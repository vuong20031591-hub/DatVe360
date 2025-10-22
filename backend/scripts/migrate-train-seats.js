const mongoose = require('mongoose');
require('dotenv').config();

/**
 * Migration Script: Update Train Seats to New Structure
 * 
 * Old format: C1-L1, C2-L1, ..., C100-R2 (100 compartments continuous)
 * New format: C101-L1, C102-L1, ..., C1010-R2 (10 coaches × 10 compartments)
 * 
 * This script:
 * 1. Finds all train seats with old format (C{1-3 digits}-{position})
 * 2. Parses compartment number and calculates coach number
 * 3. Updates seatNumber, coachNumber, and compartmentNumber
 */

async function migrateSeatStructure() {
  try {
    console.log('🔄 Starting train seat migration...\n');

    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/datve360');
    console.log('✅ Connected to MongoDB\n');

    // Define Seat model
    const Seat = mongoose.model('Seat', new mongoose.Schema({}, { strict: false }));

    // Find all seats (we'll filter train seats by checking seatNumber pattern)
    const allSeats = await Seat.find({}).lean();
    console.log(`📊 Total seats in database: ${allSeats.length}\n`);

    // Filter train seats with old format: C{number}-{position}
    // Old format: C1-L1, C2-L1, ..., C100-R2
    // New format should be: C101-L1, C102-L1, ..., C1010-R2
    const oldFormatPattern = /^C(\d{1,2})-([LR]\d)$/; // C1-L1 to C99-R2
    const newFormatPattern = /^C(\d{3})-([LR]\d)$/;   // C101-L1 to C999-R2

    const seatsToMigrate = allSeats.filter(seat => {
      if (!seat.seatNumber) return false;
      
      // Check if it matches old format (1-2 digits)
      const oldMatch = oldFormatPattern.test(seat.seatNumber);
      
      // Also check if it's missing coachNumber/compartmentNumber
      const missingFields = !seat.coachNumber || !seat.compartmentNumber;
      
      return oldMatch || (missingFields && /^C\d+-[LR]\d$/.test(seat.seatNumber));
    });

    console.log(`🔍 Found ${seatsToMigrate.length} seats to migrate\n`);

    if (seatsToMigrate.length === 0) {
      console.log('✅ No seats need migration. All seats are already in new format.\n');
      return;
    }

    // Group seats by tripId to process per trip
    const seatsByTrip = {};
    seatsToMigrate.forEach(seat => {
      const tripId = seat.tripId.toString();
      if (!seatsByTrip[tripId]) {
        seatsByTrip[tripId] = [];
      }
      seatsByTrip[tripId].push(seat);
    });

    console.log(`📦 Seats grouped into ${Object.keys(seatsByTrip).length} trips\n`);

    let totalUpdated = 0;
    let totalErrors = 0;

    // Process each trip
    for (const [tripId, seats] of Object.entries(seatsByTrip)) {
      console.log(`\n🚂 Processing trip ${tripId} (${seats.length} seats)...`);

      const updates = [];

      for (const seat of seats) {
        try {
          // Parse old seat number
          const match = seat.seatNumber.match(/^C(\d+)-([LR]\d)$/);
          if (!match) {
            console.log(`   ⚠️  Skipping invalid format: ${seat.seatNumber}`);
            continue;
          }

          const oldCompartmentNum = parseInt(match[1]);
          const position = match[2];

          // Calculate new structure
          // Assuming 10 compartments per coach
          const compartmentsPerCoach = 10;
          const coachNumber = Math.ceil(oldCompartmentNum / compartmentsPerCoach);
          const compartmentNumber = ((oldCompartmentNum - 1) % compartmentsPerCoach) + 1;

          // Generate new seat number: C{coach}{compartment}-{position}
          // Example: C1-L1 → C101-L1 (Coach 1, Compartment 01)
          //          C15-R2 → C205-R2 (Coach 2, Compartment 05)
          const compartmentPadded = compartmentNumber.toString().padStart(2, '0');
          const newSeatNumber = `C${coachNumber}${compartmentPadded}-${position}`;

          updates.push({
            updateOne: {
              filter: { _id: seat._id },
              update: {
                $set: {
                  seatNumber: newSeatNumber,
                  coachNumber: coachNumber,
                  compartmentNumber: compartmentNumber
                }
              }
            }
          });

          if (updates.length <= 5) {
            console.log(`   ✓ ${seat.seatNumber} → ${newSeatNumber} (Coach ${coachNumber}, Comp ${compartmentNumber})`);
          }

        } catch (error) {
          console.error(`   ❌ Error processing seat ${seat.seatNumber}:`, error.message);
          totalErrors++;
        }
      }

      if (updates.length > 5) {
        console.log(`   ... and ${updates.length - 5} more seats`);
      }

      // Execute bulk update
      if (updates.length > 0) {
        const result = await Seat.bulkWrite(updates);
        totalUpdated += result.modifiedCount;
        console.log(`   ✅ Updated ${result.modifiedCount} seats`);
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log('📊 Migration Summary:');
    console.log(`   Total seats processed: ${seatsToMigrate.length}`);
    console.log(`   Successfully updated: ${totalUpdated}`);
    console.log(`   Errors: ${totalErrors}`);
    console.log('='.repeat(60) + '\n');

    // Verify migration
    console.log('🔍 Verifying migration...\n');
    
    const remainingOldFormat = await Seat.countDocuments({
      seatNumber: { $regex: /^C\d{1,2}-[LR]\d$/ }
    });

    const newFormatCount = await Seat.countDocuments({
      seatNumber: { $regex: /^C\d{3}-[LR]\d$/ }
    });

    console.log(`   Old format remaining: ${remainingOldFormat}`);
    console.log(`   New format count: ${newFormatCount}`);

    if (remainingOldFormat === 0) {
      console.log('\n✅ Migration completed successfully! All seats are in new format.\n');
    } else {
      console.log('\n⚠️  Some seats still in old format. Please review manually.\n');
    }

  } catch (error) {
    console.error('❌ Migration failed:', error);
    throw error;
  } finally {
    await mongoose.connection.close();
    console.log('✅ MongoDB connection closed\n');
  }
}

// Run migration
if (require.main === module) {
  migrateSeatStructure()
    .then(() => {
      console.log('✅ Migration script completed');
      process.exit(0);
    })
    .catch((error) => {
      console.error('❌ Migration script failed:', error);
      process.exit(1);
    });
}

module.exports = { migrateSeatStructure };

