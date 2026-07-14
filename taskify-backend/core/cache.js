class MemoryCache {
  constructor() {
    this.store = new Map();
    this.timers = new Map();
  }

  async get(key) {
    const entry = this.store.get(key);
    if (!entry) return null;
    if (entry.ttl && Date.now() > entry.expires) { this.store.delete(key); return null; }
    return entry.value;
  }

  async set(key, value, ttlSec = 0) {
    this.store.set(key, { value, ttl: ttlSec > 0, expires: Date.now() + ttlSec * 1000 });
    if (ttlSec > 0) {
      if (this.timers.has(key)) clearTimeout(this.timers.get(key));
      this.timers.set(key, setTimeout(() => this.store.delete(key), ttlSec * 1000).unref());
    }
  }

  async del(key) { this.store.delete(key); if (this.timers.has(key)) { clearTimeout(this.timers.get(key)); this.timers.delete(key); } }
  async flush() { this.store.clear(); for (const t of this.timers.values()) clearTimeout(t); this.timers.clear(); }
}

class CacheManager {
  constructor() {
    this.redis = null;
    this.memory = new MemoryCache();
    this.ready = false;
  }

  async init() {
    if (!process.env.REDIS_URL && !(process.env.REDIS_HOST && process.env.REDIS_PORT)) {
      console.log('[Cache] No Redis config, using in-memory cache');
      return;
    }
    try {
      const Redis = require('ioredis');
      const url = process.env.REDIS_URL || `redis://${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`;
      this.redis = new Redis(url, {
        maxRetriesPerRequest: 1,
        retryStrategy: () => null,
        lazyConnect: true,
        enableReadyCheck: false,
      });
      // Attach handlers BEFORE connect to catch immediate failures
      this.redis.on('error', () => {}); // suppress ECONNREFUSED spam
      this.redis.on('ready', () => { this.ready = true; console.log('[Cache] Redis connected'); });
      this.redis.on('close', () => { this.ready = false; });
      await this.redis.connect();
      console.log('[Cache] Using Redis');
    } catch (err) {
      console.warn('[Cache] Redis unavailable, using in-memory cache');
      this.redis = null;
    }
  }

  async get(key) {
    if (this.redis && this.ready) { try { const v = await this.redis.get(key); return v ? JSON.parse(v) : null; } catch {} }
    return this.memory.get(key);
  }

  async set(key, value, ttlSec = 300) {
    if (this.redis && this.ready) { try { const str = JSON.stringify(value); if (ttlSec > 0) await this.redis.setex(key, ttlSec, str); else await this.redis.set(key, str); return; } catch {} }
    await this.memory.set(key, value, ttlSec);
  }

  async del(key) { if (this.redis && this.ready) { try { await this.redis.del(key); } catch {} } await this.memory.del(key); }
  async flush() { if (this.redis && this.ready) { try { await this.redis.flushdb(); } catch {} } await this.memory.flush(); }

  async remember(key, ttlSec, fn) {
    const cached = await this.get(key);
    if (cached !== null && cached !== undefined) return cached;
    const value = await fn();
    await this.set(key, value, ttlSec);
    return value;
  }
}

module.exports = new CacheManager();
