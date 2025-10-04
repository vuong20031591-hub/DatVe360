const mongoose = require('mongoose');
const Trip = require('./src/models/Trip');
const Destination = require('./src/models/Destination');
require('dotenv').config();

// Helper function to create Vietnam timezone date
const createVNDate = (year, month, day, hour, minute) => {
  // Create date in Vietnam timezone (UTC+7)
  const date = new Date(year, month - 1, day, hour, minute, 0, 0);
  // Subtract 7 hours to convert to UTC for storage
  date.setHours(date.getHours() - 7);
  return date;
};

// Time slots for different transport modes
const timeSlots = {
  flight: [
    { hour: 6, minute: 0 },   // 06:00
    { hour: 8, minute: 30 },  // 08:30
    { hour: 10, minute: 45 }, // 10:45
    { hour: 13, minute: 15 }, // 13:15
    { hour: 15, minute: 30 }, // 15:30
    { hour: 17, minute: 45 }, // 17:45
    { hour: 19, minute: 30 }, // 19:30
    { hour: 21, minute: 15 }  // 21:15
  ],
  train: [
    { hour: 5, minute: 30 },  // 05:30
    { hour: 7, minute: 0 },   // 07:00
    { hour: 9, minute: 30 },  // 09:30
    { hour: 12, minute: 0 },  // 12:00
    { hour: 14, minute: 30 }, // 14:30
    { hour: 17, minute: 0 },  // 17:00
    { hour: 19, minute: 30 }, // 19:30
    { hour: 22, minute: 0 }   // 22:00
  ],
  bus: [
    { hour: 5, minute: 0 },   // 05:00
    { hour: 6, minute: 30 },  // 06:30
    { hour: 8, minute: 0 },   // 08:00
    { hour: 10, minute: 0 },  // 10:00
    { hour: 12, minute: 30 }, // 12:30
    { hour: 14, minute: 0 },  // 14:00
    { hour: 16, minute: 30 }, // 16:30
    { hour: 18, minute: 0 },  // 18:00
    { hour: 20, minute: 0 }   // 20:00
  ],
  ferry: [
    { hour: 7, minute: 0 },   // 07:00
    { hour: 9, minute: 30 },  // 09:30
    { hour: 12, minute: 0 },  // 12:00
    { hour: 14, minute: 30 }, // 14:30
    { hour: 17, minute: 0 }   // 17:00
  ]
};

// Popular routes
const routes = [
  { from: 'HAN', to: 'SGN', mode: 'flight', duration: 120, price: 1500000 },
  { from: 'SGN', to: 'HAN', mode: 'flight', duration: 120, price: 1500000 },
  { from: 'HAN', to: 'DAD', mode: 'flight', duration: 75, price: 1200000 },
  { from: 'DAD', to: 'HAN', mode: 'flight', duration: 75, price: 1200000 },
  { from: 'SGN', to: 'DAD', mode: 'flight', duration: 90, price: 1300000 },
  { from: 'DAD', to: 'SGN', mode: 'flight', duration: 90, price: 1300000 },
  { from: 'HAN', to: 'SGN', mode: 'train', duration: 1800, price: 800000 },
  { from: 'SGN', to: 'HAN', mode: 'train', duration: 1800, price: 800000 },
  { from: 'HAN', to: 'DAD', mode: 'train', duration: 960, price: 600000 },
  { from: 'HAN', to: 'HPH', mode: 'bus', duration: 120, price: 150000 },
  { from: 'HPH', to: 'HAN', mode: 'bus', duration: 120, price: 150000 }
];

