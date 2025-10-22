require('dotenv').config();
const mongoose = require('mongoose');

// Import models
const Destination = require('../src/models/Destination');
const Route = require('../src/models/Route');
const TransportOperator = require('../src/models/TransportOperator');
const Schedule = require('../src/models/Schedule');

const logger = {
  info: (msg) => console.log(`✅ ${msg}`),
  error: (msg) => console.log(`❌ ${msg}`),
  warn: (msg) => console.log(`⚠️ ${msg}`)
};

async function connectDB() {
  try {
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/datve360';
    await mongoose.connect(mongoURI);
    logger.info('Connected to MongoDB');
  } catch (error) {
    logger.error(`Database connection failed: ${error.message}`);
    process.exit(1);
  }
}

// Dữ liệu thực tế về sân bay Việt Nam
const AIRPORTS = [
  { code: 'HAN', name: 'Sân bay Nội Bài', city: 'Hà Nội', lat: 21.2212, lng: 105.8072 },
  { code: 'SGN', name: 'Sân bay Tân Sơn Nhất', city: 'TP.HCM', lat: 10.8188, lng: 106.6519 },
  { code: 'DAD', name: 'Sân bay Đà Nẵng', city: 'Đà Nẵng', lat: 16.0439, lng: 108.1994 },
  { code: 'CXR', name: 'Sân bay Cam Ranh', city: 'Nha Trang', lat: 12.2488, lng: 109.1967 },
  { code: 'HPH', name: 'Sân bay Cát Bi', city: 'Hải Phòng', lat: 20.8197, lng: 106.7247 },
  { code: 'HUI', name: 'Sân bay Phú Bài', city: 'Huế', lat: 16.4015, lng: 107.7026 },
  { code: 'VCA', name: 'Sân bay Cần Thơ', city: 'Cần Thơ', lat: 10.0851, lng: 105.7117 },
  { code: 'PQC', name: 'Sân bay Phú Quốc', city: 'Phú Quốc', lat: 10.2270, lng: 103.9678 },
  { code: 'VDH', name: 'Sân bay Đồng Hới', city: 'Đồng Hới', lat: 17.5152, lng: 106.5897 },
  { code: 'DLI', name: 'Sân bay Liên Khương', city: 'Đà Lạt', lat: 11.7500, lng: 108.3667 },
  { code: 'UIH', name: 'Sân bay Phù Cát', city: 'Quy Nhơn', lat: 13.9550, lng: 109.0422 },
  { code: 'VDO', name: 'Sân bay Vân Đồn', city: 'Quảng Ninh', lat: 21.1197, lng: 107.4167 },
  { code: 'VII', name: 'Sân bay Vinh', city: 'Vinh', lat: 18.7378, lng: 105.6708 },
  { code: 'THD', name: 'Sân bay Thọ Xuân', city: 'Thanh Hóa', lat: 19.9017, lng: 105.4678 },
  { code: 'BMV', name: 'Sân bay Buôn Ma Thuột', city: 'Buôn Ma Thuột', lat: 12.6683, lng: 108.1203 },
  { code: 'VCS', name: 'Sân bay Côn Đảo', city: 'Côn Đảo', lat: 8.7318, lng: 106.6328 },
  { code: 'CAH', name: 'Sân bay Cà Mau', city: 'Cà Mau', lat: 9.1767, lng: 105.1524 },
  { code: 'VKG', name: 'Sân bay Rạch Giá', city: 'Rạch Giá', lat: 9.9580, lng: 105.1324 },
  { code: 'PXU', name: 'Sân bay Pleiku', city: 'Pleiku', lat: 14.0045, lng: 108.0172 },
  { code: 'TBB', name: 'Sân bay Tuy Hòa', city: 'Tuy Hòa', lat: 13.0497, lng: 109.3339 }
];

