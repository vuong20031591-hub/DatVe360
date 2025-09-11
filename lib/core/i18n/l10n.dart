import 'package:flutter/material.dart';

/// App localizations
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Common
  String get appName => 'DatVe360';
  String get search => locale.languageCode == 'vi' ? 'Tìm kiếm' : 'Search';
  String get results => locale.languageCode == 'vi' ? 'Kết quả' : 'Results';
  String get profile => locale.languageCode == 'vi' ? 'Tài khoản' : 'Profile';
  String get cancel => locale.languageCode == 'vi' ? 'Hủy' : 'Cancel';
  String get confirm => locale.languageCode == 'vi' ? 'Xác nhận' : 'Confirm';
  String get save => locale.languageCode == 'vi' ? 'Lưu' : 'Save';
  String get loading => locale.languageCode == 'vi' ? 'Đang tải...' : 'Loading...';
  String get error => locale.languageCode == 'vi' ? 'Lỗi' : 'Error';
  String get retry => locale.languageCode == 'vi' ? 'Thử lại' : 'Retry';
  String get next => locale.languageCode == 'vi' ? 'Tiếp theo' : 'Next';
  String get back => locale.languageCode == 'vi' ? 'Quay lại' : 'Back';
  String get done => locale.languageCode == 'vi' ? 'Hoàn thành' : 'Done';

  // Transport modes
  String get flight => locale.languageCode == 'vi' ? 'Máy bay' : 'Flight';
  String get train => locale.languageCode == 'vi' ? 'Tàu hỏa' : 'Train';
  String get bus => locale.languageCode == 'vi' ? 'Xe khách' : 'Bus';
  String get ferry => locale.languageCode == 'vi' ? 'Phà' : 'Ferry';

  // Search
  String get from => locale.languageCode == 'vi' ? 'Từ' : 'From';
  String get to => locale.languageCode == 'vi' ? 'Đến' : 'To';
  String get departDate => locale.languageCode == 'vi' ? 'Ngày đi' : 'Departure Date';
  String get returnDate => locale.languageCode == 'vi' ? 'Ngày về' : 'Return Date';
  String get passengers => locale.languageCode == 'vi' ? 'Hành khách' : 'Passengers';
  String get adult => locale.languageCode == 'vi' ? 'Người lớn' : 'Adult';
  String get child => locale.languageCode == 'vi' ? 'Trẻ em' : 'Child';
  String get infant => locale.languageCode == 'vi' ? 'Em bé' : 'Infant';
  String get roundTrip => locale.languageCode == 'vi' ? 'Khứ hồi' : 'Round Trip';
  String get oneWay => locale.languageCode == 'vi' ? 'Một chiều' : 'One Way';
  String get searchTrips => locale.languageCode == 'vi' ? 'Tìm chuyến' : 'Search Trips';

  // Results
  String get sortBy => locale.languageCode == 'vi' ? 'Sắp xếp theo' : 'Sort by';
  String get filter => locale.languageCode == 'vi' ? 'Lọc' : 'Filter';
  String get price => locale.languageCode == 'vi' ? 'Giá' : 'Price';
  String get duration => locale.languageCode == 'vi' ? 'Thời gian' : 'Duration';
  String get departure => locale.languageCode == 'vi' ? 'Khởi hành' : 'Departure';
  String get arrival => locale.languageCode == 'vi' ? 'Đến nơi' : 'Arrival';
  String get carrier => locale.languageCode == 'vi' ? 'Hãng' : 'Carrier';
  String get noResults => locale.languageCode == 'vi' ? 'Không có kết quả' : 'No results found';

  // Booking
  String get selectSeat => locale.languageCode == 'vi' ? 'Chọn ghế' : 'Select Seat';
  String get passengerInfo => locale.languageCode == 'vi' ? 'Thông tin hành khách' : 'Passenger Information';
  String get payment => locale.languageCode == 'vi' ? 'Thanh toán' : 'Payment';
  String get firstName => locale.languageCode == 'vi' ? 'Tên' : 'First Name';
  String get lastName => locale.languageCode == 'vi' ? 'Họ' : 'Last Name';
  String get dateOfBirth => locale.languageCode == 'vi' ? 'Ngày sinh' : 'Date of Birth';
  String get documentId => locale.languageCode == 'vi' ? 'CMND/CCCD' : 'ID Number';
  String get email => locale.languageCode == 'vi' ? 'Email' : 'Email';
  String get phone => locale.languageCode == 'vi' ? 'Số điện thoại' : 'Phone Number';

  // Ticket
  String get ticket => locale.languageCode == 'vi' ? 'Vé' : 'Ticket';
  String get bookingId => locale.languageCode == 'vi' ? 'Mã đặt vé' : 'Booking ID';
  String get downloadPdf => locale.languageCode == 'vi' ? 'Tải PDF' : 'Download PDF';
  String get shareTicket => locale.languageCode == 'vi' ? 'Chia sẻ vé' : 'Share Ticket';

  // Status
  String get available => locale.languageCode == 'vi' ? 'Trống' : 'Available';
  String get booked => locale.languageCode == 'vi' ? 'Đã đặt' : 'Booked';
  String get selected => locale.languageCode == 'vi' ? 'Đang chọn' : 'Selected';
  String get confirmed => locale.languageCode == 'vi' ? 'Đã xác nhận' : 'Confirmed';
  String get cancelled => locale.languageCode == 'vi' ? 'Đã hủy' : 'Cancelled';
  String get pending => locale.languageCode == 'vi' ? 'Đang xử lý' : 'Pending';
  String get completed => locale.languageCode == 'vi' ? 'Hoàn thành' : 'Completed';

  // Validation messages
  String get fieldRequired => locale.languageCode == 'vi' ? 'Trường này là bắt buộc' : 'This field is required';
  String get invalidEmail => locale.languageCode == 'vi' ? 'Email không hợp lệ' : 'Invalid email';
  String get invalidPhone => locale.languageCode == 'vi' ? 'Số điện thoại không hợp lệ' : 'Invalid phone number';
  String get fromToSame => locale.languageCode == 'vi' ? 'Điểm đi và điểm đến không được trùng nhau' : 'From and To cannot be the same';
  String get pastDate => locale.languageCode == 'vi' ? 'Không thể chọn ngày trong quá khứ' : 'Cannot select past date';
  String get returnBeforeDepart => locale.languageCode == 'vi' ? 'Ngày về phải sau ngày đi' : 'Return date must be after departure date';
  String get minPassengers => locale.languageCode == 'vi' ? 'Phải có ít nhất 1 người lớn' : 'Must have at least 1 adult';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
