# DatVe360 - Ứng dụng đặt vé đa phương tiện 🚀

Xin chào mọi người! Mình xin giới thiệu về dự án **DatVe360** - một ứng dụng mobile đặt vé tích hợp đa phương tiện giao thông mà mình vừa hoàn thành.

## 🎯 Ý tưởng dự án

Bạn biết đấy, việc đặt vé máy bay, tàu hỏa, xe khách hay phà hiện tại phải vào từng app riêng biệt rất bất tiện. Vì vậy mình đã nghĩ ra ý tưởng tạo một ứng dụng **"all-in-one"** để người dùng có thể:

- 🛫 Đặt vé máy bay
- 🚄 Đặt vé tàu hỏa
- 🚌 Đặt vé xe khách
- ⛴️ Đặt vé phà

Tất cả trong một ứng dụng duy nhất!

## 🏗️ Kiến trúc và công nghệ

Mình đã áp dụng **Clean Architecture** để dự án dễ maintain và scale:

```
lib/
├── app/                    # Cấu hình app chính
│   ├── router/            # GoRouter navigation
│   └── theme/             # Material 3 theme
├── core/                  # Core utilities
│   ├── constants/         # App constants
│   ├── i18n/             # Đa ngôn ngữ (Vi/En)
│   └── providers/        # Riverpod providers
├── features/             # Các tính năng chính
│   ├── search/           # Tìm kiếm chuyến đi
│   ├── results/          # Kết quả tìm kiếm
│   ├── booking/          # Đặt vé
│   ├── manage/           # Quản lý booking
│   ├── tickets/          # Vé điện tử
│   └── profile/          # Tài khoản
└── shared/               # Widgets dùng chung
```

**Tech Stack:**
- **Flutter** - Framework chính
- **Riverpod** - State management
- **GoRouter** - Navigation
- **Hive** - Local storage
- **Firebase** - Backend services
- **Material 3** - Design system

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

```bash
# Clone repository
git clone https://github.com/vuong20031591-hub/DatVe360.git
cd DatVe360

# Cài đặt dependencies
flutter pub get

# Chạy app
flutter run
```

## 📱 Screenshots

*Sẽ cập nhật screenshots sau khi test trên thiết bị thật*

## 🎓 Điều mình học được

Qua dự án này, mình đã học được rất nhiều:

1. **Clean Architecture** - Cách tổ chức code professional
2. **State Management** - Sử dụng Riverpod hiệu quả
3. **Material 3** - Design system mới nhất của Google
4. **Navigation** - GoRouter cho complex routing
5. **Localization** - Hỗ trợ đa ngôn ngữ
6. **Performance** - Optimize app cho mobile

## 🔮 Kế hoạch tiếp theo

- [ ] Hoàn thiện booking flow
- [ ] Tích hợp payment gateway
- [ ] QR code cho vé điện tử
- [ ] Push notifications
- [ ] Offline support
- [ ] Unit tests
- [ ] Deploy lên Google Play Store

## 🤝 Đóng góp

Mọi người có thể contribute bằng cách:
- Report bugs
- Suggest features
- Submit pull requests
- Review code

## 📞 Liên hệ

Nếu có câu hỏi gì về dự án, mọi người có thể liên hệ mình qua:
- Email: vuong20032604@gmail.com
- Zalo: 0397707745
- GitHub: @vuong20031591-hub

---

**Cảm ơn mọi người đã quan tâm đến dự án DatVe360! 🙏**

*"Một ứng dụng - Mọi chuyến đi"* ✈️🚄🚌⛴️
