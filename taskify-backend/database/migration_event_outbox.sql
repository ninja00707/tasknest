-- ── Event Outbox ──────────────────────────────────────────────────────
-- Reliable event emission: writes happen in the same transaction as the
-- business mutation; a background processor picks up unprocessed rows
-- and emits via Socket.IO + dispatches notifications.

CREATE TABLE IF NOT EXISTS event_outbox (
  id              BIGSERIAL PRIMARY KEY,
  event_type      VARCHAR(100) NOT NULL,       -- ticket:created | ticket:updated
  ticket_id       INT NOT NULL REFERENCES tickets(id),
  parent_ticket_id INT REFERENCES tickets(id), -- populated when ticket_id is a sub-ticket
  payload         JSONB NOT NULL,              -- the full ticket DTO to broadcast
  actor_id        INT NOT NULL REFERENCES users(id),
  version         BIGINT NOT NULL,
  created_at      TIMESTAMPTZ DEFAULT now(),
  processed_at    TIMESTAMPTZ
);

-- Partial index: only unprocessed rows need fast lookups
CREATE INDEX IF NOT EXISTS idx_event_outbox_unprocessed
  ON event_outbox (created_at)
  WHERE processed_at IS NULL;
