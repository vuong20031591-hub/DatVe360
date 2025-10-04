const mongoose = require('mongoose');
const Trip = require('./src/models/Trip');
require('dotenv').config();

const clearTrips = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/datve360');
    console.log('Connected to MongoDB');

    const result = await Trip.deleteMany({});
    console.log(`Deleted ${result.deletedCount} trips`);

    await mongoose.disconnect();
    console.log('Done!');
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
};

clearTrips();

