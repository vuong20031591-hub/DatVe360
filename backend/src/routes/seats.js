const express = require('express');
const router = express.Router();

// @desc    Get seat map for schedule
// @route   GET /api/v1/seats/schedule/:scheduleId
// @access  Public
router.get('/schedule/:scheduleId', async (req, res) => {
  try {
    const { scheduleId } = req.params;

    // Generate mock seat map for testing
    const seatMap = generateMockSeatMap();

    res.json({
      success: true,
      data: {
        scheduleId,
        layout: '3-3',
        totalSeats: 120,
        availableSeats: 95,
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

// Helper function to generate mock seat map
function generateMockSeatMap() {
  const layout = '3-3';
  const totalSeats = 120;
  const vehicleType = 'aircraft';
  
  // Parse layout (e.g., "3-3" means 3 seats, aisle, 3 seats)
  const seatConfig = layout.split('-').map(n => parseInt(n));
  const seatsPerRow = seatConfig.reduce((sum, n) => sum + n, 0);
  const totalRows = Math.ceil(totalSeats / seatsPerRow);
  
  const seatMap = [];
  const columns = generateColumnLabels(seatConfig);
  
  // Generate some booked seats for realism (5-15% occupancy)
  const occupancyRate = 0.05 + Math.random() * 0.10;
  const bookedSeatsCount = Math.floor(totalSeats * occupancyRate);
  const bookedSeats = new Set();
  
  // Randomly select booked seats
  while (bookedSeats.size < bookedSeatsCount) {
    const row = Math.floor(Math.random() * totalRows) + 1;
    const colIndex = Math.floor(Math.random() * columns.length);
    const seatId = `${row}${columns[colIndex]}`;
    bookedSeats.add(seatId);
  }
  
  for (let row = 1; row <= totalRows; row++) {
    const rowSeats = [];
    let colIndex = 0;
    
    for (let sectionIndex = 0; sectionIndex < seatConfig.length; sectionIndex++) {
      const sectionSize = seatConfig[sectionIndex];
      
      for (let seatInSection = 0; seatInSection < sectionSize; seatInSection++) {
        const col = columns[colIndex];
        const seatId = `${row}${col}`;
        
        // Determine seat type based on position
        let seatType = 'standard';
        if (vehicleType === 'aircraft') {
          if (row <= 3) seatType = 'premium';
          else if (col === 'A' || col === 'F') seatType = 'window';
          else if (col === 'C' || col === 'D') seatType = 'aisle';
        }
        
        // Determine seat status
        let status = 'available';
        if (bookedSeats.has(seatId)) {
          status = 'booked';
        }
        
        rowSeats.push({
          id: seatId,
          row,
          col,
          type: seatType,
          status,
          priceAddon: seatType === 'premium' ? 500000 :
                     seatType === 'window' || seatType === 'aisle' ? 50000 : 0,
          metadata: {
            section: sectionIndex,
            position: seatInSection
          }
        });
        
        colIndex++;
      }
      
      // Add aisle space (except after last section)
      if (sectionIndex < seatConfig.length - 1) {
        rowSeats.push(null); // Aisle space
      }
    }
    
    seatMap.push(rowSeats);
  }
  
  return seatMap;
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
