const fs = require('fs');
const path = require('path');

// Ensure logs directory exists
const logsDir = path.join(__dirname, '../../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Log levels
const LOG_LEVELS = {
  ERROR: 0,
  WARN: 1,
  INFO: 2,
  DEBUG: 3
};

const currentLogLevel = LOG_LEVELS[process.env.LOG_LEVEL?.toUpperCase()] ?? LOG_LEVELS.INFO;

// Color codes for console output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  gray: '\x1b[90m'
};

class Logger {
  constructor() {
    this.logFile = path.join(logsDir, `app-${new Date().toISOString().split('T')[0]}.log`);
  }

  formatMessage(level, message, ...args) {
    const timestamp = new Date().toISOString();
    const formattedArgs = args.length > 0 ? ' ' + args.map(arg => 
      typeof arg === 'object' ? JSON.stringify(arg, null, 2) : String(arg)
    ).join(' ') : '';
    
    return `[${timestamp}] ${level}: ${message}${formattedArgs}`;
  }

  writeToFile(logMessage) {
    try {
      fs.appendFileSync(this.logFile, logMessage + '\n');
    } catch (error) {
      console.error('Failed to write to log file:', error.message);
    }
  }

  log(level, color, message, ...args) {
    if (LOG_LEVELS[level] > currentLogLevel) return;

    const logMessage = this.formatMessage(level, message, ...args);
    
    // Console output with colors (only in development)
    if (process.env.NODE_ENV !== 'production') {
      console.log(`${color}${logMessage}${colors.reset}`);
    }
    
    // File output (always)
    this.writeToFile(logMessage);
  }

  error(message, ...args) {
    this.log('ERROR', colors.red, message, ...args);
  }

  warn(message, ...args) {
    this.log('WARN', colors.yellow, message, ...args);
  }

  info(message, ...args) {
    this.log('INFO', colors.green, message, ...args);
  }

  debug(message, ...args) {
    this.log('DEBUG', colors.blue, message, ...args);
  }

  // HTTP request logger
  http(req, res, responseTime) {
    const { method, url, ip } = req;
    const { statusCode } = res;
    const userAgent = req.get('User-Agent') || '';
    
    const color = statusCode >= 400 ? colors.red : 
                 statusCode >= 300 ? colors.yellow : colors.green;
    
    this.log('INFO', color, `${method} ${url} ${statusCode} ${responseTime}ms - ${ip} "${userAgent}"`);
  }
}

module.exports = new Logger();
