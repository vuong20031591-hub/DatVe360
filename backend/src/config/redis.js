const Redis = require('ioredis');
const logger = require('../utils/logger');

class RedisClient {
  constructor() {
    this.client = null;
    this.isConnected = false;
    this.init();
  }

  init() {
    if (!process.env.REDIS_URL) {
      logger.warn('Redis URL not configured, skipping Redis setup');
      return;
    }

    try {
      this.client = new Redis(process.env.REDIS_URL, {
        retryDelayOnFailure: (times) => Math.min(times * 50, 2000),
        maxRetriesPerRequest: 3,
        lazyConnect: true,
        keepAlive: 30000,
        family: 4,
      });

      this.setupEventHandlers();
      // Don't auto-connect, only connect when explicitly called
      // this.connect();
    } catch (error) {
      logger.error('Redis initialization error:', error);
    }
  }

  setupEventHandlers() {
    if (!this.client) return;

    this.client.on('connect', () => {
      logger.info('Redis connected');
      this.isConnected = true;
    });

    this.client.on('ready', () => {
      logger.info('Redis ready');
    });

    this.client.on('error', (error) => {
      logger.error('Redis error:', error);
      this.isConnected = false;
    });

    this.client.on('close', () => {
      logger.warn('Redis connection closed');
      this.isConnected = false;
    });

    this.client.on('reconnecting', (ms) => {
      logger.info(`Redis reconnecting in ${ms}ms`);
    });

    this.client.on('end', () => {
      logger.warn('Redis connection ended');
      this.isConnected = false;
    });
  }

  async connect() {
    if (!this.client) return false;

    try {
      await this.client.connect();
      return true;
    } catch (error) {
      logger.error('Redis connection failed:', error);
      return false;
    }
  }

  async disconnect() {
    if (this.client) {
      await this.client.quit();
      this.isConnected = false;
    }
  }

  // Cache methods
  async get(key) {
    if (!this.isConnected) return null;
    
    try {
      const value = await this.client.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.error('Redis GET error:', error);
      return null;
    }
  }

  async set(key, value, ttl = null) {
    if (!this.isConnected) return false;

    try {
      const serialized = JSON.stringify(value);
      if (ttl) {
        await this.client.setex(key, ttl, serialized);
      } else {
        await this.client.set(key, serialized);
      }
      return true;
    } catch (error) {
      logger.error('Redis SET error:', error);
      return false;
    }
  }

  async del(key) {
    if (!this.isConnected) return false;

    try {
      await this.client.del(key);
      return true;
    } catch (error) {
      logger.error('Redis DEL error:', error);
      return false;
    }
  }

  async exists(key) {
    if (!this.isConnected) return false;

    try {
      const exists = await this.client.exists(key);
      return exists === 1;
    } catch (error) {
      logger.error('Redis EXISTS error:', error);
      return false;
    }
  }

  async expire(key, ttl) {
    if (!this.isConnected) return false;

    try {
      await this.client.expire(key, ttl);
      return true;
    } catch (error) {
      logger.error('Redis EXPIRE error:', error);
      return false;
    }
  }

  async ping() {
    if (!this.isConnected) return 'PONG (disconnected)';

    try {
      return await this.client.ping();
    } catch (error) {
      logger.error('Redis PING error:', error);
      return 'PONG (error)';
    }
  }

  // Hash operations
  async hget(key, field) {
    if (!this.isConnected) return null;

    try {
      const value = await this.client.hget(key, field);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.error('Redis HGET error:', error);
      return null;
    }
  }

  async hset(key, field, value) {
    if (!this.isConnected) return false;

    try {
      const serialized = JSON.stringify(value);
      await this.client.hset(key, field, serialized);
      return true;
    } catch (error) {
      logger.error('Redis HSET error:', error);
      return false;
    }
  }

  async hdel(key, field) {
    if (!this.isConnected) return false;

    try {
      await this.client.hdel(key, field);
      return true;
    } catch (error) {
      logger.error('Redis HDEL error:', error);
      return false;
    }
  }

  // List operations
  async lpush(key, value) {
    if (!this.isConnected) return false;

    try {
      const serialized = JSON.stringify(value);
      await this.client.lpush(key, serialized);
      return true;
    } catch (error) {
      logger.error('Redis LPUSH error:', error);
      return false;
    }
  }

  async rpop(key) {
    if (!this.isConnected) return null;

    try {
      const value = await this.client.rpop(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.error('Redis RPOP error:', error);
      return null;
    }
  }

  // Cache utilities
  getCacheKey(...parts) {
    return parts.join(':');
  }

  getDefaultTTL() {
    return parseInt(process.env.CACHE_TTL) || 3600; // 1 hour
  }

  // Session management
  async setSession(sessionId, data, ttl = null) {
    const key = this.getCacheKey('session', sessionId);
    const sessionTTL = ttl || this.getDefaultTTL();
    return await this.set(key, data, sessionTTL);
  }

  async getSession(sessionId) {
    const key = this.getCacheKey('session', sessionId);
    return await this.get(key);
  }

  async deleteSession(sessionId) {
    const key = this.getCacheKey('session', sessionId);
    return await this.del(key);
  }

  // Rate limiting
  async checkRateLimit(identifier, maxRequests = 100, windowSeconds = 3600) {
    if (!this.isConnected) return { allowed: true, remaining: maxRequests };

    const key = this.getCacheKey('ratelimit', identifier);
    
    try {
      const current = await this.client.get(key);
      
      if (!current) {
        await this.client.setex(key, windowSeconds, '1');
        return { allowed: true, remaining: maxRequests - 1 };
      }

      const count = parseInt(current);
      if (count >= maxRequests) {
        return { allowed: false, remaining: 0 };
      }

      await this.client.incr(key);
      return { allowed: true, remaining: maxRequests - count - 1 };
    } catch (error) {
      logger.error('Redis rate limit error:', error);
      return { allowed: true, remaining: maxRequests };
    }
  }

  get status() {
    return this.isConnected ? 'ready' : 'disconnected';
  }
}

// Create singleton instance
const redisClient = new RedisClient();

// Graceful shutdown
process.on('SIGTERM', async () => {
  await redisClient.disconnect();
});

process.on('SIGINT', async () => {
  await redisClient.disconnect();
});

module.exports = redisClient;
