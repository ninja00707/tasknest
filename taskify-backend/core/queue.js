// ── Background Job Queue ───────────────────────────────────────────────────
// Uses BullMQ + Redis in production; falls back to in-process setImmediate
// when Redis is unavailable. All backgroundable operations go through here.

class InProcessQueue {
  constructor(name) {
    this.name = name;
    this.handlers = new Map();
  }

  async add(jobName, data, opts = {}) {
    setImmediate(async () => {
      const handler = this.handlers.get(jobName);
      if (handler) {
        try { await handler({ id: `${Date.now()}-${Math.random()}`, data, opts }); }
        catch (err) { console.error(`[Queue:${this.name}] Job ${jobName} failed:`, err.message); }
      }
    });
  }

  process(jobName, handler) { this.handlers.set(jobName, handler); }

  async close() { this.handlers.clear(); }
}

class BullQueue {
  constructor(name) {
    const Bull = require('bullmq');
    const connection = { host: process.env.REDIS_HOST || 'localhost', port: parseInt(process.env.REDIS_PORT) || 6379 };
    if (process.env.REDIS_URL) connection.url = process.env.REDIS_URL;
    this.queue = new Bull.Queue(name, { connection, defaultJobOptions: { removeOnComplete: 100, removeOnFail: 50 } });
  }

  async add(jobName, data, opts = {}) {
    return this.queue.add(jobName, data, opts);
  }

  process(jobName, handler) {
    new Bull.Worker(this.queue.name, async (job) => {
      if (job.name === jobName) await handler(job);
    }, { connection: this.queue.opts.connection });
  }

  async close() { await this.queue.close(); }
}

class QueueManager {
  constructor() {
    this.queues = new Map();
    this.useBull = false;
  }

  async init() {
    if (process.env.REDIS_URL || (process.env.REDIS_HOST && process.env.REDIS_PORT)) {
      try {
        const Redis = require('ioredis');
        const test = new Redis({
          host: process.env.REDIS_HOST || 'localhost',
          port: parseInt(process.env.REDIS_PORT) || 6379,
          maxRetriesPerRequest: 1,
          retryStrategy: () => null,
          lazyConnect: true,
          enableReadyCheck: false,
        });
        test.on('error', () => {});
        await test.connect();
        await test.quit();
        this.useBull = true;
        console.log('[Queue] Using BullMQ (Redis available)');
      } catch (err) {
        console.warn('[Queue] Redis unavailable, using in-process queue');
      }
    }
  }

  get(name) {
    if (this.queues.has(name)) return this.queues.get(name);
    const q = this.useBull ? new BullQueue(name) : new InProcessQueue(name);
    this.queues.set(name, q);
    return q;
  }

  async closeAll() {
    for (const q of this.queues.values()) await q.close();
  }
}

module.exports = new QueueManager();
