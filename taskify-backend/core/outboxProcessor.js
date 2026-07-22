const ticketRepo = require('../modules/ticket/ticket.repository');
const socketHelper = require('./socketHelper');

const POLL_INTERVAL_MS = parseInt(process.env.OUTBOX_POLL_INTERVAL_MS) || 200;
const BATCH_SIZE = parseInt(process.env.OUTBOX_BATCH_SIZE) || 50;

class OutboxProcessor {
  constructor() {
    this.running = false;
    this.timer = null;
  }

  start() {
    if (this.running) return;
    this.running = true;
    console.log(`[Outbox] Processor started (poll=${POLL_INTERVAL_MS}ms, batch=${BATCH_SIZE})`);
    this._tick();
  }

  stop() {
    this.running = false;
    if (this.timer) clearTimeout(this.timer);
    console.log('[Outbox] Processor stopped');
  }

  async _tick() {
    if (!this.running) return;
    try {
      const rows = await ticketRepo.getUnprocessedOutbox(BATCH_SIZE);
      if (rows.length > 0) {
        console.log(`[Outbox] Processing ${rows.length} event(s)`);
        await this._processBatch(rows);
      }
    } catch (err) {
      console.error('[Outbox] Tick error:', err.message);
    }
    if (this.running) {
      this.timer = setTimeout(() => this._tick(), POLL_INTERVAL_MS);
    }
  }

  async _processBatch(rows) {
    const processedIds = [];

    for (const row of rows) {
      try {
        await this._processRow(row);
        processedIds.push(row.id);
      } catch (err) {
        console.error(`[Outbox] Failed to process row ${row.id} (ticket ${row.ticket_id}):`, err.message);
      }
    }

    if (processedIds.length > 0) {
      await ticketRepo.markOutboxProcessed(processedIds);
    }
  }

  async _processRow(row) {
    const { event_type, ticket_id, parent_ticket_id, payload, version } = row;
    const ticket = payload?.ticket || payload?.comment || null;

    // Resolve involved users for the ticket
    let involved = [];
    try {
      involved = await ticketRepo.getTicketInvolvedUsers(ticket_id);
    } catch (err) {
      console.error(`[Outbox] Failed to resolve involved users for ticket ${ticket_id}:`, err.message);
      return;
    }
    if (!involved || involved.length === 0) return;

    // Build message and skip list
    const message = this._buildMessage(event_type, ticket_id, ticket, payload);
    const skipUserIds = this._resolveActor(ticket, payload);

    // Create notifications + emit per-user (with notificationId) via the existing emit engine
    await socketHelper.emit(event_type, ticket_id, involved, message, payload, skipUserIds);

    // Emit enriched payload for realtime subscribers (TicketBloc stream)
    // This goes beyond the old lightweight emit — it sends the full ticket object
    this._emitEnriched(event_type, ticket_id, parent_ticket_id, involved, payload, version, skipUserIds);
  }

  _buildMessage(eventType, ticketId, ticket, payload) {
    const title = ticket?.title || '';
    const ticketNumber = ticket?.ticket_number || ticketId;

    switch (eventType) {
      case 'TICKET_CREATED':
        return `New Ticket Created: ${title}`;
      case 'TICKET_STATUS_UPDATED':
        return `Ticket #${ticketNumber} status changed to ${ticket?.status || 'updated'}`;
      case 'TICKET_CLOSED':
        return `Ticket #${ticketNumber} has been closed`;
      case 'TICKET_ASSIGNED':
        return `Ticket #${ticketNumber} assigned to ${ticket?.assigned_to_name || 'employee'}`;
      case 'TICKET_UPDATED':
        return `Ticket #${ticketNumber} was updated`;
      case 'TICKET_REOPENED':
        return `Ticket #${ticketNumber} has been reopened and is now In Progress`;
      case 'COMMENT_ADDED':
        return `New comment on Ticket #${ticketNumber}`;
      case 'SUB_TICKET_CREATED':
        return `New Multi-Task Ticket #${ticketNumber} created`;
      case 'SUB_TICKET_ASSIGNED':
        return `Ticket #${ticketNumber}: department task assigned`;
      case 'SUB_TICKET_PROGRESS':
        return `Sub-Ticket #${ticketNumber}: progress updated (${ticket?.overall_progress || 0}% complete)`;
      case 'SUB_TICKET_REOPENED':
        return `Sub-Ticket #${ticketNumber}: department task reopened`;
      case 'SUB_TICKET_COMPLETED':
        return `Sub-Ticket #${ticketNumber} has been completed`;
      default:
        return `Ticket #${ticketNumber} was updated`;
    }
  }

  _resolveActor(ticket, payload) {
    // Skip sending notification to the user who performed the action
    const actorId = payload?.actingUserId;
    if (actorId) return [actorId];
    // Fallback: comment author
    if (payload?.comment?.user_id) return [payload.comment.user_id];
    return [];
  }

  _emitEnriched(eventType, ticketId, parentTicketId, involved, payload, version, skipUserIds) {
    if (!socketHelper.io) return;

    const enrichedPayload = {
      ticketId,
      parentTicketId: parentTicketId || payload?.ticket?.parent_ticket_id || null,
      version,
      event: eventType,
      ticket: payload?.ticket || null,
      comment: payload?.comment || null,
      changedFields: payload?.changedFields || null,
      createdAt: new Date().toISOString(),
    };

    for (const userId of involved) {
      if (skipUserIds.includes(userId)) continue;
      socketHelper.io.to(`user_${userId}`).emit('TICKET_ENRICHED', enrichedPayload);
    }

    // Also broadcast to department rooms for dashboard live updates
    const assignedDeptId = payload?.ticket?.assigned_dept_id;
    if (assignedDeptId) {
      socketHelper.io.to(`dept_${assignedDeptId}`).emit('TICKET_ENRICHED', enrichedPayload);
    }
    const creatorDeptId = payload?.ticket?.created_by_dept;
    if (creatorDeptId && Number(creatorDeptId) !== Number(assignedDeptId)) {
      socketHelper.io.to(`dept_${creatorDeptId}`).emit('TICKET_ENRICHED', enrichedPayload);
    }
  }
}

module.exports = new OutboxProcessor();
