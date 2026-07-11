const EventEmitter = require('events');

class AppEventBus extends EventEmitter {
  constructor() {
    super();
    this.setMaxListeners(100);
  }

  emitTicketEvent(eventType, ticketId, data = {}) {
    this.emit('ticket:*', { eventType, ticketId, data });
    this.emit(`ticket:${eventType}`, { ticketId, data });
  }

  emitNotification(userId, ticketId, message, eventType, payload = {}) {
    this.emit('notification', { userId, ticketId, message, eventType, payload });
  }
}

module.exports = new AppEventBus();
