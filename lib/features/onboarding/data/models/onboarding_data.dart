/// Onboarding screen data model
class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;
  final String? lottieAsset;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.lottieAsset,
  });

  static List<OnboardingData> get screens => [
        const OnboardingData(
          title: 'Đặt vé dễ dàng',
          subtitle: 'Máy bay  ·  Tàu hỏa  ·  Xe khách  – tất cả trong một ứng dụng',
          imagePath: 'assets/images/onboarding_1.png',
          lottieAsset: 'assets/lottie/transport_booking.json',
        ),
        const OnboardingData(
          title: 'Thanh toán an toàn',
          subtitle: 'Hỗ trợ nhiều phương thức – Nhanh chóng – Bảo mật',
          imagePath: 'assets/images/onboarding_2.png',
          lottieAsset: 'assets/lottie/secure_payment.json',
        ),
        const OnboardingData(
          title: 'Vé điện tử tiện lợi',
          subtitle: 'Nhận e-ticket (QR/PDF) ngay sau khi thanh toán',
          imagePath: 'assets/images/onboarding_3.png',
          lottieAsset: 'assets/lottie/digital_ticket.json',
        ),
      ];
}
