const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'DatVe360 API Documentation',
      version: '1.0.0',
      description: 'API documentation for DatVe360 - Multi-modal Transportation Booking Platform',
      contact: {
        name: 'DatVe360 Team',
        email: 'support@datve360.com',
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT',
      },
    },
    servers: [
      {
        url: `http://localhost:${process.env.PORT || 5000}/api/${process.env.API_VERSION || 'v1'}`,
        description: 'Development server',
      },
      {
        url: `http://192.168.100.245:${process.env.PORT || 5000}/api/${process.env.API_VERSION || 'v1'}`,
        description: 'Local network server',
      },
      {
        url: `http://10.0.2.2:${process.env.PORT || 5000}/api/${process.env.API_VERSION || 'v1'}`,
        description: 'Android emulator server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Enter your JWT token',
        },
      },
      schemas: {
        User: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              description: 'User ID',
            },
            email: {
              type: 'string',
              format: 'email',
              description: 'User email address',
            },
            displayName: {
              type: 'string',
              description: 'User display name',
            },
            phoneNumber: {
              type: 'string',
              description: 'User phone number',
            },
            role: {
              type: 'string',
              enum: ['user', 'admin', 'operator'],
              description: 'User role',
            },
            isVerified: {
              type: 'boolean',
              description: 'Email verification status',
            },
            photoURL: {
              type: 'string',
              description: 'User profile photo URL',
            },
          },
        },
        Booking: {
          type: 'object',
          properties: {
            bookingId: {
              type: 'string',
              description: 'Unique booking ID',
            },
            pnr: {
              type: 'string',
              description: 'Passenger Name Record',
            },
            status: {
              type: 'string',
              enum: ['pending', 'confirmed', 'cancelled', 'completed'],
              description: 'Booking status',
            },
            totalPrice: {
              type: 'number',
              description: 'Total booking price',
            },
            paymentStatus: {
              type: 'string',
              enum: ['pending', 'paid', 'failed', 'refunded'],
              description: 'Payment status',
            },
          },
        },
        Schedule: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              description: 'Schedule ID',
            },
            transportType: {
              type: 'string',
              enum: ['flight', 'train', 'bus', 'ferry'],
              description: 'Type of transportation',
            },
            departureTime: {
              type: 'string',
              format: 'date-time',
              description: 'Departure time',
            },
            arrivalTime: {
              type: 'string',
              format: 'date-time',
              description: 'Arrival time',
            },
            price: {
              type: 'number',
              description: 'Base price',
            },
          },
        },
        Error: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              example: false,
            },
            message: {
              type: 'string',
              description: 'Error message',
            },
            error: {
              type: 'string',
              description: 'Error details',
            },
          },
        },
        SuccessResponse: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              example: true,
            },
            message: {
              type: 'string',
              description: 'Success message',
            },
            data: {
              type: 'object',
              description: 'Response data',
            },
          },
        },
      },
      responses: {
        UnauthorizedError: {
          description: 'Access token is missing or invalid',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error',
              },
            },
          },
        },
        NotFoundError: {
          description: 'Resource not found',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error',
              },
            },
          },
        },
        ValidationError: {
          description: 'Validation error',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error',
              },
            },
          },
        },
      },
    },
    tags: [
      {
        name: 'Authentication',
        description: 'User authentication and authorization',
      },
      {
        name: 'Bookings',
        description: 'Booking management',
      },
      {
        name: 'Schedules',
        description: 'Schedule search and management',
      },
      {
        name: 'Payments',
        description: 'Payment processing',
      },
      {
        name: 'Tickets',
        description: 'Ticket management',
      },
      {
        name: 'Destinations',
        description: 'Destination information',
      },
      {
        name: 'Admin',
        description: 'Admin operations',
      },
    ],
  },
  apis: [
    './src/routes/*.js',
    './src/routes/admin/*.js',
    './src/models/*.js',
  ],
};

const swaggerSpec = swaggerJsdoc(options);

module.exports = swaggerSpec;

