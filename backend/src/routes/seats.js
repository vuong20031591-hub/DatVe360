const express = require('express');
const router = express.Router();
const Schedule = require('../models/Schedule');
const Booking = require('../models/Booking');

// @desc    Get seat map for schedule
// @route   GET /api/v1/seats/schedule/:scheduleId
// @access  Public
router.get('/schedule/:scheduleId', async (req, res) => {
  try {
    const { scheduleId } = req.params;

    // Get schedule from database
    const schedule = await Schedule.findById(scheduleId)
      .populate('routeId')
      .populate('operatorId');

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy lịch trình'
      });
    }

    // Get booked seats for this schedule
    const bookings = await Booking.find({
      scheduleId,
      status: { $in: ['confirmed', 'pending'] }
    }).select('seats');

    const bookedSeatIds = new Set();
    bookings.forEach(booking => {
      booking.seats.forEach(seat => {
        bookedSeatIds.add(seat.seatId);
      });
    });

    // Generate seat map based on transport type
    const seatMap = generateSeatMapByType(
      schedule.transportType,
      schedule.seatConfiguration,
      bookedSeatIds
    );

    res.json({
      success: true,
      data: {
        scheduleId,
        transportType: schedule.transportType,
        layout: schedule.seatConfiguration.layout,
        totalSeats: schedule.seatConfiguration.totalSeats,
        availableSeats: schedule.seatConfiguration.availableSeats,
        seatMap
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi server',
      error: error.message
    });
  }
});

// Helper function to generate seat map based on transport type
function generateSeatMapByType(transportType, seatConfig, bookedSeatIds) {
  switch (transportType.toLowerCase()) {
    case 'flight':
      return generateAirplaneSeatMap(seatConfig, bookedSeatIds);
    case 'train':
      return generateTrainSeatMap(seatConfig, bookedSeatIds);
    case 'bus':
      return generateBusSeatMap(seatConfig, bookedSeatIds);
    default:
      return generateAirplaneSeatMap(seatConfig, bookedSeatIds);
  }
}

// Generate airplane seat map (3-3 or 2-4-2 layout)
function generateAirplaneSeatMap(seatConfig, bookedSeatIds) {
  const layout = seatConfig.layout || '3-3';
  const totalSeats = seatConfig.totalSeats;

  const layoutConfig = layout.split('-').map(n => parseInt(n));
  const seatsPerRow = layoutConfig.reduce((sum, n) => sum + n, 0);
  const totalRows = Math.ceil(totalSeats / seatsPerRow);

  const seatMap = [];
  const columns = generateColumnLabels(layoutConfig);

  for (let row = 1; row <= totalRows; row++) {
    const rowSeats = [];
    let colIndex = 0;

    for (let sectionIndex = 0; sectionIndex < layoutConfig.length; sectionIndex++) {
      const sectionSize = layoutConfig[sectionIndex];

      for (let seatInSection = 0; seatInSection < sectionSize; seatInSection++) {
        const col = columns[colIndex];
        const seatId = `${row}${col}`;

        // Determine seat type
        let seatType = 'standard';
        if (row <= 3) seatType = 'vip'; // First 3 rows are VIP

        // Determine status
        const status = bookedSeatIds.has(seatId) ? 'booked' : 'available';

        rowSeats.push({
          id: seatId,
          row,
          col,
          type: seatType,
          status,
          priceAddon: seatType === 'vip' ? 500000 : 0
        });

        colIndex++;
      }

      // Add aisle space (except after last section)
      if (sectionIndex < layoutConfig.length - 1) {
        rowSeats.push(null);
      }
    }

    seatMap.push(rowSeats);
  }

  return seatMap;
}

