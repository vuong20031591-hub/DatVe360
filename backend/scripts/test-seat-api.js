const axios = require('axios');
const mongoose = require('mongoose');
require('dotenv').config();

const API_BASE = 'http://localhost:3000/api/v1';

async function testSeatAPI() {
  try {
    console.log('🔍 Testing Seat API with new train structure...\n');

    // Connect to MongoDB to get a train schedule ID
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/datve360');
    console.log('✅ Connected to MongoDB\n');

    // Find a train schedule
    const Schedule = mongoose.model('Schedule', new mongoose.Schema({}, { strict: false }));
    const trainSchedule = await Schedule.findOne({ transportType: 'train' }).lean();

    if (!trainSchedule) {
      console.log('❌ No train schedule found in database');
      process.exit(1);
    }

    console.log('📋 Found train schedule:');
    console.log(`   ID: ${trainSchedule._id}`);
    console.log(`   Route: ${trainSchedule.vehicleNumber || 'N/A'}`);
    console.log(`   Seat Config:`, JSON.stringify(trainSchedule.seatConfiguration, null, 2));
    console.log('');

    // Test seat map API
    console.log('🚀 Calling seat map API...');
    const response = await axios.get(`${API_BASE}/seats/schedule/${trainSchedule._id}`);

    if (response.data.success) {
      console.log('✅ API Response successful!\n');
      
      const { data } = response.data;
      console.log('📊 Seat Map Summary:');
      console.log(`   Transport Type: ${data.transportType}`);
      console.log(`   Layout: ${data.layout}`);
      console.log(`   Total Seats: ${data.totalSeats}`);
      console.log(`   Available Seats: ${data.availableSeats}`);
      console.log('');

      if (data.seatMap && Array.isArray(data.seatMap)) {
        console.log(`📦 Total Coaches: ${data.seatMap.length}`);
        console.log('');

        // Show first 3 coaches
        data.seatMap.slice(0, 3).forEach((coach, coachIndex) => {
          console.log(`🚂 Coach ${coach.coachNumber || coachIndex + 1}:`);
          console.log(`   Compartments: ${coach.compartments?.length || 0}`);
          
          if (coach.compartments && coach.compartments.length > 0) {
            // Show first 2 compartments
            coach.compartments.slice(0, 2).forEach((comp, compIndex) => {
              console.log(`   └─ Compartment ${comp.compartmentNumber || compIndex + 1}:`);
              console.log(`      Left Berths: ${comp.leftBerths?.map(b => b.id).join(', ') || 'N/A'}`);
              console.log(`      Right Berths: ${comp.rightBerths?.map(b => b.id).join(', ') || 'N/A'}`);
            });
            
            if (coach.compartments.length > 2) {
              console.log(`   └─ ... and ${coach.compartments.length - 2} more compartments`);
            }
          }
          console.log('');
        });

        if (data.seatMap.length > 3) {
          console.log(`... and ${data.seatMap.length - 3} more coaches\n`);
        }

        // Verify seat ID format
        const firstCoach = data.seatMap[0];
        if (firstCoach && firstCoach.compartments && firstCoach.compartments[0]) {
          const firstComp = firstCoach.compartments[0];
          const sampleSeat = firstComp.leftBerths?.[0] || firstComp.rightBerths?.[0];
          
          if (sampleSeat) {
            console.log('✅ Seat ID Format Verification:');
            console.log(`   Sample Seat ID: ${sampleSeat.id}`);
            console.log(`   Expected Format: C{coach}{compartment}-{position}`);
            console.log(`   Example: C101-L1 (Coach 1, Compartment 01, Left berth 1)`);
            
            // Check if format matches
            const formatMatch = /^C\d{2,3}-[LR]\d$/.test(sampleSeat.id);
            console.log(`   Format Valid: ${formatMatch ? '✅ YES' : '❌ NO'}`);
            console.log('');
          }
        }

        // Count total seats
        let totalSeatsInMap = 0;
        data.seatMap.forEach(coach => {
          coach.compartments?.forEach(comp => {
            totalSeatsInMap += (comp.leftBerths?.length || 0) + (comp.rightBerths?.length || 0);
          });
        });
        
        console.log('📈 Statistics:');
        console.log(`   Total Seats in Map: ${totalSeatsInMap}`);
        console.log(`   Expected Total: ${data.totalSeats}`);
        console.log(`   Match: ${totalSeatsInMap === data.totalSeats ? '✅ YES' : '❌ NO'}`);
        console.log('');

      } else {
        console.log('⚠️  Seat map is not in expected format (array of coaches)');
        console.log('   Actual format:', typeof data.seatMap);
      }

    } else {
      console.log('❌ API Response failed:', response.data.message);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.response) {
      console.error('   Status:', error.response.status);
      console.error('   Data:', error.response.data);
    }
  } finally {
    await mongoose.connection.close();
    console.log('\n✅ MongoDB connection closed');
  }
}

testSeatAPI();

