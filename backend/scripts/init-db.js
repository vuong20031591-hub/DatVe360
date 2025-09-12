require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Import models
const User = require('../src/models/User');
const Destination = require('../src/models/Destination');
const Schedule = require('../src/models/Schedule');

const logger = {
  info: (msg) => console.log(`✅ ${msg}`),
  error: (msg) => console.log(`❌ ${msg}`),
  warn: (msg) => console.log(`⚠️ ${msg}`)
};

async function connectDB() {
  try {
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/datve360';
    await mongoose.connect(mongoURI);
    logger.info('Connected to MongoDB');
  } catch (error) {
    logger.error(`Database connection failed: ${error.message}`);
    process.exit(1);
  }
}

async function clearDatabase() {
  try {
    await User.deleteMany({});
    await Destination.deleteMany({});
    await Schedule.deleteMany({});
    logger.info('Cleared existing data');
  } catch (error) {
    logger.error(`Failed to clear database: ${error.message}`);
  }
}

async function createUsers() {
  try {
    const users = [
      {
        email: 'admin@datve360.com',
        password: await bcrypt.hash('123456', 12),
        displayName: 'Admin DatVe360',
        role: 'admin',
        isVerified: true,
        isActive: true,
        preferences: {
          language: 'vi',
          currency: 'VND'
        }
      },
      {
        email: 'operator@datve360.com',
        password: await bcrypt.hash('123456', 12),
        displayName: 'Operator DatVe360',
        role: 'operator',
        isVerified: true,
        isActive: true,
        preferences: {
          language: 'vi',
          currency: 'VND'
        }
      },
      {
        email: 'user@example.com',
        password: await bcrypt.hash('123456', 12),
        displayName: 'Nguyen Van A',
        phoneNumber: '0901234567',
        role: 'user',
        isVerified: true,
        isActive: true,
        profile: {
          firstName: 'Van A',
          lastName: 'Nguyen',
          gender: 'male',
          nationality: 'VN'
        },
        preferences: {
          language: 'vi',
          currency: 'VND'
        }
      }
    ];

    await User.insertMany(users);
    logger.info(`Created ${users.length} users`);
  } catch (error) {
    logger.error(`Failed to create users: ${error.message}`);
  }
}

async function createDestinations() {
  try {
    const destinations = [
      // Airports
      {
        code: 'HAN',
        name: 'Sân bay Nội Bài',
        city: 'Hà Nội',
        country: 'VN',
        type: 'airport',
        coordinates: { lat: 21.2187, lng: 105.8042 },
        timezone: 'Asia/Ho_Chi_Minh',
        isActive: true
      },
      {
        code: 'SGN',
        name: 'Sân bay Tân Sơn Nhất',
        city: 'TP.HCM',
        country: 'VN',
        type: 'airport',
        coordinates: { lat: 10.8188, lng: 106.6519 },
        timezone: 'Asia/Ho_Chi_Minh',
        isActive: true
      },
      {
        code: 'DAD',
        name: 'Sân bay Đà Nẵng',
        city: 'Đà Nẵng',
        country: 'VN',
        type: 'airport',
        coordinates: { lat: 16.0544, lng: 108.2022 },
        timezone: 'Asia/Ho_Chi_Minh',
        isActive: true
      },
      {
        code: 'CXR',
        name: 'Sân bay Cam Ranh',
        city: 'Nha Trang',
        country: 'VN',
        type: 'airport',
        coordinates: { lat: 11.9982, lng: 109.2194 },
        timezone: 'Asia/Ho_Chi_Minh',
        isActive: true
      },
      // Train stations
      {
        code: 'HN_TRAIN',
        name: 'Ga Hà Nội',
        city: 'Hà Nội',
        country: 'VN',
        type: 'train_station',
        coordinates: { lat: 21.0245, lng: 105.8412 },
        timezone: 'Asia/Ho_Chi_Minh',
        isActive: true
      },
      {
        code: 'SGN_TRAIN',
        name: 'Ga Sài Gòn',
        city: 'TP.HCM',
        country: 'VN',
        type: 'train_station',
        coordinates: { lat: 10.7821, lng: 106.6769 },
        timezone: 'Asia/Ho_Chi_Minh',
        isActive: true
      },
      // Bus stations
      {
        code: 'HN_BUS',
        name: 'Bến xe Mỹ Đình',
        city: 'Hà Nội',
        country: 'VN',
        type: 'bus_station',
        coordinates: { lat: 21.0278, lng: 105.7789 },
        timezone: 'Asia/Ho_Chi_Minh',
        isActive: true
      },
      {
        code: 'SGN_BUS',
        name: 'Bến xe Miền Đông',
        city: 'TP.HCM',
        country: 'VN',
        type: 'bus_station',
        coordinates: { lat: 10.8142, lng: 106.7317 },
        timezone: 'Asia/Ho_Chi_Minh',
        isActive: true
      }
    ];

    await Destination.insertMany(destinations);
    logger.info(`Created ${destinations.length} destinations`);
  } catch (error) {
    logger.error(`Failed to create destinations: ${error.message}`);
  }
}

