# DatVe360 Backend API

Backend API cho ứng dụng đặt vé đa phương tiện DatVe360.

## 🚀 Cài đặt và chạy

### Yêu cầu hệ thống
- Node.js >= 18.0.0
- MongoDB >= 5.0
- Redis (tùy chọn, cho caching)

### Cài đặt dependencies
```bash
npm install
```

### Cấu hình môi trường
1. Copy file `.env.example` thành `.env`:
```bash
cp .env.example .env
```

2. Cập nhật các biến môi trường trong `.env`:
```env
# Database
MONGODB_URI=mongodb://localhost:27017/datve360

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_REFRESH_SECRET=your-refresh-secret-key

# Email (tùy chọn)
EMAIL_SERVICE=gmail
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
```

### Khởi tạo database
```bash
# Khởi tạo database với dữ liệu cơ bản
npm run db:init

# Thêm dữ liệu mẫu (tùy chọn)
npm run db:seed

# Hoặc reset toàn bộ database
npm run db:reset
```

### Chạy ứng dụng
```bash
# Development mode
npm run dev

# Production mode
npm start
```

## 📊 Database Schema

### Users
- Authentication với JWT + Refresh tokens
- Role-based access (user, operator, admin)
- Profile và preferences

### Destinations
- Airports, train stations, bus stations, ferry ports
- Coordinates và timezone info

### Schedules
- Lịch trình cho tất cả phương tiện
- Seat configuration và pricing
- Vehicle information

### Bookings
- Passenger information
- Seat selection
- Payment integration

### Tickets
- QR codes và PDF generation
- Status tracking

## 🔐 Authentication

### Đăng ký
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "displayName": "Nguyen Van A",
  "phoneNumber": "0901234567"
}
```

### Đăng nhập
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "rememberMe": true
}
```

### Refresh token
```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "your-refresh-token"
}
```

## 🛣️ API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Đăng ký
- `POST /api/v1/auth/login` - Đăng nhập
- `POST /api/v1/auth/refresh` - Refresh token
- `POST /api/v1/auth/logout` - Đăng xuất
- `POST /api/v1/auth/forgot-password` - Quên mật khẩu
- `POST /api/v1/auth/reset-password` - Reset mật khẩu

### Destinations
- `GET /api/v1/destinations` - Danh sách điểm đến
- `GET /api/v1/destinations/search` - Tìm kiếm điểm đến
- `GET /api/v1/destinations/:id` - Chi tiết điểm đến

### Schedules
- `GET /api/v1/schedules/search` - Tìm kiếm lịch trình
- `GET /api/v1/schedules/:id` - Chi tiết lịch trình
- `GET /api/v1/schedules/:id/seats` - Sơ đồ ghế

### Bookings
- `POST /api/v1/bookings` - Tạo booking
- `GET /api/v1/bookings` - Danh sách booking
- `GET /api/v1/bookings/:id` - Chi tiết booking
- `PUT /api/v1/bookings/:id/cancel` - Hủy booking

### Payments
- `POST /api/v1/payments/process` - Xử lý thanh toán
- `GET /api/v1/payments/:id/status` - Trạng thái thanh toán

### Tickets
- `GET /api/v1/tickets/booking/:bookingId` - Vé theo booking
- `GET /api/v1/tickets/:id/qr` - QR code
- `GET /api/v1/tickets/:id/pdf` - PDF ticket

## 🧪 Test Accounts

Sau khi chạy `npm run db:init`, bạn có thể sử dụng các tài khoản test:

```
Admin: admin@datve360.com / 123456
Operator: operator@datve360.com / 123456
User: user@example.com / 123456
```

## 🔧 Development

### Cấu trúc thư mục
```
src/
├── config/          # Database, Redis, Logger config
├── middleware/      # Auth, validation, error handling
├── models/          # Mongoose models
├── routes/          # API routes
├── utils/           # Utilities (QR, PDF generation)
└── app.js          # Main application file
```

### Logging
- Development: Console output với colors
- Production: File-based logging với rotation

### Error Handling
- Centralized error handling middleware
- Custom error classes
- Validation với express-validator

## 📦 Deployment

### Docker (sắp có)
```bash
docker-compose up -d
```

### PM2
```bash
npm install -g pm2
pm2 start ecosystem.config.js
```

## 🤝 Contributing

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push và tạo Pull Request

## 📄 License

ISC License - DatVe360 Team
