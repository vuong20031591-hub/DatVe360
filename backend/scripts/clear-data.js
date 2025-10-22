require('dotenv').config();
const mongoose = require('mongoose');

const Destination = require('../src/models/Destination');
const Schedule = require('../src/models/Schedule');

async function clearData() {
  try {
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/datve360';
    await mongoose.connect(mongoURI);
    console.log('✅ Connected to MongoDB');
    
    const destResult = await Destination.deleteMany({});
    console.log(`✅ Deleted ${destResult.deletedCount} destinations`);
    
    const schedResult = await Schedule.deleteMany({});
    console.log(`✅ Deleted ${schedResult.deletedCount} schedules`);
    
    console.log('✅ Data cleared successfully!');
  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
  } finally {
    await mongoose.connection.close();
    console.log('✅ Database connection closed');
    process.exit(0);
  }
}

clearData();