// Ga tàu hỏa chính
const TRAIN_STATIONS = [
  { code: 'HN_TRAIN', name: 'Ga Hà Nội', city: 'Hà Nội', lat: 21.0245, lng: 105.8412 },
  { code: 'SGN_TRAIN', name: 'Ga Sài Gòn', city: 'TP.HCM', lat: 10.7821, lng: 106.6770 },
  { code: 'DN_TRAIN', name: 'Ga Đà Nẵng', city: 'Đà Nẵng', lat: 16.0678, lng: 108.2208 },
  { code: 'HUE_TRAIN', name: 'Ga Huế', city: 'Huế', lat: 16.4637, lng: 107.5909 },
  { code: 'NT_TRAIN', name: 'Ga Nha Trang', city: 'Nha Trang', lat: 12.2388, lng: 109.1967 },
  { code: 'VINH_TRAIN', name: 'Ga Vinh', city: 'Vinh', lat: 18.6759, lng: 105.6920 },
  { code: 'QB_TRAIN', name: 'Ga Quảng Bình', city: 'Đồng Hới', lat: 17.4739, lng: 106.6222 },
  { code: 'QN_TRAIN', name: 'Ga Quảng Ngãi', city: 'Quảng Ngãi', lat: 15.1214, lng: 108.8044 },
  { code: 'BT_TRAIN', name: 'Ga Biên Hòa', city: 'Biên Hòa', lat: 10.9450, lng: 106.8200 },
  { code: 'PT_TRAIN', name: 'Ga Phan Thiết', city: 'Phan Thiết', lat: 10.9300, lng: 108.1022 },
  { code: 'DT_TRAIN', name: 'Ga Dĩ An', city: 'Dĩ An', lat: 10.9067, lng: 106.7700 },
  { code: 'NB_TRAIN', name: 'Ga Ninh Bình', city: 'Ninh Bình', lat: 20.2506, lng: 105.9745 },
  { code: 'TH_TRAIN', name: 'Ga Thanh Hóa', city: 'Thanh Hóa', lat: 19.8067, lng: 105.7850 },
  { code: 'HG_TRAIN', name: 'Ga Hà Giang', city: 'Hà Giang', lat: 22.8228, lng: 104.9784 },
  { code: 'LC_TRAIN', name: 'Ga Lào Cai', city: 'Lào Cai', lat: 22.4856, lng: 103.9750 }
];

// Bến xe khách chính
const BUS_STATIONS = [
  { code: 'HN_BUS_MD', name: 'Bến xe Mỹ Đình', city: 'Hà Nội', lat: 21.0278, lng: 105.7789 },
  { code: 'HN_BUS_GV', name: 'Bến xe Giáp Vát', city: 'Hà Nội', lat: 21.0520, lng: 105.8198 },
  { code: 'HN_BUS_NL', name: 'Bến xe Nước Ngầm', city: 'Hà Nội', lat: 21.0011, lng: 105.8453 },
  { code: 'SGN_BUS_MD', name: 'Bến xe Miền Đông', city: 'TP.HCM', lat: 10.8142, lng: 106.7317 },
  { code: 'SGN_BUS_MT', name: 'Bến xe Miền Tây', city: 'TP.HCM', lat: 10.7378, lng: 106.6122 },
  { code: 'SGN_BUS_AN', name: 'Bến xe An Sương', city: 'TP.HCM', lat: 10.8378, lng: 106.6022 },
  { code: 'DN_BUS', name: 'Bến xe Đà Nẵng', city: 'Đà Nẵng', lat: 16.0544, lng: 108.2022 },
  { code: 'NT_BUS', name: 'Bến xe Nha Trang', city: 'Nha Trang', lat: 12.2388, lng: 109.1967 },
  { code: 'CT_BUS', name: 'Bến xe Cần Thơ', city: 'Cần Thơ', lat: 10.0452, lng: 105.7469 },
  { code: 'DL_BUS', name: 'Bến xe Đà Lạt', city: 'Đà Lạt', lat: 11.9404, lng: 108.4583 },
  { code: 'VT_BUS', name: 'Bến xe Vũng Tàu', city: 'Vũng Tàu', lat: 10.3460, lng: 107.0843 },
  { code: 'HP_BUS', name: 'Bến xe Hải Phòng', city: 'Hải Phòng', lat: 20.8449, lng: 106.6881 },
  { code: 'HUE_BUS', name: 'Bến xe Huế', city: 'Huế', lat: 16.4637, lng: 107.5909 },
  { code: 'QN_BUS', name: 'Bến xe Quy Nhơn', city: 'Quy Nhơn', lat: 13.7830, lng: 109.2192 },
  { code: 'PT_BUS', name: 'Bến xe Phan Thiết', city: 'Phan Thiết', lat: 10.9300, lng: 108.1022 }
];

