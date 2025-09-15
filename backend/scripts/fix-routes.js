require('dotenv').config();
const mongoose = require('mongoose');

// Import models
const Destination = require('../src/models/Destination');
const Route = require('../src/models/Route');
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

async function createRoutes() {
  try {
    // Get all destinations
    const destinations = await Destination.find({});
    const destMap = {};
    destinations.forEach(dest => {
      destMap[dest.code] = dest._id;
    });

    // Define route data
    const routeData = [
      // Flight routes
      { from: 'HAN', to: 'SGN', type: 'flight', distance: 1166, duration: 120 },
      { from: 'SGN', to: 'HAN', type: 'flight', distance: 1166, duration: 120 },
      { from: 'HAN', to: 'DAD', type: 'flight', distance: 608, duration: 80 },
      { from: 'DAD', to: 'HAN', type: 'flight', distance: 608, duration: 80 },
      { from: 'SGN', to: 'DAD', type: 'flight', distance: 608, duration: 75 },
      { from: 'DAD', to: 'SGN', type: 'flight', distance: 608, duration: 75 },
      
      // Train routes
      { from: 'HAN', to: 'SGN', type: 'train', distance: 1726, duration: 1800 }, // 30 hours
      { from: 'SGN', to: 'HAN', type: 'train', distance: 1726, duration: 1800 },
      { from: 'HAN', to: 'DAD', type: 'train', distance: 791, duration: 900 }, // 15 hours
      { from: 'DAD', to: 'HAN', type: 'train', distance: 791, duration: 900 },
      
      // Bus routes
      { from: 'HAN', to: 'SGN', type: 'bus', distance: 1726, duration: 1440 }, // 24 hours
      { from: 'SGN', to: 'HAN', type: 'bus', distance: 1726, duration: 1440 },
      { from: 'HAN', to: 'DAD', type: 'bus', distance: 791, duration: 720 }, // 12 hours
      { from: 'DAD', to: 'HAN', type: 'bus', distance: 791, duration: 720 },
      { from: 'SGN', to: 'DAD', type: 'bus', distance: 964, duration: 840 }, // 14 hours
      { from: 'DAD', to: 'SGN', type: 'bus', distance: 964, duration: 840 },
    ];

    const routes = [];
    for (const route of routeData) {
      if (destMap[route.from] && destMap[route.to]) {
        routes.push({
          fromDestination: destMap[route.from],
          toDestination: destMap[route.to],
          transportType: route.type,
          distance: route.distance,
          estimatedDuration: route.duration,
          isActive: true
        });
      }
    }

    // Clear existing routes and create new ones
    await Route.deleteMany({});
    const createdRoutes = await Route.insertMany(routes);
    logger.info(`Created ${createdRoutes.length} routes`);

    return createdRoutes;
  } catch (error) {
    logger.error(`Failed to create routes: ${error.message}`);
    throw error;
  }
}

async function updateSchedules() {
  try {
    // Get all routes
    const routes = await Route.find({}).populate('fromDestination toDestination');
    const routeMap = {};
    
    routes.forEach(route => {
      const key = `${route.fromDestination.code}-${route.toDestination.code}-${route.transportType}`;
      routeMap[key] = route._id;
    });

    // Get all schedules
    const schedules = await Schedule.find({});
    logger.info(`Found ${schedules.length} schedules to update`);

    let updatedCount = 0;
    for (const schedule of schedules) {
      // Try to match schedule with route based on operator and transport type
      let transportType = 'flight'; // default
      
      if (schedule.operatorCode) {
        if (['VN', 'VJ', 'QH', 'BL'].includes(schedule.operatorCode)) {
          transportType = 'flight';
        } else if (['SE'].includes(schedule.operatorCode)) {
          transportType = 'train';
        } else if (['FUTA', 'HOANG_LONG'].includes(schedule.operatorCode)) {
          transportType = 'bus';
        }
      }

      // For now, assume all existing schedules are HAN-SGN flights
      const routeKey = `HAN-SGN-${transportType}`;
      if (routeMap[routeKey]) {
        await Schedule.updateOne(
          { _id: schedule._id },
          { routeId: routeMap[routeKey] }
        );
        updatedCount++;
      }
    }

    logger.info(`Updated ${updatedCount} schedules with proper route references`);
  } catch (error) {
    logger.error(`Failed to update schedules: ${error.message}`);
    throw error;
  }
}

async function fixRoutes() {
  try {
    logger.info('Starting route fix process...');
    
    await connectDB();
    await createRoutes();
    await updateSchedules();
    
    logger.info('Route fix completed!');
    
    // Display summary
    const routeCount = await Route.countDocuments();
    const scheduleCount = await Schedule.countDocuments();
    
    console.log('\n📊 Updated Database Summary:');
    console.log(`🛣️ Total Routes: ${routeCount}`);
    console.log(`🚀 Total Schedules: ${scheduleCount}`);
    
  } catch (error) {
    logger.error(`Route fix failed: ${error.message}`);
  } finally {
    await mongoose.connection.close();
    logger.info('Database connection closed');
  }
}

// Run the fix
fixRoutes();
