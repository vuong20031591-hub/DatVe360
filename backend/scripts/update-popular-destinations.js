/**
 * Script to update popular destinations with images
 * Run: node backend/scripts/update-popular-destinations.js
 */

require('dotenv').config();
const mongoose = require('mongoose');
const Destination = require('../src/models/Destination');

// Popular destination codes and their image URLs
const popularDestinations = [
  // Airports (Sân bay)
  { code: 'HAN', imageUrl: 'https://images.unsplash.com/photo-1509023464722-18d996393ca8?w=800' }, // Hà Nội
  { code: 'SGN', imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800' }, // TP.HCM
  { code: 'DAD', imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800' }, // Đà Nẵng
  { code: 'CXR', imageUrl: 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800' }, // Nha Trang
  { code: 'DLI', imageUrl: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800' }, // Đà Lạt
  { code: 'PQC', imageUrl: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800' }, // Phú Quốc
  
  // Bus Stations (Bến xe)
  { code: 'HN_BUS_MD', imageUrl: 'https://images.unsplash.com/photo-1509023464722-18d996393ca8?w=800' }, // Mỹ Đình
  { code: 'SGN_BUS_MD', imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800' }, // Miền Đông
  { code: 'SGN_BUS_MT', imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800' }, // Miền Tây
  { code: 'DN_BUS', imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800' }, // Đà Nẵng
  
  // Train Stations (Ga tàu)
  { code: 'HN_TRAIN', imageUrl: 'https://images.unsplash.com/photo-1509023464722-18d996393ca8?w=800' }, // Hà Nội
  { code: 'SGN_TRAIN', imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800' }, // Sài Gòn
  { code: 'DN_TRAIN', imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800' }, // Đà Nẵng
];

async function updatePopularDestinations() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // Reset all destinations to not popular
    console.log('Resetting all destinations to popular=false...');
    await Destination.updateMany({}, { popular: false });
    console.log('✅ Reset complete\n');

    // Update popular destinations
    let updated = 0;
    let notFound = 0;

    console.log('Updating popular destinations...\n');
    for (const dest of popularDestinations) {
      const result = await Destination.findOneAndUpdate(
        { code: dest.code },
        { 
          popular: true,
          imageUrl: dest.imageUrl
        },
        { new: true }
      );

      if (result) {
        console.log(`✅ ${result.name} (${result.code}) - ${result.city}`);
        updated++;
      } else {
        console.log(`❌ Not found: ${dest.code}`);
        notFound++;
      }
    }

    console.log(`\n📊 Summary:`);
    console.log(`   Updated: ${updated}`);
    console.log(`   Not found: ${notFound}`);
    console.log(`   Total: ${popularDestinations.length}`);

    // Display updated popular destinations
    console.log('\n🌟 Popular Destinations:');
    const popular = await Destination.find({ popular: true })
      .select('name code city type imageUrl')
      .sort({ city: 1, name: 1 });
    
    popular.forEach(dest => {
      console.log(`   - ${dest.name} (${dest.code}) - ${dest.city} [${dest.type}]`);
    });

    await mongoose.disconnect();
    console.log('\n✅ Script completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

updatePopularDestinations();