// Hãng hàng không
const AIRLINES = [
  { code: 'VN', name: 'Vietnam Airlines', type: 'premium' },
  { code: 'VJ', name: 'VietJet Air', type: 'budget' },
  { code: 'QH', name: 'Bamboo Airways', type: 'premium' },
  { code: 'VU', name: 'Vietravel Airlines', type: 'budget' }
];

// Nhà xe khách
const BUS_OPERATORS = [
  { name: 'Phương Trang (FUTA)', code: 'FUTA', quality: 'premium' },
  { name: 'Mai Linh Express', code: 'MLX', quality: 'premium' },
  { name: 'Thành Bưởi', code: 'TB', quality: 'standard' },
  { name: 'Hoàng Long', code: 'HL', quality: 'premium' },
  { name: 'Kumho Samco', code: 'KS', quality: 'premium' },
  { name: 'Hà Lan', code: 'HaLan', quality: 'standard' },
  { name: 'Phúc Xuyên', code: 'PX', quality: 'standard' },
  { name: 'Hải Vân', code: 'HV', quality: 'standard' }
];

// Tàu hỏa
const TRAINS = [
  { code: 'SE1', name: 'Tàu SE1', type: 'express' },
  { code: 'SE2', name: 'Tàu SE2', type: 'express' },
  { code: 'SE3', name: 'Tàu SE3', type: 'express' },
  { code: 'SE4', name: 'Tàu SE4', type: 'express' },
  { code: 'SE5', name: 'Tàu SE5', type: 'express' },
  { code: 'SE6', name: 'Tàu SE6', type: 'express' },
  { code: 'SE7', name: 'Tàu SE7', type: 'express' },
  { code: 'SE8', name: 'Tàu SE8', type: 'express' },
  { code: 'TN1', name: 'Tàu TN1', type: 'local' },
  { code: 'TN2', name: 'Tàu TN2', type: 'local' }
];

async function seedTransportOperators() {
  try {
    const operators = [];

    // Add airlines
    AIRLINES.forEach(airline => {
      operators.push({
        name: airline.name,
        code: airline.code,
        transportTypes: ['flight'],
        isActive: true
      });
    });

    // Add bus operators
    BUS_OPERATORS.forEach(busOp => {
      operators.push({
        name: busOp.name,
        code: busOp.code,
        transportTypes: ['bus'],
        isActive: true
      });
    });

    // Add train operator
    operators.push({
      name: 'Đường sắt Việt Nam',
      code: 'DSVN',
      transportTypes: ['train'],
      isActive: true
    });

    // Check existing and insert new
    const existingCodes = await TransportOperator.find({}).distinct('code');
    const newOperators = operators.filter(op => !existingCodes.includes(op.code));

    if (newOperators.length > 0) {
      await TransportOperator.insertMany(newOperators);
      logger.info(`Added ${newOperators.length} new transport operators`);
    } else {
      logger.info('All transport operators already exist');
    }
  } catch (error) {
    logger.error(`Failed to seed transport operators: ${error.message}`);
  }
}

