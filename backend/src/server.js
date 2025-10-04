const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { Server } = require('socket.io');
const http = require('http');

require('dotenv').config();

const connectDB = require('./config/database');
const redis = require('./config/redis');
const logger = require('./config/logger');
const { errorHandler, notFound } = require('./middleware/errorHandler');

// Route imports
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const destinationRoutes = require('./routes/destinations');
const routeRoutes = require('./routes/routes');
const scheduleRoutes = require('./routes/schedules');
const bookingRoutes = require('./routes/bookings');
const ticketRoutes = require('./routes/tickets');
const paymentRoutes = require('./routes/payments');
const adminRoutes = require('./routes/admin');
const uploadRoutes = require('./routes/uploads');

// Socket handlers
const socketHandlers = require('./sockets');

class AppServer {
  constructor() {
    this.app = express();
    this.server = http.createServer(this.app);
    this.io = new Server(this.server, {
      cors: {
        origin: process.env.SOCKET_IO_ORIGINS || "http://localhost:*",
        methods: ["GET", "POST"]
      }
    });
    
    this.port = process.env.PORT || 3000;
    this.apiVersion = process.env.API_VERSION || 'v1';
    
    this.initializeDatabase();
    this.initializeRedis();
    this.initializeMiddlewares();
    this.initializeRoutes();
    this.initializeSocketHandlers();
    this.initializeErrorHandling();
  }

  async initializeDatabase() {
    try {
      await connectDB();
      logger.info('✅ Database connected successfully');
    } catch (error) {
      logger.error('❌ Database connection failed:', error);
      process.exit(1);
    }
  }

  async initializeRedis() {
    try {
      await redis.ping();
      logger.info('✅ Redis connected successfully');
    } catch (error) {
      logger.warn('⚠️ Redis connection failed, continuing without cache');
    }
  }

  initializeMiddlewares() {
    // Security middleware
    this.app.use(helmet({
      contentSecurityPolicy: false, // For development
      crossOriginResourcePolicy: { policy: "cross-origin" }
    }));
    
    // CORS
    this.app.use(cors({
      origin: (origin, callback) => {
        const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'];
        if (!origin || allowedOrigins.includes(origin)) {
          callback(null, true);
        } else {
          callback(new Error('Not allowed by CORS'));
        }
      },
      credentials: true,
    }));

    // Rate limiting
    const limiter = rateLimit({
      windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
      max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
      message: {
        error: 'Quá nhiều yêu cầu từ IP này, vui lòng thử lại sau.'
      },
      standardHeaders: true,
      legacyHeaders: false,
    });
    this.app.use(`/api/${this.apiVersion}`, limiter);

    // Body parsing
    this.app.use(express.json({ 
      limit: '10mb',
      verify: (req, res, buf) => {
        req.rawBody = buf;
      }
    }));
    this.app.use(express.urlencoded({ extended: true, limit: '10mb' }));

    // Compression
    this.app.use(compression());

    // Logging
    if (process.env.NODE_ENV === 'development') {
      this.app.use(morgan('dev'));
    } else {
      this.app.use(morgan('combined', {
        stream: { write: message => logger.info(message.trim()) }
      }));
    }

    // Static files
    this.app.use('/uploads', express.static('uploads'));

    // Request ID and timing
    this.app.use((req, res, next) => {
      req.requestId = require('uuid').v4();
      req.startTime = Date.now();
      res.setHeader('X-Request-ID', req.requestId);
      next();
    });
  }

  initializeRoutes() {
    const apiPrefix = `/api/${this.apiVersion}`;
    
    // Health check
    this.app.get(`${apiPrefix}/health`, (req, res) => {
      const uptime = process.uptime();
      const memoryUsage = process.memoryUsage();
      
      res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        uptime: `${Math.floor(uptime / 60)}m ${Math.floor(uptime % 60)}s`,
        environment: process.env.NODE_ENV,
        version: require('../package.json').version,
        memory: {
          used: `${Math.round(memoryUsage.heapUsed / 1024 / 1024)}MB`,
          total: `${Math.round(memoryUsage.heapTotal / 1024 / 1024)}MB`
        },
        database: 'connected',
        cache: redis.status === 'ready' ? 'connected' : 'disconnected'
      });
    });

    // API routes
    this.app.use(`${apiPrefix}/auth`, authRoutes);
    this.app.use(`${apiPrefix}/users`, userRoutes);
    this.app.use(`${apiPrefix}/destinations`, destinationRoutes);
    this.app.use(`${apiPrefix}/routes`, routeRoutes);
    this.app.use(`${apiPrefix}/schedules`, scheduleRoutes);
    this.app.use(`${apiPrefix}/bookings`, bookingRoutes);
    this.app.use(`${apiPrefix}/tickets`, ticketRoutes);
    this.app.use(`${apiPrefix}/payments`, paymentRoutes);
    this.app.use(`${apiPrefix}/admin`, adminRoutes);
    this.app.use(`${apiPrefix}/uploads`, uploadRoutes);

    // Root route
    this.app.get('/', (req, res) => {
      res.json({
        message: 'DatVe360 Backend API',
        version: require('../package.json').version,
        author: 'DatVe360 Team',
        environment: process.env.NODE_ENV,
        documentation: `${process.env.BASE_URL}${apiPrefix}/docs`,
        endpoints: {
          health: `${apiPrefix}/health`,
          auth: `${apiPrefix}/auth`,
          destinations: `${apiPrefix}/destinations`,
          routes: `${apiPrefix}/routes`,
          schedules: `${apiPrefix}/schedules`,
          bookings: `${apiPrefix}/bookings`,
          tickets: `${apiPrefix}/tickets`,
          payments: `${apiPrefix}/payments`,
          admin: `${apiPrefix}/admin`,
        },
        features: [
          'JWT Authentication',
          'Real-time booking updates',
          'Payment gateway integration',
          'QR code generation',
          'PDF ticket generation',
          'Email notifications',
          'Admin dashboard API'
        ]
      });
    });
  }

  initializeSocketHandlers() {
    socketHandlers(this.io);
  }

  initializeErrorHandling() {
    // 404 handler
    this.app.use(notFound);
    
    // Global error handler
    this.app.use(errorHandler);

    // Graceful shutdown
    process.on('SIGTERM', () => {
      logger.info('SIGTERM received, shutting down gracefully');
      this.server.close(() => {
        logger.info('Process terminated');
        process.exit(0);
      });
    });

    process.on('SIGINT', () => {
      logger.info('SIGINT received, shutting down gracefully');
      this.server.close(() => {
        logger.info('Process terminated');
        process.exit(0);
      });
    });

    // Handle uncaught exceptions
    process.on('uncaughtException', (error) => {
      logger.error('Uncaught Exception:', error);
      process.exit(1);
    });

    process.on('unhandledRejection', (reason, promise) => {
      logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
      process.exit(1);
    });
  }

  start() {
    this.server.listen(this.port, () => {
      logger.info(`🚀 Server running on port ${this.port}`);
      logger.info(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`📚 API Base URL: ${process.env.BASE_URL}/api/${this.apiVersion}`);
      logger.info(`🏥 Health Check: ${process.env.BASE_URL}/api/${this.apiVersion}/health`);
      logger.info(`🔌 Socket.IO ready for real-time connections`);
    });
  }

  getApp() {
    return this.app;
  }

  getServer() {
    return this.server;
  }

  getIO() {
    return this.io;
  }
}

// Start server if this file is run directly
if (require.main === module) {
  const appServer = new AppServer();
  appServer.start();
}

module.exports = AppServer;