const generateSchedules = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/datve360');
    console.log('Connected to MongoDB');

    // Get all destinations
    const destinations = await Destination.find({});
    console.log(`Found ${destinations.length} destinations`);

    // Date range: 04/10/2025 to 30/10/2025
    const startDate = new Date('2025-10-04');
    const endDate = new Date('2025-10-30');
    
    let totalTrips = 0;
    let totalSchedules = 0;

    // For each route
    for (const route of routes) {
      const fromDest = destinations.find(d => d.code === route.from);
      const toDest = destinations.find(d => d.code === route.to);

      if (!fromDest || !toDest) {
        console.log(`Skipping route ${route.from} -> ${route.to}: destination not found`);
        continue;
      }

      console.log(`\nGenerating schedules for ${route.from} -> ${route.to} (${route.mode})`);

      // Get time slots for this mode
      const slots = timeSlots[route.mode] || timeSlots.bus;

      // Carrier info
      const carrierInfo = {
        flight: { name: 'Vietnam Airlines', code: 'VN' },
        train: { name: 'Đường sắt Việt Nam', code: 'SE' },
        bus: { name: 'Phương Trang', code: 'PT' },
        ferry: { name: 'Superdong', code: 'SD' }
      };

      const carrier = carrierInfo[route.mode] || carrierInfo.bus;

      // For each time slot
      for (const slot of slots) {
        // Generate schedules for each day
        const currentDate = new Date(startDate);
        let scheduleCount = 0;

        while (currentDate <= endDate) {
          // Create Vietnam timezone date
          const departAt = createVNDate(
            currentDate.getFullYear(),
            currentDate.getMonth() + 1,
            currentDate.getDate(),
            slot.hour,
            slot.minute
          );

          const arriveAt = new Date(departAt);
          arriveAt.setMinutes(arriveAt.getMinutes() + route.duration);

          // Create trip (each trip is a schedule)
          const trip = new Trip({
            carrierId: carrier.code,
            carrierName: carrier.name,
            mode: route.mode,
            from: fromDest.name,
            fromCode: fromDest.code,
            to: toDest.name,
            toCode: toDest.code,
            departAt,
            arriveAt,
            duration: route.duration,
            basePrice: route.price,
            classOptions: route.mode === 'flight' ? [
              {
                id: 'ECO',
                name: 'Economy',
                price: route.price,
                totalSeats: 150,
                availableSeats: 150,
                amenities: ['Hành lý xách tay 7kg', 'Nước uống']
              },
              {
                id: 'BUS',
                name: 'Business',
                price: route.price * 2,
                totalSeats: 30,
                availableSeats: 30,
                amenities: ['Hành lý 30kg', 'Suất ăn', 'Phòng chờ']
              }
            ] : route.mode === 'train' ? [
              {
                id: 'HARD',
                name: 'Ngồi cứng',
                price: route.price * 0.7,
                totalSeats: 80,
                availableSeats: 80,
                amenities: ['Ghế ngồi']
              },
              {
                id: 'SOFT',
                name: 'Ngồi mềm',
                price: route.price,
                totalSeats: 60,
                availableSeats: 60,
                amenities: ['Ghế ngồi êm', 'Điều hòa']
              },
              {
                id: 'SLEEPER',
                name: 'Giường nằm',
                price: route.price * 1.5,
                totalSeats: 40,
                availableSeats: 40,
                amenities: ['Giường nằm', 'Chăn gối', 'Điều hòa']
              }
            ] : [
              {
                id: 'NORMAL',
                name: 'Ghế thường',
                price: route.price,
                totalSeats: 40,
                availableSeats: 40,
                amenities: ['Ghế ngồi', 'Nước uống']
              },
              {
                id: 'SLEEPER',
                name: 'Giường nằm',
                price: route.price * 1.3,
                totalSeats: 20,
                availableSeats: 20,
                amenities: ['Giường nằm', 'Chăn gối', 'Điều hòa']
              }
            ],
            status: 'scheduled',
            isActive: true
          });

          await trip.save();
          totalTrips++;
          totalSchedules++;
          scheduleCount++;

          currentDate.setDate(currentDate.getDate() + 1);
        }

        console.log(`  Created ${scheduleCount} trips for slot ${slot.hour}:${slot.minute.toString().padStart(2, '0')}`);
      }
    }

    console.log(`\n✅ Done!`);
    console.log(`Total trips created: ${totalTrips}`);
    console.log(`Total schedules created: ${totalSchedules}`);

    await mongoose.disconnect();
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
};

generateSchedules();