async function createSampleSchedules() {
  try {
    const destinations = await Destination.find({});
    const hanAirport = destinations.find(d => d.code === 'HAN');
    const sgnAirport = destinations.find(d => d.code === 'SGN');
    const dadAirport = destinations.find(d => d.code === 'DAD');

    if (!hanAirport || !sgnAirport || !dadAirport) {
      logger.warn('Missing required destinations for schedules');
      return;
    }

    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(6, 0, 0, 0);

    const schedules = [
      // Flight HAN -> SGN
      {
        routeId: new mongoose.Types.ObjectId(),
        operatorId: new mongoose.Types.ObjectId(),
        operatorName: 'Vietnam Airlines',
        operatorCode: 'VN',
        vehicleNumber: 'VN-A123',
        transportType: 'flight',
        from: hanAirport._id,
        to: sgnAirport._id,
        departureTime: new Date(tomorrow.getTime()),
        arrivalTime: new Date(tomorrow.getTime() + 2 * 60 * 60 * 1000), // +2h
        duration: 120, // minutes
        vehicle: {
          type: 'aircraft',
          model: 'Airbus A321',
          registrationNumber: 'VN-A123',
          facilities: ['WiFi', 'Entertainment', 'Meals']
        },
        seatConfiguration: {
          totalSeats: 180,
          availableSeats: 150,
          layout: '3-3',
          classes: new Map([
            ['economy', {
              totalSeats: 150,
              availableSeats: 130,
              price: 1430000,
              currency: 'VND',
              amenities: ['Meal', 'Baggage 20kg']
            }],
            ['business', {
              totalSeats: 30,
              availableSeats: 20,
              price: 3200000,
              currency: 'VND',
              amenities: ['Premium Meal', 'Baggage 30kg', 'Lounge Access']
            }]
          ])
        },
        status: 'scheduled',
        bookingDeadline: new Date(tomorrow.getTime() - 2 * 60 * 60 * 1000), // 2h before
        cancellationPolicy: {
          refundable: true,
          cancellationFee: 200000,
          timeLimit: 24
        }
      },
      // Flight SGN -> HAN
      {
        routeId: new mongoose.Types.ObjectId(),
        operatorId: new mongoose.Types.ObjectId(),
        operatorName: 'VietJet Air',
        operatorCode: 'VJ',
        vehicleNumber: 'VJ-A456',
        transportType: 'flight',
        from: sgnAirport._id,
        to: hanAirport._id,
        departureTime: new Date(tomorrow.getTime() + 4 * 60 * 60 * 1000), // +4h
        arrivalTime: new Date(tomorrow.getTime() + 6 * 60 * 60 * 1000), // +6h
        duration: 120,
        vehicle: {
          type: 'aircraft',
          model: 'Airbus A320',
          registrationNumber: 'VN-A456',
          facilities: ['WiFi', 'Entertainment']
        },
        seatConfiguration: {
          totalSeats: 180,
          availableSeats: 160,
          layout: '3-3',
          classes: new Map([
            ['economy', {
              totalSeats: 180,
              availableSeats: 160,
              price: 1250000,
              currency: 'VND',
              amenities: ['Baggage 20kg']
            }]
          ])
        },
        status: 'scheduled',
        bookingDeadline: new Date(tomorrow.getTime() + 2 * 60 * 60 * 1000),
        cancellationPolicy: {
          refundable: true,
          cancellationFee: 150000,
          timeLimit: 24
        }
      }
    ];

    await Schedule.insertMany(schedules);
    logger.info(`Created ${schedules.length} sample schedules`);
  } catch (error) {
    logger.error(`Failed to create schedules: ${error.message}`);
  }
}

async function initializeDatabase() {
  try {
    logger.info('Starting database initialization...');

    await connectDB();
    await clearDatabase();
    await createUsers();
    await createDestinations();
    await createSampleSchedules();

    logger.info('Database initialization completed successfully!');

    // Display summary
    const userCount = await User.countDocuments();
    const destinationCount = await Destination.countDocuments();
    const scheduleCount = await Schedule.countDocuments();

    console.log('\n📊 Database Summary:');
    console.log(`👥 Users: ${userCount}`);
    console.log(`📍 Destinations: ${destinationCount}`);
    console.log(`🚀 Schedules: ${scheduleCount}`);

    console.log('\n🔑 Test Accounts:');
    console.log('Admin: admin@datve360.com / 123456');
    console.log('Operator: operator@datve360.com / 123456');
    console.log('User: user@example.com / 123456');

  } catch (error) {
    logger.error(`Database initialization failed: ${error.message}`);
  } finally {
    await mongoose.connection.close();
    logger.info('Database connection closed');
    process.exit(0);
  }
}

// Run initialization
if (require.main === module) {
  initializeDatabase();
}

module.exports = { initializeDatabase };