// Generate train seat map (compartments with berths organized by coaches)
function generateTrainSeatMap(seatConfig, bookedSeatIds) {
  const totalSeats = seatConfig.totalSeats;
  const seatsPerCompartment = 4; // 4-berth compartments (2 left + 2 right)
  const compartmentsPerCoach = 10; // Standard: 10 compartments per coach

  const totalCompartments = Math.ceil(totalSeats / seatsPerCompartment);
  const totalCoaches = Math.ceil(totalCompartments / compartmentsPerCoach);

  const coaches = [];
  let globalSeatNumber = 1;

  for (let coachNum = 1; coachNum <= totalCoaches; coachNum++) {
    const compartments = [];
    const maxCompartmentsInThisCoach = Math.min(
      compartmentsPerCoach,
      totalCompartments - (coachNum - 1) * compartmentsPerCoach
    );

    for (let compNum = 1; compNum <= maxCompartmentsInThisCoach; compNum++) {
      const leftBerths = [];
      const rightBerths = [];

      // Left side: 2 berths (lower, upper)
      for (let i = 0; i < 2; i++) {
        if (globalSeatNumber > totalSeats) break;

        const seatId = `C${coachNum}${compNum < 10 ? '0' + compNum : compNum}-L${i + 1}`;
        leftBerths.push({
          id: seatId,
          coachNumber: coachNum,
          compartmentNumber: compNum,
          position: `L${i + 1}`,
          type: 'standard',
          status: bookedSeatIds.has(seatId) ? 'booked' : 'available',
          priceAddon: 0
        });
        globalSeatNumber++;
      }

      // Right side: 2 berths (lower, upper)
      for (let i = 0; i < 2; i++) {
        if (globalSeatNumber > totalSeats) break;

        const seatId = `C${coachNum}${compNum < 10 ? '0' + compNum : compNum}-R${i + 1}`;
        rightBerths.push({
          id: seatId,
          coachNumber: coachNum,
          compartmentNumber: compNum,
          position: `R${i + 1}`,
          type: 'standard',
          status: bookedSeatIds.has(seatId) ? 'booked' : 'available',
          priceAddon: 0
        });
        globalSeatNumber++;
      }

      compartments.push({
        compartmentNumber: compNum,
        leftBerths,
        rightBerths
      });

      if (globalSeatNumber > totalSeats) break;
    }

    coaches.push({
      coachNumber: coachNum,
      compartments
    });

    if (globalSeatNumber > totalSeats) break;
  }

  return coaches;
}

// Generate bus seat map (2-1 layout with 2 levels)
function generateBusSeatMap(seatConfig, bookedSeatIds) {
  const totalSeats = seatConfig.totalSeats;
  const seatsPerLevel = Math.ceil(totalSeats / 2);

  const lowerLevel = [];
  const upperLevel = [];

  let seatNumber = 1;

  // Generate lower level
  for (let row = 1; row <= Math.ceil(seatsPerLevel / 3); row++) {
    const rowSeats = [];

    // Left side: 2 seats
    for (let i = 0; i < 2; i++) {
      const seatId = `L${row}${String.fromCharCode(65 + i)}`; // L1A, L1B
      rowSeats.push({
        id: seatId,
        type: 'standard',
        status: bookedSeatIds.has(seatId) ? 'booked' : 'available',
        priceAddon: 0
      });
      seatNumber++;
      if (seatNumber > totalSeats) break;
    }

    // Right side: 1 seat
    if (seatNumber <= totalSeats) {
      const seatId = `L${row}C`;
      rowSeats.push({
        id: seatId,
        type: 'standard',
        status: bookedSeatIds.has(seatId) ? 'booked' : 'available',
        priceAddon: 0
      });
      seatNumber++;
    }

    lowerLevel.push(rowSeats);
    if (seatNumber > totalSeats) break;
  }

  // Generate upper level
  for (let row = 1; row <= Math.ceil(seatsPerLevel / 3); row++) {
    const rowSeats = [];

    // Left side: 2 seats
    for (let i = 0; i < 2; i++) {
      const seatId = `U${row}${String.fromCharCode(65 + i)}`; // U1A, U1B
      rowSeats.push({
        id: seatId,
        type: 'standard',
        status: bookedSeatIds.has(seatId) ? 'booked' : 'available',
        priceAddon: 0
      });
      seatNumber++;
      if (seatNumber > totalSeats) break;
    }

    // Right side: 1 seat
    if (seatNumber <= totalSeats) {
      const seatId = `U${row}C`;
      rowSeats.push({
        id: seatId,
        type: 'standard',
        status: bookedSeatIds.has(seatId) ? 'booked' : 'available',
        priceAddon: 0
      });
      seatNumber++;
    }

    upperLevel.push(rowSeats);
    if (seatNumber > totalSeats) break;
  }

  return [{
    lowerLevel,
    upperLevel
  }];
}

// Helper function to generate column labels
function generateColumnLabels(seatConfig) {
  const labels = [];
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  let labelIndex = 0;
  
  for (const sectionSize of seatConfig) {
    for (let i = 0; i < sectionSize; i++) {
      labels.push(alphabet[labelIndex]);
      labelIndex++;
    }
  }
  
  return labels;
}

module.exports = router;
