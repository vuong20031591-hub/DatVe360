# DatVe360 - Ứng dụng đặt vé đa phương tiện 🚀

Xin chào mọi người! Mình xin giới thiệu về dự án **DatVe360** - một ứng dụng mobile đặt vé tích hợp đa phương tiện giao thông với backend API hoàn chỉnh.

## 🎯 Ý tưởng dự án

Bạn biết đấy, việc đặt vé máy bay, tàu hỏa, xe khách hay phà hiện tại phải vào từng app riêng biệt rất bất tiện. Vì vậy mình đã nghĩ ra ý tưởng tạo một ứng dụng **"all-in-one"** để người dùng có thể:

- 🛫 Đặt vé máy bay
- 🚄 Đặt vé tàu hỏa
- 🚌 Đặt vé xe khách
- ⛴️ Đặt vé phà

Tất cả trong một ứng dụng duy nhất!

## 🏗️ Kiến trúc và công nghệ

### Frontend (Flutter)
Mình đã áp dụng **Clean Architecture** để dự án dễ maintain và scale:

```
lib/
├── app/                    # Cấu hình app chính
│   ├── router/            # GoRouter navigation
│   └── theme/             # Material 3 theme
├── core/                  # Core utilities
│   ├── constants/         # App constants
│   ├── i18n/             # Đa ngôn ngữ (Vi/En)
│   ├── network/          # Dio HTTP client
│   └── providers/        # Riverpod providers
├── features/             # Các tính năng chính
│   ├── auth/             # Xác thực người dùng
│   ├── search/           # Tìm kiếm chuyến đi
│   ├── results/          # Kết quả tìm kiếm
│   ├── booking/          # Đặt vé
│   ├── tickets/          # Vé điện tử
│   └── profile/          # Tài khoản
└── shared/               # Widgets dùng chung
```

### Backend (Node.js)
```
backend/
├── src/
│   ├── config/           # Database, Redis config
│   ├── models/           # MongoDB models
│   ├── routes/           # API routes
│   ├── services/         # Business logic
│   ├── middleware/       # Auth, validation
│   └── utils/            # Helper functions
├── scripts/              # Database setup scripts
└── logs/                 # Application logs
```

**Tech Stack:**
- **Frontend**: Flutter, Riverpod, GoRouter, Material 3
- **Backend**: Node.js, Express, MongoDB, Redis
- **Payment**: VNPay integration với WebView
- **Real-time**: Socket.IO
- **Storage**: Hive (local), MongoDB (server)

## ✨ Tính năng đã hoàn thành

### 🔍 Trang tìm kiếm chính
- Tab chuyển đổi giữa các phương tiện (Flight/Train/Bus/Ferry)
- Form tìm kiếm với validation đầy đủ
- Popular destinations carousel
- Recent searches history
- Material 3 design đẹp mắt

### 🧭 Navigation hiện đại
- **NavigationBar Material 3** thay vì BottomNavigationBar cũ
- Haptic feedback khi tap
- Smooth animations
- Badge system sẵn sàng cho notifications
- Icons outlined/filled cho states

### 🎨 UI/UX
- **Material 3 Design Language**
- Light/Dark theme support
- Responsive design
- Vietnamese/English localization
- Clean và modern interface

## 🚀 Cách chạy dự án

### 📋 Yêu cầu hệ thống
- **Flutter SDK** >= 3.19.0
- **Node.js** >= 18.0.0
- **MongoDB** >= 6.0
- **Redis** (tùy chọn, cho caching)

### 🔧 Cài đặt Backend

**Cài đặt MongoDB**
```bash
# Ubuntu/Debian
sudo apt-get install mongodb

# macOS với Homebrew
brew install mongodb-community

# Windows: Tải từ https://www.mongodb.com/try/download/community
```
### 📱 Clone du an ve

```bash
# Clone repository
git clone https://github.com/vuong20031591-hub/DatVe360.git
cd DatVe360

1. **Setup Backend**
```bash
# Di chuyển vào thư mục backend
cd backend

# Cài đặt dependencies
npm install

# Copy file cấu hình
cp .env.example .env

# Chỉnh sửa file .env với thông tin database của bạn
# MONGODB_URI=mongodb://localhost:27017/datve360
```

2. **Khởi tạo Database & Dữ liệu mẫu**
```bash
# Tạo database và collections
npm run db:init

# Thêm dữ liệu mẫu (destinations, schedules, users)
npm run db:seed

# Hoặc chạy cả hai lệnh
npm run db:reset
```

3. **Chạy Backend Server**
```bash
# Vào thư mục backend
cd backend

# Development mode với nodemon
npm run dev

# Production mode
npm start