async function seedDestinations() {
  try {
    const destinations = [];
    
    // Add airports
    AIRPORTS.forEach(airport => {
      destinations.push({
        code: airport.code,
        name: airport.name,
        city: airport.city,
        country: 'VN',
        type: 'airport',
        coordinates: {
          type: 'Point',
          coordinates: [airport.lng, airport.lat] // [longitude, latitude]
        },
        timezone: 'Asia/Ho_Chi_Minh',
        active: true
      });
    });

    // Add train stations
    TRAIN_STATIONS.forEach(station => {
      destinations.push({
        code: station.code,
        name: station.name,
        city: station.city,
        country: 'VN',
        type: 'train_station',
        coordinates: {
          type: 'Point',
          coordinates: [station.lng, station.lat] // [longitude, latitude]
        },
        timezone: 'Asia/Ho_Chi_Minh',
        active: true
      });
    });

    // Add bus stations
    BUS_STATIONS.forEach(station => {
      destinations.push({
        code: station.code,
        name: station.name,
        city: station.city,
        country: 'VN',
        type: 'bus_station',
        coordinates: {
          type: 'Point',
          coordinates: [station.lng, station.lat] // [longitude, latitude]
        },
        timezone: 'Asia/Ho_Chi_Minh',
        active: true
      });
    });
    
    // Check existing and insert new
    const existingCodes = await Destination.find({}).distinct('code');
    const newDestinations = destinations.filter(dest => !existingCodes.includes(dest.code));
    
    if (newDestinations.length > 0) {
      await Destination.insertMany(newDestinations);
      logger.info(`Added ${newDestinations.length} new destinations`);
    } else {
      logger.info('All destinations already exist');
    }
  } catch (error) {
    logger.error(`Failed to seed destinations: ${error.message}`);
  }
}

