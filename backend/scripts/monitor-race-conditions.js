/**
 * Race Condition Monitoring Script
 * 
 * Monitors và report các race condition attempts trong production:
 * 1. Booking conflicts (409 errors)
 * 2. Payment duplicates
 * 3. Cancellation conflicts
 * 4. Schedule update conflicts
 * 
 * Usage: node scripts/monitor-race-conditions.js
 */

require('dotenv').config();
const mongoose = require('mongoose');
const Booking = require('../src/models/Booking');
const Payment = require('../src/models/Payment');
const Schedule = require('../src/models/Schedule');

const mongoURI = process.env.MONGODB_URI;

// Monitor booking conflicts
async function monitorBookingConflicts(since = new Date(Date.now() - 24 * 60 * 60 * 1000)) {
  console.log('\n📊 BOOKING CONFLICTS (Last 24h)');
  console.log('='.repeat(70));

  // Find schedules with potential overselling
  const schedules = await Schedule.find({
    'seatConfiguration.availableSeats': { $lt: 0 }
  });

  if (schedules.length > 0) {
    console.log(`❌ CRITICAL: ${schedules.length} schedules có số ghế âm!`);
    schedules.forEach(s => {
      console.log(`  - Schedule ${s._id}: ${s.seatConfiguration.availableSeats} ghế`);
    });
  } else {
    console.log('✅ Không có schedule nào bị overselling');
  }

  // Find bookings created at same time for same schedule
  const pipeline = [
    {
      $match: {
        createdAt: { $gte: since }
      }
    },
    {
      $group: {
        _id: {
          scheduleId: '$scheduleId',
          second: {
            $dateToString: {
              format: '%Y-%m-%d %H:%M:%S',
              date: '$createdAt'
            }
          }
        },
        count: { $sum: 1 },
        bookings: { $push: '$_id' }
      }
    },
    {
      $match: {
        count: { $gt: 1 }
      }
    },
    {
      $sort: { count: -1 }
    },
    {
      $limit: 10
    }
  ];

  const conflicts = await Booking.aggregate(pipeline);

  if (conflicts.length > 0) {
    console.log(`\n⚠️  Phát hiện ${conflicts.length} potential race conditions:`);
    conflicts.forEach(c => {
      console.log(`  - ${c._id.second}: ${c.count} bookings cùng lúc cho schedule ${c._id.scheduleId}`);
    });
  } else {
    console.log('\n✅ Không phát hiện concurrent booking conflicts');
  }
}

// Monitor payment duplicates
async function monitorPaymentDuplicates(since = new Date(Date.now() - 24 * 60 * 60 * 1000)) {
  console.log('\n📊 PAYMENT DUPLICATES (Last 24h)');
  console.log('='.repeat(70));

  // Find bookings with multiple completed payments
  const pipeline = [
    {
      $match: {
        createdAt: { $gte: since },
        status: 'completed'
      }
    },
    {
      $group: {
        _id: '$bookingId',
        count: { $sum: 1 },
        payments: { $push: '$_id' },
        totalAmount: { $sum: '$amount' }
      }
    },
    {
      $match: {
        count: { $gt: 1 }
      }
    }
  ];

  const duplicates = await Payment.aggregate(pipeline);

  if (duplicates.length > 0) {
    console.log(`❌ CRITICAL: ${duplicates.length} bookings có nhiều payments!`);
    duplicates.forEach(d => {
      console.log(`  - Booking ${d._id}: ${d.count} payments, total ${d.totalAmount} VND`);
    });
  } else {
    console.log('✅ Không có payment duplicates');
  }

  // Find payments processed multiple times (same transactionId)
  const txPipeline = [
    {
      $match: {
        createdAt: { $gte: since },
        status: 'completed',
        vnpayTransactionNo: { $exists: true, $ne: null }
      }
    },
    {
      $group: {
        _id: '$vnpayTransactionNo',
        count: { $sum: 1 },
        payments: { $push: '$_id' }
      }
    },
    {
      $match: {
        count: { $gt: 1 }
      }
    }
  ];

  const txDuplicates = await Payment.aggregate(txPipeline);

  if (txDuplicates.length > 0) {
    console.log(`\n❌ CRITICAL: ${txDuplicates.length} transaction IDs được process nhiều lần!`);
    txDuplicates.forEach(d => {
      console.log(`  - Transaction ${d._id}: ${d.count} lần`);
    });
  } else {
    console.log('\n✅ Không có transaction duplicates');
  }
}