# Server sẽ chạy tại http://localhost:5000
```

4. **Chạy Frontend**

```bash
# Cài đặt dependencies
flutter pub get

# Chạy code generation (nếu cần)
dart run build_runner build

# Chạy app
flutter run
```

### 🗄️ Cấu trúc Database

**Collections chính:**
- `users` - Thông tin người dùng và xác thực
- `destinations` - Sân bay, ga tàu, bến xe, cảng
- `schedules` - Lịch trình các chuyến đi
- `bookings` - Thông tin đặt vé
- `tickets` - Vé điện tử
- `payments` - Lịch sử thanh toán

**Dữ liệu mẫu bao gồm:**
- 3 tài khoản test (admin, operator, user)
- 15+ destinations (sân bay, ga tàu, bến xe)
- Sample schedules cho các tuyến phổ biến
- Cấu hình VNPay sandbox

**Tài khoản test:**
```
Admin: admin@datve360.com / 123456
Operator: operator@datve360.com / 123456
User: user@example.com / 123456
```

## 📱 Screenshots

*chua cap nhat*

## 🎓 Điều mình học được

Qua dự án này, mình đã học được rất nhiều:

1. **Clean Architecture** - Cách tổ chức code professional
2. **State Management** - Sử dụng Riverpod 2.x hiệu quả
3. **Material 3** - Design system mới nhất của Google
4. **Navigation** - GoRouter + Navigator hybrid approach
5. **Localization** - Hỗ trợ đa ngôn ngữ (Vi/En)
6. **Backend Development** - Node.js, Express, MongoDB
7. **Payment Integration** - VNPay với WebView
8. **Real-time Features** - Socket.IO cho notifications
9. **Database Design** - MongoDB schema và indexing
10. **API Design** - RESTful APIs với proper error handling

## 🔮 Kế hoạch tiếp theo

### ✅ Đã hoàn thành
- [x] Clean Architecture setup
- [x] Material 3 UI/UX
- [x] GoRouter navigation
- [x] Riverpod state management
- [x] Backend API với MongoDB
- [x] VNPay payment integration
- [x] Ticket system với QR code
- [x] Multi-language support
- [x] Database seeding scripts

### 🚧 Đang phát triển
- [ ] Unit & Integration tests
- [ ] Push notifications
- [ ] Offline support với Hive
- [ ] Performance optimization
- [ ] Error tracking với Sentry

### 📋 Roadmap
- [ ] Deploy backend lên cloud (AWS/GCP)
- [ ] CI/CD pipeline
- [ ] Admin dashboard
- [ ] Mobile app deployment
- [ ] Load testing & monitoring

## 🛠️ API Documentation

### Base URL
```
Development: http://localhost:5000/api/v1
```

### Key Endpoints
```
Authentication:
POST /auth/login          # Đăng nhập
POST /auth/register       # Đăng ký
POST /auth/refresh        # Refresh token

Search & Booking:
GET  /destinations        # Danh sách điểm đến
GET  /schedules/search    # Tìm kiếm lịch trình
POST /bookings           # Tạo booking
GET  /bookings/:id       # Chi tiết booking

Payment:
POST /payments/vnpay/create    # Tạo thanh toán VNPay
GET  /payments/vnpay/return    # VNPay callback
```

## 🤝 Đóng góp

Mọi người có thể contribute bằng cách:

- 🐛 Report bugs qua GitHub Issues
- 💡 Suggest features mới
- 🔧 Submit pull requests
- 👀 Review code và documentation
- 📝 Cải thiện documentation

### Development Guidelines
1. Fork repository và tạo feature branch
2. Follow coding conventions (Flutter/Node.js best practices)
3. Viết tests cho features mới
4. Update documentation nếu cần
5. Submit PR với mô tả chi tiết

## 📞 Liên hệ

Nếu có câu hỏi gì về dự án, mọi người có thể liên hệ mình qua:

- 📧 **Email**: vuong20032604@gmail.com
- 📱 **Zalo**: 0397707745
- 🐙 **GitHub**: [@vuong20031591-hub](https://github.com/vuong20031591-hub)
- 🌐 **Repository**: [DatVe360](https://github.com/vuong20031591-hub/DatVe360)

---

**Cảm ơn mọi người đã quan tâm đến dự án DatVe360! 🙏**

*"Một ứng dụng - Mọi chuyến đi"* ✈️🚄🚌⛴️

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/vuong20031591-hub/DatVe360?style=social)
![GitHub forks](https://img.shields.io/github/forks/vuong20031591-hub/DatVe360?style=social)
![GitHub issues](https://img.shields.io/github/issues/vuong20031591-hub/DatVe360)
![GitHub license](https://img.shields.io/github/license/vuong20031591-hub/DatVe360)
