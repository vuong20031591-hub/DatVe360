require('dotenv').config();

// Handle unhandled promise rejections early
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise);
  console.error('Reason:', reason);
  process.exit(1);
});

// Handle uncaught exceptions early
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { createServer } = require('http');
const { Server } = require('socket.io');

// Import configurations
const connectDB = require('./config/database');
const redisClient = require('./config/redis');
const logger = require('./utils/logger');

// Import middleware
const { errorHandler, notFound } = require('./middleware/errorHandler');

// Import routes
let authRoutes, tripRoutes, bookingRoutes, scheduleRoutes, seatRoutes, destinationRoutes, paymentRoutes, ticketRoutes, adminUsersRoutes, adminTicketsRoutes, adminCategoriesRoutes, adminSchedulesRoutes, adminSchedulesByTypeRoutes, adminBookingsRoutes, adminPaymentsRoutes, adminReportsRoutes;
try {
  console.log('Loading routes...');
  authRoutes = require('./routes/auth');
  console.log('Auth routes loaded');
  tripRoutes = require('./routes/trip');
  console.log('Trip routes loaded');
  bookingRoutes = require('./routes/bookings');
  console.log('Booking routes loaded');
  scheduleRoutes = require('./routes/schedules');
  console.log('Schedule routes loaded');
  seatRoutes = require('./routes/seats');
  console.log('Seat routes loaded');
  destinationRoutes = require('./routes/destinations');
  console.log('Destination routes loaded');
  paymentRoutes = require('./routes/payments');
  console.log('Payment routes loaded');
  ticketRoutes = require('./routes/tickets');
  console.log('Ticket routes loaded');
  adminUsersRoutes = require('./routes/admin/users');
  adminTicketsRoutes = require('./routes/admin/tickets');
  adminCategoriesRoutes = require('./routes/admin/categories');
  adminSchedulesRoutes = require('./routes/admin/schedules');
  adminSchedulesByTypeRoutes = require('./routes/admin/schedules-by-type');
  adminBookingsRoutes = require('./routes/admin/bookings');
  adminPaymentsRoutes = require('./routes/admin/payments');
  adminReportsRoutes = require('./routes/admin/reports');
} catch (error) {
  console.error('Error importing routes:', error);
  process.exit(1);
}

// Import socket handlers (commented out for now)
// const socketHandler = require('./socket/socketHandler');

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || ["http://localhost:3000"],
    credentials: true
  }
});

// Database connections will be initialized before starting server

// Security middleware
app.use(helmet());
app.use(cors({
  origin: true, // Allow all origins for testing
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: {
    error: 'Quá nhiều yêu cầu từ địa chỉ IP này, vui lòng thử lại sau.'
  }
});
app.use('/api', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use(morgan('combined', { 
  stream: { write: message => logger.info(message.trim()) }
}));

// Socket.IO (commented out for now)
// socketHandler(io);
app.set('io', io);

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

// API Routes
const API_PREFIX = `/api/${process.env.API_VERSION || 'v1'}`;

app.use(`${API_PREFIX}/auth`, authRoutes);
app.use(`${API_PREFIX}/trips`, tripRoutes);
app.use(`${API_PREFIX}/bookings`, bookingRoutes);
app.use(`${API_PREFIX}/schedules`, scheduleRoutes);
app.use(`${API_PREFIX}/seats`, seatRoutes);
app.use(`${API_PREFIX}/destinations`, destinationRoutes);
app.use(`${API_PREFIX}/payments`, paymentRoutes);
app.use(`${API_PREFIX}/tickets`, ticketRoutes);
app.use(`${API_PREFIX}/admin/users`, adminUsersRoutes);
app.use(`${API_PREFIX}/admin/tickets`, adminTicketsRoutes);
app.use(`${API_PREFIX}/admin/categories`, adminCategoriesRoutes);
app.use(`${API_PREFIX}/admin/schedules`, adminSchedulesRoutes);
app.use(`${API_PREFIX}/admin/schedules-by-type`, adminSchedulesByTypeRoutes);
app.use(`${API_PREFIX}/admin/bookings`, adminBookingsRoutes);
app.use(`${API_PREFIX}/admin/payments`, adminPaymentsRoutes);
app.use(`${API_PREFIX}/admin/reports`, adminReportsRoutes);

// Static files for uploads
app.use('/uploads', express.static('uploads'));

// Error handling middleware
app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 5000;

// Start server function
const startServer = async () => {
  try {
    // Connect to databases first
    await connectDB();
    await redisClient.connect();

    // Then start the server
    server.listen(PORT, '0.0.0.0', () => {
      logger.info(`🚀 Server started on port ${PORT} in ${process.env.NODE_ENV} mode`);
      logger.info(`🌐 API available at http://localhost:${PORT}${API_PREFIX}`);
      logger.info(`🌐 API available at http://192.168.100.245:${PORT}${API_PREFIX}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Start the server
startServer();

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    logger.info('Process terminated');
  });
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  console.error('Unhandled Rejection:', reason);
  process.exit(1);
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

module.exports = app;