async function seedRoutes() {
  try {
    const destinations = await Destination.find({});
    const destMap = {};
    destinations.forEach(dest => {
      destMap[dest.code] = dest._id;
    });

    const routes = [];

    // Flight routes
    const flightRoutes = [
      { from: 'HAN', to: 'SGN', distance: 1160, duration: 120 },
      { from: 'SGN', to: 'HAN', distance: 1160, duration: 120 },
      { from: 'HAN', to: 'DAD', distance: 610, duration: 80 },
      { from: 'DAD', to: 'HAN', distance: 610, duration: 80 },
      { from: 'SGN', to: 'DAD', distance: 610, duration: 75 },
      { from: 'DAD', to: 'SGN', distance: 610, duration: 75 },
      { from: 'HAN', to: 'CXR', distance: 1050, duration: 110 },
      { from: 'SGN', to: 'CXR', distance: 450, duration: 60 },
      { from: 'HAN', to: 'PQC', distance: 1400, duration: 140 },
      { from: 'SGN', to: 'PQC', distance: 320, duration: 60 },
      { from: 'HAN', to: 'DLI', distance: 1000, duration: 100 },
      { from: 'SGN', to: 'DLI', distance: 300, duration: 50 },
      { from: 'HAN', to: 'HPH', distance: 100, duration: 45 },
      { from: 'HAN', to: 'VDO', distance: 150, duration: 50 },
      { from: 'SGN', to: 'VCA', distance: 170, duration: 45 }
    ];

    flightRoutes.forEach(route => {
      if (destMap[route.from] && destMap[route.to]) {
        routes.push({
          fromDestination: destMap[route.from],
          toDestination: destMap[route.to],
          transportType: 'flight',
          distance: route.distance,
          estimatedDuration: route.duration,
          isActive: true
        });
      }
    });

    // Bus routes
    const busRoutes = [
      { from: 'HN_BUS_MD', to: 'SGN_BUS_MD', distance: 1700, duration: 1800 },
      { from: 'SGN_BUS_MD', to: 'HN_BUS_MD', distance: 1700, duration: 1800 },
      { from: 'HN_BUS_MD', to: 'DN_BUS', distance: 800, duration: 900 },
      { from: 'DN_BUS', to: 'HN_BUS_MD', distance: 800, duration: 900 },
      { from: 'SGN_BUS_MD', to: 'DN_BUS', distance: 900, duration: 720 },
      { from: 'DN_BUS', to: 'SGN_BUS_MD', distance: 900, duration: 720 },
      { from: 'SGN_BUS_MD', to: 'DL_BUS', distance: 300, duration: 420 },
      { from: 'DL_BUS', to: 'SGN_BUS_MD', distance: 300, duration: 420 },
      { from: 'SGN_BUS_MD', to: 'VT_BUS', distance: 125, duration: 150 },
      { from: 'VT_BUS', to: 'SGN_BUS_MD', distance: 125, duration: 150 },
      { from: 'SGN_BUS_MT', to: 'CT_BUS', distance: 170, duration: 240 },
      { from: 'CT_BUS', to: 'SGN_BUS_MT', distance: 170, duration: 240 },
      { from: 'HN_BUS_MD', to: 'HP_BUS', distance: 120, duration: 120 },
      { from: 'HP_BUS', to: 'HN_BUS_MD', distance: 120, duration: 120 },
      { from: 'DN_BUS', to: 'HUE_BUS', distance: 100, duration: 180 },
      { from: 'HUE_BUS', to: 'DN_BUS', distance: 100, duration: 180 }
    ];

    busRoutes.forEach(route => {
      if (destMap[route.from] && destMap[route.to]) {
        routes.push({
          fromDestination: destMap[route.from],
          toDestination: destMap[route.to],
          transportType: 'bus',
          distance: route.distance,
          estimatedDuration: route.duration,
          isActive: true
        });
      }
    });

    // Train routes
    const trainRoutes = [
      { from: 'HN_TRAIN', to: 'SGN_TRAIN', distance: 1726, duration: 1920 },
      { from: 'SGN_TRAIN', to: 'HN_TRAIN', distance: 1726, duration: 1920 },
      { from: 'HN_TRAIN', to: 'DN_TRAIN', distance: 791, duration: 960 },
      { from: 'DN_TRAIN', to: 'HN_TRAIN', distance: 791, duration: 960 },
      { from: 'HN_TRAIN', to: 'HUE_TRAIN', distance: 688, duration: 720 },
      { from: 'HUE_TRAIN', to: 'HN_TRAIN', distance: 688, duration: 720 },
      { from: 'SGN_TRAIN', to: 'NT_TRAIN', distance: 411, duration: 480 },
      { from: 'NT_TRAIN', to: 'SGN_TRAIN', distance: 411, duration: 480 },
      { from: 'DN_TRAIN', to: 'SGN_TRAIN', distance: 935, duration: 960 },
      { from: 'SGN_TRAIN', to: 'DN_TRAIN', distance: 935, duration: 960 }
    ];

    trainRoutes.forEach(route => {
      if (destMap[route.from] && destMap[route.to]) {
        routes.push({
          fromDestination: destMap[route.from],
          toDestination: destMap[route.to],
          transportType: 'train',
          distance: route.distance,
          estimatedDuration: route.duration,
          isActive: true
        });
      }
    });

    // Check existing and insert new
    const existingRoutes = await Route.find({});
    const existingRouteKeys = new Set(
      existingRoutes.map(r => `${r.fromDestination}-${r.toDestination}-${r.transportType}`)
    );

    const newRoutes = routes.filter(route => {
      const key = `${route.fromDestination}-${route.toDestination}-${route.transportType}`;
      return !existingRouteKeys.has(key);
    });

    if (newRoutes.length > 0) {
      await Route.insertMany(newRoutes);
      logger.info(`Added ${newRoutes.length} new routes`);
    } else {
      logger.info('All routes already exist');
    }
  } catch (error) {
    logger.error(`Failed to seed routes: ${error.message}`);
  }
}

