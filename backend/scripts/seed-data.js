require('dotenv').config();
const mongoose = require('mongoose');

// Import models
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

async function seedMoreDestinations() {
  try {
    const additionalDestinations = [
      // More airports
      { code: 'HPH', name: 'Sân bay Cát Bi', city: 'Hải Phòng', country: 'VN', type: 'airport', coordinates: { lat: 20.8197, lng: 106.7247 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      { code: 'HUI', name: 'Sân bay Phú Bài', city: 'Huế', country: 'VN', type: 'airport', coordinates: { lat: 16.4015, lng: 107.7026 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      { code: 'VCA', name: 'Sân bay Cần Thơ', city: 'Cần Thơ', country: 'VN', type: 'airport', coordinates: { lat: 10.0851, lng: 105.7117 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      { code: 'PQC', name: 'Sân bay Phú Quốc', city: 'Phú Quốc', country: 'VN', type: 'airport', coordinates: { lat: 10.2270, lng: 103.9678 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      { code: 'VDH', name: 'Sân bay Đồng Hới', city: 'Đồng Hới', country: 'VN', type: 'airport', coordinates: { lat: 17.5152, lng: 106.5897 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      
      // Train stations
      { code: 'DN_TRAIN', name: 'Ga Đà Nẵng', city: 'Đà Nẵng', country: 'VN', type: 'train_station', coordinates: { lat: 16.0678, lng: 108.2208 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      { code: 'HUE_TRAIN', name: 'Ga Huế', city: 'Huế', country: 'VN', type: 'train_station', coordinates: { lat: 16.4637, lng: 107.5909 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      { code: 'NT_TRAIN', name: 'Ga Nha Trang', city: 'Nha Trang', country: 'VN', type: 'train_station', coordinates: { lat: 12.2388, lng: 109.1967 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      
      // Bus stations
      { code: 'DN_BUS', name: 'Bến xe Đà Nẵng', city: 'Đà Nẵng', country: 'VN', type: 'bus_station', coordinates: { lat: 16.0544, lng: 108.2022 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      { code: 'NT_BUS', name: 'Bến xe Nha Trang', city: 'Nha Trang', country: 'VN', type: 'bus_station', coordinates: { lat: 12.2388, lng: 109.1967 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      { code: 'CT_BUS', name: 'Bến xe Cần Thơ', city: 'Cần Thơ', country: 'VN', type: 'bus_station', coordinates: { lat: 10.0452, lng: 105.7469 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      
      // Ferry ports
      { code: 'VT_FERRY', name: 'Cảng Vũng Tàu', city: 'Vũng Tàu', country: 'VN', type: 'port', coordinates: { lat: 10.3460, lng: 107.0843 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      { code: 'PQ_FERRY', name: 'Cảng Phú Quốc', city: 'Phú Quốc', country: 'VN', type: 'port', coordinates: { lat: 10.2899, lng: 103.9840 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true },
      { code: 'CM_FERRY', name: 'Cảng Cà Mau', city: 'Cà Mau', country: 'VN', type: 'port', coordinates: { lat: 9.1767, lng: 105.1524 }, timezone: 'Asia/Ho_Chi_Minh', isActive: true }
    ];

    // Check if destinations already exist
    const existingCodes = await Destination.find({}).distinct('code');
    const newDestinations = additionalDestinations.filter(dest => !existingCodes.includes(dest.code));
    
    if (newDestinations.length > 0) {
      await Destination.insertMany(newDestinations);
      logger.info(`Added ${newDestinations.length} new destinations`);
    } else {
      logger.info('All destinations already exist');
    }
  } catch (error) {
    logger.error(`Failed to seed destinations: ${error.message}`);
  }
}

async function seedMoreSchedules() {
  try {
    const destinations = await Destination.find({});
    const destMap = {};
    destinations.forEach(dest => {
      destMap[dest.code] = dest._id;
    });

    const today = new Date();
    const schedules = [];

    // Generate schedules for next 7 days
    for (let day = 1; day <= 7; day++) {
      const scheduleDate = new Date(today);
      scheduleDate.setDate(today.getDate() + day);
      scheduleDate.setHours(6, 0, 0, 0);

      // Flight schedules
      const flightRoutes = [
        { from: 'HAN', to: 'SGN', operator: 'Vietnam Airlines', code: 'VN', duration: 120, price: 1430000 },
        { from: 'SGN', to: 'HAN', operator: 'VietJet Air', code: 'VJ', duration: 120, price: 1250000 },
        { from: 'HAN', to: 'DAD', operator: 'Bamboo Airways', code: 'QH', duration: 80, price: 980000 },
        { from: 'DAD', to: 'HAN', operator: 'Vietnam Airlines', code: 'VN', duration: 80, price: 1050000 },
        { from: 'SGN', to: 'DAD', operator: 'VietJet Air', code: 'VJ', duration: 75, price: 890000 },
        { from: 'DAD', to: 'SGN', operator: 'Jetstar Pacific', code: 'BL', duration: 75, price: 850000 }
      ];

      flightRoutes.forEach((route, index) => {
        if (destMap[route.from] && destMap[route.to]) {
          const departureTime = new Date(scheduleDate.getTime() + (index * 2 + 6) * 60 * 60 * 1000);
          const arrivalTime = new Date(departureTime.getTime() + route.duration * 60 * 1000);

          schedules.push({
            routeId: new mongoose.Types.ObjectId(),
            operatorId: new mongoose.Types.ObjectId(),
            operatorName: route.operator,
            operatorCode: route.code,
            vehicleNumber: `${route.code}-A${Math.floor(Math.random() * 999)}`,
            transportType: 'flight',
            from: destMap[route.from],
            to: destMap[route.to],
            departureTime,
            arrivalTime,
            duration: route.duration,
            vehicle: {
              type: 'aircraft',
              model: 'Airbus A321',
              registrationNumber: `${route.code}-A${Math.floor(Math.random() * 999)}`,
              facilities: ['WiFi', 'Entertainment', 'Meals']
            },
            seatConfiguration: {
              totalSeats: 180,
              availableSeats: Math.floor(Math.random() * 50) + 130,
              layout: '3-3',
              classes: new Map([
                ['economy', {
                  totalSeats: 150,
                  availableSeats: Math.floor(Math.random() * 30) + 120,
                  price: route.price,
                  currency: 'VND',
                  amenities: ['Meal', 'Baggage 20kg']
                }],
                ['business', {
                  totalSeats: 30,
                  availableSeats: Math.floor(Math.random() * 10) + 20,
                  price: route.price * 2.2,
                  currency: 'VND',
                  amenities: ['Premium Meal', 'Baggage 30kg', 'Lounge Access']
                }]
              ])
            },
            status: 'scheduled',
            bookingDeadline: new Date(departureTime.getTime() - 2 * 60 * 60 * 1000),
            cancellationPolicy: {
              refundable: true,
              cancellationFee: Math.floor(route.price * 0.1),
              timeLimit: 24
            }
          });
        }
      });
    }

    if (schedules.length > 0) {
      await Schedule.insertMany(schedules);
      logger.info(`Created ${schedules.length} additional schedules`);
    }
  } catch (error) {
    logger.error(`Failed to seed schedules: ${error.message}`);
  }
}

async function seedDatabase() {
  try {
    logger.info('Starting additional data seeding...');
    
    await connectDB();
    await seedMoreDestinations();
    await seedMoreSchedules();
    
    logger.info('Additional data seeding completed!');
    
    // Display summary
    const destinationCount = await Destination.countDocuments();
    const scheduleCount = await Schedule.countDocuments();
    
    console.log('\n📊 Updated Database Summary:');
    console.log(`📍 Total Destinations: ${destinationCount}`);
    console.log(`🚀 Total Schedules: ${scheduleCount}`);
    
  } catch (error) {
    logger.error(`Data seeding failed: ${error.message}`);
  } finally {
    await mongoose.connection.close();
    logger.info('Database connection closed');
    process.exit(0);
  }
}

// Run seeding
if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase };
