import 'package:freezed_annotation/freezed_annotation.dart';
import '../../booking/data/models/booking.dart';

part 'ticket.freezed.dart';
part 'ticket.g.dart';

@freezed
class Ticket with _$Ticket {
  const factory Ticket({
    required String id,
    required String bookingId,
    required String pnr,
    required String qrData,
    String? pdfPath,
    required DateTime issuedAt,
    DateTime? validUntil,
    @Default(false) bool isUsed,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Ticket;

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
}

@freezed
class QRTicketData with _$QRTicketData {
  const factory QRTicketData({
    required String bookingId,
    required String pnr,
    required String passengerName,
    required String from,
    required String to,
    required DateTime departAt,
    required String seatNumber,
    required String carrierName,
    required DateTime issuedAt,
  }) = _QRTicketData;

  factory QRTicketData.fromJson(Map<String, dynamic> json) =>
      _$QRTicketDataFromJson(json);
}

extension TicketX on Ticket {
  bool get isValid {
    if (isUsed) return false;
    if (validUntil != null && DateTime.now().isAfter(validUntil!)) {
      return false;
    }
    return true;
  }
  
  bool get isExpired {
    return validUntil != null && DateTime.now().isAfter(validUntil!);
  }
  
  String get statusText {
    if (isUsed) return 'Đã sử dụng';
    if (isExpired) return 'Đã hết hạn';
    return 'Có hiệu lực';
  }
  
  bool get hasPdf => pdfPath != null && pdfPath!.isNotEmpty;
}

extension QRTicketDataX on QRTicketData {
  String toQRString() {
    return 'DATVE360|$bookingId|$pnr|$passengerName|$from|$to|'
        '${departAt.millisecondsSinceEpoch}|$seatNumber|$carrierName|'
        '${issuedAt.millisecondsSinceEpoch}';
  }
  
  static QRTicketData? fromQRString(String qrString) {
    try {
      final parts = qrString.split('|');
      if (parts.length != 10 || parts[0] != 'DATVE360') return null;
      
      return QRTicketData(
        bookingId: parts[1],
        pnr: parts[2],
        passengerName: parts[3],
        from: parts[4],
        to: parts[5],
        departAt: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[6])),
        seatNumber: parts[7],
        carrierName: parts[8],
        issuedAt: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[9])),
      );
    } catch (e) {
      return null;
    }
  }
}