async function seedSchedules() {
  try {
    const routes = await Route.find({}).populate('fromDestination toDestination');
    const operators = await TransportOperator.find({});

    // Create operator maps by transport type
    const operatorsByType = {
      flight: operators.filter(op => op.transportTypes.includes('flight')),
      bus: operators.filter(op => op.transportTypes.includes('bus')),
      train: operators.filter(op => op.transportTypes.includes('train'))
    };

    const schedules = [];
    const today = new Date();

    // Generate schedules for next 30 days
    for (let day = 1; day <= 30; day++) {
      const scheduleDate = new Date(today);
      scheduleDate.setDate(today.getDate() + day);

      // Generate schedules for each route
      routes.forEach(route => {
        const routeOperators = operatorsByType[route.transportType] || [];

        if (route.transportType === 'flight') {
          schedules.push(...generateFlightSchedulesForRoute(route, routeOperators, scheduleDate));
        } else if (route.transportType === 'bus') {
          schedules.push(...generateBusSchedulesForRoute(route, routeOperators, scheduleDate));
        } else if (route.transportType === 'train') {
          schedules.push(...generateTrainSchedulesForRoute(route, routeOperators, scheduleDate));
        }
      });
    }

    if (schedules.length > 0) {
      await Schedule.insertMany(schedules);
      logger.info(`Created ${schedules.length} schedules`);
    }
  } catch (error) {
    logger.error(`Failed to seed schedules: ${error.message}`);
  }
}

// Helper function to generate flight schedules for a route
function generateFlightSchedulesForRoute(route, operators, date) {
  const schedules = [];

  // Base price calculation based on distance
  const basePrice = Math.floor(route.distance * 1.2 + 200000);

  operators.forEach((operator, opIdx) => {
    // Each airline has 2-4 flights per day on popular routes
    const flightsPerDay = route.distance > 1000 ? 4 : 2;

    for (let flightNum = 0; flightNum < flightsPerDay; flightNum++) {
      const hour = 6 + (opIdx * 4) + (flightNum * 3);
      if (hour >= 24) continue;

      const departureTime = new Date(date);
      departureTime.setHours(hour, Math.floor(Math.random() * 60), 0, 0);

      const arrivalTime = new Date(departureTime.getTime() + route.estimatedDuration * 60 * 1000);

      // Price varies by operator type and time
      let price = basePrice;
      const airlineType = AIRLINES.find(a => a.code === operator.code)?.type || 'budget';
      if (airlineType === 'budget') {
        price = Math.floor(price * 0.85);
      }
      if (hour < 8 || hour > 20) {
        price = Math.floor(price * 0.9);
      }

      schedules.push({
        routeId: route._id,
        operatorId: operator._id,
        operatorName: operator.name,
        operatorCode: operator.code,
        vehicleNumber: `${operator.code}${Math.floor(Math.random() * 900) + 100}`,
        transportType: 'flight',
        from: route.fromDestination._id,
        to: route.toDestination._id,
        departureTime,
        arrivalTime,
        duration: route.estimatedDuration,
        vehicle: {
          type: 'aircraft',
          model: airlineType === 'premium' ? 'Airbus A321' : 'Airbus A320',
          registrationNumber: `VN-${operator.code}${Math.floor(Math.random() * 999)}`,
          facilities: airlineType === 'premium'
            ? ['WiFi', 'Entertainment', 'Meals', 'USB Charging']
            : ['WiFi', 'Snacks']
        },
        seatConfiguration: {
          totalSeats: 180,
          availableSeats: Math.floor(Math.random() * 80) + 100,
          layout: '3-3',
          classes: new Map([
            ['economy', {
              totalSeats: 150,
              availableSeats: Math.floor(Math.random() * 60) + 90,
              price: price,
              currency: 'VND',
              amenities: ['Baggage 20kg', 'Meal']
            }],
            ['business', {
              totalSeats: 30,
              availableSeats: Math.floor(Math.random() * 15) + 15,
              price: Math.floor(price * 2.2),
              currency: 'VND',
              amenities: ['Baggage 30kg', 'Premium Meal', 'Lounge Access', 'Priority Boarding']
            }]
          ])
        },
        status: 'scheduled',
        bookingDeadline: new Date(departureTime.getTime() - 2 * 60 * 60 * 1000),
        cancellationPolicy: {
          refundable: true,
          cancellationFee: Math.floor(price * 0.1),
          timeLimit: 24
        }
      });
    }
  });

  return schedules;
}

