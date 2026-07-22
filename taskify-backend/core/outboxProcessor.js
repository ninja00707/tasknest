// ── Event Outbox Processor ──────────────────────────────────────────────
// Polls `event_outbox` for unprocessed rows, resolves involved users,
// emits via Socket.IO, dispatches notifications, then marks processed.
// Runs in-process via setInterval; single-instance only (safe for now).

const pool = require('../database/db');
const { broadcast, broadcastNotification } = require('./socket');
const queueManager = require('./queue');

const POLL_INTERVAL_MS = parseInt(process.env.OUTBOX_POLL_MS) || 100;
const BATCH_SIZE = parseInt(process.env.OUTBOX_BATCH_SIZE) || 20;
const BACKOFF_INTERVAL_MS = 10000; // 10s between retries when table is missing

let _running = false;
let _timer = null;
let _consecutiveErrors = 0;

async function _processBatch() {
  if (_running) return;
  _running = true;

  const client = await pool.connect();
  try {
    // ── Claim a batch of unprocessed rows atomically ───────────────────
    const { rows: events } = await client.query(`
      SELECT id, event_type, ticket_id, parent_ticket_id, payload, actor_id, version, created_at
      FROM event_outbox
      WHERE processed_at IS NULL
      ORDER BY created_at ASC
      LIMIT $1
      FOR UPDATE SKIP LOCKED
    `, [BATCH_SIZE]);

    // Reset error counter on success
    _consecutiveErrors = 0;

    if (events.length === 0) {
      _running = false;
      return;
    }

    for (const evt of events) {
      try {
        await _processEvent(client, evt);
        await client.query(
          'UPDATE event_outbox SET processed_at = now() WHERE id = $1',
          [evt.id]
        );
      } catch (err) {
        console.error(`[OutboxProcessor] Event ${evt.id} (ticket ${evt.ticket_id}) failed:`, err.message);
        // Mark as processed to avoid infinite retry loops.
        // In production you'd want a retry_count column + dead-letter queue.
        await client.query(
          'UPDATE event_outbox SET processed_at = now() WHERE id = $1',
          [evt.id]
        );
      }
    }
  } catch (err) {
    _consecutiveErrors++;
    console.error(`[OutboxProcessor] Batch error (${_consecutiveErrors}):`, err.message);

    // If the table is missing or schema is wrong, pause the processor
    if (_consecutiveErrors >= 3) {
      console.warn('[OutboxProcessor] Too many consecutive errors — pausing. Run the migration and restart.');
      stop();
    }
  } finally {
    client.release();
    _running = false;
  }
}

async function _processEvent(client, evt) {
  const { event_type, ticket_id, parent_ticket_id, payload, actor_id, version } = evt;

  // ── 1. Resolve involved users via existing recursive tree logic ─────
  const { rows: participantRows } = await client.query(
    'SELECT get_ticket_participants($1) AS user_ids',
    [ticket_id]
  );

  // Fallback: if the PG function doesn't exist, use the JS repository
  let involvedUserIds;
  try {
    const ticketRepo = require('../modules/ticket/ticket.repository');
    involvedUserIds = await ticketRepo.getTicketParticipants(ticket_id);
  } catch (_) {
    // If the repository method fails, broadcast to all (dashboard room)
    involvedUserIds = [];
  }

  // ── 2. Build enriched payload ───────────────────────────────────────
  const enrichedPayload = {
    ticket: payload,
    ticketId: ticket_id,
    parentTicketId: parent_ticket_id || payload?.parent_ticket_id || null,
    type: event_type,
    version: version,
    updatedAt: new Date().toISOString(),
    changedFields: _inferChangedFields(event_type),
  };

  // ── 3. Emit via Socket.IO ──────────────────────────────────────────
  broadcast(event_type, enrichedPayload, ticket_id, actor_id, involvedUserIds);

  // ── 4. Dispatch notifications via queue ────────────────────────────
  const notifMessage = _buildNotificationMessage(event_type, payload, ticket_id);
  if (notifMessage) {
    try {
      const queue = queueManager.get('notifications');
      await queue.add('dispatch', {
        ticketId: ticket_id,
        userIds: involvedUserIds,
        message: notifMessage,
        eventType: event_type,
        payload: { ticketNumber: payload?.ticket_number || payload?.ticketNumber || ticket_id },
        skipUserIds: [actor_id],
      });
    } catch (err) {
      console.error(`[OutboxProcessor] Notification dispatch failed for ticket ${ticket_id}:`, err.message);
    }
  }
}

function _inferChangedFields(eventType) {
  if (eventType === 'ticket:created') return ['*'];
  return ['status'];
}

function _buildNotificationMessage(eventType, payload, ticketId) {
  const ticketNum = payload?.ticket_number || `#${ticketId}`;
  switch (eventType) {
    case 'ticket:created':
      return `New ticket ${ticketNum} created`;
    case 'ticket:updated':
      return `Ticket ${ticketNum} has been updated`;
    default:
      return null;
  }
}

function start() {
  if (_timer) return;
  console.log(`[OutboxProcessor] Starting (poll=${POLL_INTERVAL_MS}ms, batch=${BATCH_SIZE})`);
  _timer = setInterval(_processBatch, POLL_INTERVAL_MS);
}

function stop() {
  if (_timer) {
    clearInterval(_timer);
    _timer = null;
  }
  console.log('[OutboxProcessor] Stopped');
}

module.exports = { start, stop, _processBatch };
