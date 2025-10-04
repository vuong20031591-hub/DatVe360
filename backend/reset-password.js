const mongoose = require('mongoose');
const User = require('./src/models/User');
require('dotenv').config();

const resetPassword = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/datve360');
    console.log('Connected to MongoDB');

    // Find user
    const email = 'ntv@gmail.com';
    const newPassword = '123456';
    
    const user = await User.findOne({ email });
    
    if (!user) {
      console.log('User not found:', email);
      process.exit(1);
    }

    console.log('User found:', user.email);
    console.log('Current password:', user.password ? 'EXISTS' : 'MISSING');

    // Update password
    user.password = newPassword;
    await user.save();

    console.log('Password updated successfully!');
    console.log('Email:', email);
    console.log('New password:', newPassword);

    await mongoose.disconnect();
    console.log('Done!');
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
};

resetPassword();