// Monitor cancellation conflicts
async function monitorCancellationConflicts(since = new Date(Date.now() - 24 * 60 * 60 * 1000)) {
  console.log('\n📊 CANCELLATION CONFLICTS (Last 24h)');
  console.log('='.repeat(70));

  // Find bookings cancelled multiple times (check audit log if available)
  const cancelled = await Booking.find({
    status: 'cancelled',
    cancelledAt: { $gte: since }
  }).select('_id pnr cancelledAt scheduleId passengers');

  console.log(`Total cancellations: ${cancelled.length}`);

  // Check if any schedule has more available seats than total seats
  const schedules = await Schedule.find();
  let oversupply = 0;

  for (const schedule of schedules) {
    const totalSeats = schedule.seatConfiguration.totalSeats;
    const availableSeats = schedule.seatConfiguration.availableSeats;

    if (availableSeats > totalSeats) {
      oversupply++;
      console.log(`⚠️  Schedule ${schedule._id}: ${availableSeats}/${totalSeats} ghế (oversupply!)`);
    }
  }

  if (oversupply === 0) {
    console.log('✅ Không có schedule nào bị oversupply từ cancellation');
  }
}

// Monitor schedule update conflicts
async function monitorScheduleUpdateConflicts(since = new Date(Date.now() - 24 * 60 * 60 * 1000)) {
  console.log('\n📊 SCHEDULE UPDATE CONFLICTS (Last 24h)');
  console.log('='.repeat(70));

  // Find schedules updated while having pending bookings
  const schedules = await Schedule.find({
    updatedAt: { $gte: since }
  }).select('_id updatedAt');

  let conflicts = 0;

  for (const schedule of schedules) {
    const pendingBookings = await Booking.find({
      scheduleId: schedule._id,
      status: 'pending',
      createdAt: { $lt: schedule.updatedAt }
    });

    if (pendingBookings.length > 0) {
      conflicts++;
      console.log(`⚠️  Schedule ${schedule._id} updated với ${pendingBookings.length} pending bookings`);
    }
  }

  if (conflicts === 0) {
    console.log('✅ Không có schedule update conflicts');
  }
}

// Generate summary report
async function generateSummaryReport() {
  console.log('\n📈 SUMMARY REPORT');
  console.log('='.repeat(70));

  const now = new Date();
  const last24h = new Date(now - 24 * 60 * 60 * 1000);

  const stats = {
    totalBookings: await Booking.countDocuments({ createdAt: { $gte: last24h } }),
    confirmedBookings: await Booking.countDocuments({ 
      createdAt: { $gte: last24h },
      status: 'confirmed'
    }),
    cancelledBookings: await Booking.countDocuments({ 
      createdAt: { $gte: last24h },
      status: 'cancelled'
    }),
    totalPayments: await Payment.countDocuments({ createdAt: { $gte: last24h } }),
    completedPayments: await Payment.countDocuments({ 
      createdAt: { $gte: last24h },
      status: 'completed'
    }),
    failedPayments: await Payment.countDocuments({ 
      createdAt: { $gte: last24h },
      status: 'failed'
    })
  };

  console.log(`Bookings (24h):`);
  console.log(`  Total: ${stats.totalBookings}`);
  console.log(`  Confirmed: ${stats.confirmedBookings} (${(stats.confirmedBookings/stats.totalBookings*100).toFixed(1)}%)`);
  console.log(`  Cancelled: ${stats.cancelledBookings} (${(stats.cancelledBookings/stats.totalBookings*100).toFixed(1)}%)`);
  console.log(``);
  console.log(`Payments (24h):`);
  console.log(`  Total: ${stats.totalPayments}`);
  console.log(`  Completed: ${stats.completedPayments} (${(stats.completedPayments/stats.totalPayments*100).toFixed(1)}%)`);
  console.log(`  Failed: ${stats.failedPayments} (${(stats.failedPayments/stats.totalPayments*100).toFixed(1)}%)`);
}

// Main
async function main() {
  try {
    await mongoose.connect(mongoURI);
    console.log('✅ Connected to MongoDB');
    console.log(`📅 Monitoring period: Last 24 hours`);
    console.log(`🕐 Current time: ${new Date().toISOString()}`);

    await monitorBookingConflicts();
    await monitorPaymentDuplicates();
    await monitorCancellationConflicts();
    await monitorScheduleUpdateConflicts();
    await generateSummaryReport();

    console.log('\n' + '='.repeat(70));
    console.log('✅ Monitoring completed');
    console.log('='.repeat(70));

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
  }
}

main();