// Helper function to generate bus schedules for a route
function generateBusSchedulesForRoute(route, operators, date) {
  const schedules = [];

  // Base price calculation based on distance
  const basePrice = Math.floor(route.distance * 0.25 + 50000);

  operators.forEach((operator, opIdx) => {
    // Each operator has 2-3 buses per day
    const busesPerDay = route.estimatedDuration > 600 ? 2 : 3;

    for (let busNum = 0; busNum < busesPerDay; busNum++) {
      const hour = 6 + (opIdx * 2) + (busNum * 6);
      if (hour >= 24) continue;

      const departureTime = new Date(date);
      departureTime.setHours(hour, 0, 0, 0);

      const arrivalTime = new Date(departureTime.getTime() + route.estimatedDuration * 60 * 1000);

      // Price varies by operator quality
      let price = basePrice;
      const busQuality = BUS_OPERATORS.find(b => b.code === operator.code)?.quality || 'standard';
      if (busQuality === 'premium') {
        price = Math.floor(price * 1.2);
      }

      const busType = busQuality === 'premium' ? 'Giường nằm Limousine' : 'Giường nằm';
      const totalSeats = busQuality === 'premium' ? 34 : 40;

      schedules.push({
        routeId: route._id,
        operatorId: operator._id,
        operatorName: operator.name,
        operatorCode: operator.code,
        vehicleNumber: `${operator.code}-${Math.floor(Math.random() * 9000) + 1000}`,
        transportType: 'bus',
        from: route.fromDestination._id,
        to: route.toDestination._id,
        departureTime,
        arrivalTime,
        duration: route.estimatedDuration,
        vehicle: {
          type: 'bus',
          model: busType,
          registrationNumber: `${Math.floor(Math.random() * 90) + 10}A-${Math.floor(Math.random() * 90000) + 10000}`,
          facilities: busQuality === 'premium'
            ? ['WiFi', 'AC', 'Toilet', 'Water', 'Blanket', 'USB Charging']
            : ['AC', 'Water', 'Blanket']
        },
        seatConfiguration: {
          totalSeats: totalSeats,
          availableSeats: Math.floor(Math.random() * 20) + 14,
          layout: '2-1', // 2 seats left, 1 seat right, 2 levels
          classes: new Map([
            ['standard', {
              totalSeats: totalSeats,
              availableSeats: Math.floor(Math.random() * 20) + 14,
              price: price,
              currency: 'VND',
              amenities: busQuality === 'premium'
                ? ['Giường nằm', 'Chăn gối', 'Nước uống', 'WiFi']
                : ['Giường nằm', 'Chăn gối', 'Nước uống']
            }]
          ])
        },
        status: 'scheduled',
        bookingDeadline: new Date(departureTime.getTime() - 1 * 60 * 60 * 1000),
        cancellationPolicy: {
          refundable: true,
          cancellationFee: Math.floor(price * 0.2),
          timeLimit: 12
        }
      });
    }
  });

  return schedules;
}

