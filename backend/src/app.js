require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { createServer } = require('http');
const { Server } = require('socket.io');

// Import configurations
const connectDB = require('./config/database');
// const connectRedis = require('./config/redis'); // Commented out for now
const logger = require('./utils/logger');

// Import middleware - Temporarily commented out for testing
// const errorHandler = require('./middleware/errorHandler');
// const notFound = require('./middleware/notFound');

// Import routes
let authRoutes, tripRoutes, bookingRoutes, scheduleRoutes, destinationRoutes;
try {
  authRoutes = require('./routes/auth');
  tripRoutes = require('./routes/trip');
  bookingRoutes = require('./routes/bookings');
  scheduleRoutes = require('./routes/schedules');
  destinationRoutes = require('./routes/destinations');
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

// Connect to databases
connectDB();
// connectRedis(); // Commented out for now

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
app.use(`${API_PREFIX}/destinations`, destinationRoutes);

// Static files for uploads
app.use('/uploads', express.static('uploads'));

// Error handling middleware - Temporarily commented out for testing
// app.use(notFound);
// app.use(errorHandler);

const PORT = process.env.PORT || 5000;

server.listen(PORT, '0.0.0.0', () => {
  logger.info(`🚀 Server started on port ${PORT} in ${process.env.NODE_ENV} mode`);
  logger.info(`🌐 API available at http://localhost:${PORT}${API_PREFIX}`);
  logger.info(`🌐 API available at http://192.168.100.245:${PORT}${API_PREFIX}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    logger.info('Process terminated');
  });
});

module.exports = app;
