const winston = require('winston');
const path = require('path');
const fs = require('fs');

// Create logs directory if it doesn't exist
const logsDir = path.join(process.cwd(), 'logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Custom log format
const logFormat = winston.format.combine(
  winston.format.timestamp({
    format: 'YYYY-MM-DD HH:mm:ss'
  }),
  winston.format.errors({ stack: true }),
  winston.format.json(),
  winston.format.prettyPrint()
);

// Console format for development
const consoleFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({
    format: 'HH:mm:ss'
  }),
  winston.format.printf(({ timestamp, level, message, ...meta }) => {
    let log = `${timestamp} [${level}]: ${message}`;
    
    if (Object.keys(meta).length > 0) {
      log += ' ' + JSON.stringify(meta, null, 2);
    }
    
    return log;
  })
);

// Create logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: logFormat,
  defaultMeta: { service: 'datve360-backend' },
  transports: [
    // Error log file
    new winston.transports.File({
      filename: path.join(logsDir, 'error.log'),
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5,
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      )
    }),
    
    // Combined log file
    new winston.transports.File({
      filename: path.join(logsDir, 'combined.log'),
      maxsize: 5242880, // 5MB
      maxFiles: 10,
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      )
    })
  ],
  
  // Handle exceptions and rejections
  exceptionHandlers: [
    new winston.transports.File({
      filename: path.join(logsDir, 'exceptions.log'),
      maxsize: 5242880,
      maxFiles: 5
    })
  ],
  
  rejectionHandlers: [
    new winston.transports.File({
      filename: path.join(logsDir, 'rejections.log'),
      maxsize: 5242880,
      maxFiles: 5
    })
  ]
});

// Add console transport for development
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: consoleFormat,
    level: 'debug'
  }));
}

// Request logger middleware
logger.requestLogger = (req, res, next) => {
  const startTime = Date.now();
  
  // Log request
  logger.info('Incoming request', {
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    requestId: req.requestId
  });
  
  // Log response when finished
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    
    logger.info('Request completed', {
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      requestId: req.requestId
    });
  });
  
  next();
};

// Database logger
logger.dbLogger = {
  info: (message, meta = {}) => {
    logger.info(`[DATABASE] ${message}`, meta);
  },
  error: (message, error = {}) => {
    logger.error(`[DATABASE] ${message}`, { error });
  },
  warn: (message, meta = {}) => {
    logger.warn(`[DATABASE] ${message}`, meta);
  }
};

// Payment logger
logger.paymentLogger = {
  info: (message, meta = {}) => {
    logger.info(`[PAYMENT] ${message}`, meta);
  },
  error: (message, error = {}) => {
    logger.error(`[PAYMENT] ${message}`, { error });
  },
  warn: (message, meta = {}) => {
    logger.warn(`[PAYMENT] ${message}`, meta);
  }
};

// Auth logger
logger.authLogger = {
  info: (message, meta = {}) => {
    logger.info(`[AUTH] ${message}`, meta);
  },
  error: (message, error = {}) => {
    logger.error(`[AUTH] ${message}`, { error });
  },
  warn: (message, meta = {}) => {
    logger.warn(`[AUTH] ${message}`, meta);
  }
};

// Booking logger
logger.bookingLogger = {
  info: (message, meta = {}) => {
    logger.info(`[BOOKING] ${message}`, meta);
  },
  error: (message, error = {}) => {
    logger.error(`[BOOKING] ${message}`, { error });
  },
  warn: (message, meta = {}) => {
    logger.warn(`[BOOKING] ${message}`, meta);
  }
};

// Utility methods
logger.logError = (error, context = {}) => {
  logger.error(error.message, {
    error: {
      name: error.name,
      message: error.message,
      stack: error.stack
    },
    ...context
  });
};

logger.logApiCall = (method, endpoint, duration, statusCode, requestId) => {
  logger.info('API call completed', {
    method,
    endpoint,
    duration: `${duration}ms`,
    statusCode,
    requestId
  });
};

logger.logUserAction = (userId, action, details = {}) => {
  logger.info('User action', {
    userId,
    action,
    ...details
  });
};

logger.logSecurityEvent = (event, details = {}) => {
  logger.warn(`[SECURITY] ${event}`, details);
};

module.exports = logger;