// Helper function to generate train schedules for a route
function generateTrainSchedulesForRoute(route, operators, date) {
  const schedules = [];

  // Base price calculation based on distance
  const basePrice = Math.floor(route.distance * 0.5 + 100000);

  // Each route has 2-3 trains per day
  const trainsPerDay = route.estimatedDuration > 1000 ? 2 : 3;

  for (let trainIdx = 0; trainIdx < trainsPerDay; trainIdx++) {
    const train = TRAINS[trainIdx % TRAINS.length];
    const operator = operators[0]; // Train operator is always DSVN

    const hour = trainIdx === 0 ? 6 : (trainIdx === 1 ? 19 : 12);
    const departureTime = new Date(date);
    departureTime.setHours(hour, 0, 0, 0);

    const arrivalTime = new Date(departureTime.getTime() + route.estimatedDuration * 60 * 1000);

    // Price varies by train type
    let price = basePrice;
    if (train.type === 'express') {
      price = Math.floor(price * 1.1);
    }

    schedules.push({
      routeId: route._id,
      operatorId: operator._id,
      operatorName: operator.name,
      operatorCode: operator.code,
      vehicleNumber: train.code,
      transportType: 'train',
      from: route.fromDestination._id,
      to: route.toDestination._id,
      departureTime,
      arrivalTime,
      duration: route.estimatedDuration,
      vehicle: {
        type: 'train',
        model: train.type === 'express' ? 'Tàu SE (Thống Nhất)' : 'Tàu TN (Tàu Nhanh)',
        registrationNumber: train.code,
        facilities: ['AC', 'Toilet', 'Dining Car', 'Power Outlet']
      },
      seatConfiguration: {
        // Realistic train configuration:
        // 10 coaches × 10 compartments × 4 berths = 400 seats
        totalSeats: 400,
        availableSeats: Math.floor(Math.random() * 150) + 250,
        layout: 'compartment', // 10 compartments per coach, 4 berths per compartment
        coaches: 10, // Number of coaches
        compartmentsPerCoach: 10,
        seatsPerCompartment: 4,
        classes: new Map([
          ['hard_seat', {
            totalSeats: 150,
            availableSeats: Math.floor(Math.random() * 50) + 100,
            price: Math.floor(price * 0.6),
            currency: 'VND',
            amenities: ['Ghế cứng', 'AC']
          }],
          ['soft_seat', {
            totalSeats: 100,
            availableSeats: Math.floor(Math.random() * 40) + 60,
            price: Math.floor(price * 0.8),
            currency: 'VND',
            amenities: ['Ghế mềm', 'AC', 'Chăn gối']
          }],
          ['hard_bed', {
            totalSeats: 100,
            availableSeats: Math.floor(Math.random() * 40) + 60,
            price: price,
            currency: 'VND',
            amenities: ['Giường nằm cứng', 'AC', 'Chăn gối']
          }],
          ['soft_bed', {
            totalSeats: 50,
            availableSeats: Math.floor(Math.random() * 20) + 30,
            price: Math.floor(price * 1.3),
            currency: 'VND',
            amenities: ['Giường nằm mềm', 'AC', 'Chăn gối', 'Tủ đồ']
          }]
        ])
      },
      status: 'scheduled',
      bookingDeadline: new Date(departureTime.getTime() - 3 * 60 * 60 * 1000),
      cancellationPolicy: {
        refundable: true,
        cancellationFee: Math.floor(price * 0.15),
        timeLimit: 24
      }
    });
  }

  return schedules;
}

async function seedDatabase() {
  try {
    logger.info('Starting realistic data seeding...');

    await connectDB();
    await seedDestinations();
    await seedTransportOperators();
    await seedRoutes();
    await seedSchedules();

    logger.info('Realistic data seeding completed!');

    // Display summary
    const destinationCount = await Destination.countDocuments();
    const operatorCount = await TransportOperator.countDocuments();
    const routeCount = await Route.countDocuments();
    const scheduleCount = await Schedule.countDocuments();

    console.log('\n📊 Database Summary:');
    console.log(`📍 Total Destinations: ${destinationCount}`);
    console.log(`  - Airports: ${AIRPORTS.length}`);
    console.log(`  - Train Stations: ${TRAIN_STATIONS.length}`);
    console.log(`  - Bus Stations: ${BUS_STATIONS.length}`);
    console.log(`🚗 Total Operators: ${operatorCount}`);
    console.log(`🛣️  Total Routes: ${routeCount}`);
    console.log(`🚀 Total Schedules: ${scheduleCount}`);
    console.log(`\n✈️ Airlines: ${AIRLINES.map(a => a.name).join(', ')}`);
    console.log(`🚌 Bus Operators: ${BUS_OPERATORS.map(b => b.name).join(', ')}`);
    console.log(`🚂 Trains: ${TRAINS.map(t => t.code).join(', ')}`);

  } catch (error) {
    logger.error(`Data seeding failed: ${error.message}`);
  } finally {
    await mongoose.connection.close();
    logger.info('Database connection closed');
    process.exit(0);
  }
}

// Run seeding
if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase };

