/// Management section enum for admin dashboard
enum ManagementSection {
  dashboard('dashboard', 'Dashboard', 'Tổng quan'),
  destinations('destinations', 'Destinations', 'Điểm đến'),
  categories('categories', 'Categories', 'Danh mục vé'),
  tickets('tickets', 'Tickets', 'Vé'),
  users('users', 'Users', 'Người dùng'),
  bookings('bookings', 'Bookings', 'Đặt vé'),
  payments('payments', 'Payments', 'Thanh toán'),
  reports('reports', 'Reports', 'Báo cáo'),
  settings('settings', 'Settings', 'Cài đặt');

  const ManagementSection(this.value, this.displayName, this.vietnameseName);
  
  final String value;
  final String displayName;
  final String vietnameseName;
}

