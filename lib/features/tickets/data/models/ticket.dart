class Ticket {
  final String id;
  final String bookingId;
  final String pnr;
  final String qrData;
  final String? pdfPath;
  final DateTime issuedAt;
  final DateTime? validUntil;
  final bool isUsed;
  final Map<String, dynamic> metadata;

  const Ticket({
    required this.id,
    required this.bookingId,
    required this.pnr,
    required this.qrData,
    this.pdfPath,
    required this.issuedAt,
    this.validUntil,
    this.isUsed = false,
    this.metadata = const {},
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      pnr: json['pnr'] ?? '',
      qrData: json['qrData'] ?? '',
      pdfPath: json['pdfPath'],
      issuedAt: DateTime.parse(
        json['issuedAt'] ?? DateTime.now().toIso8601String(),
      ),
      validUntil: json['validUntil'] != null
          ? DateTime.parse(json['validUntil'])
          : null,
      isUsed: json['isUsed'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'pnr': pnr,
      'qrData': qrData,
      'pdfPath': pdfPath,
      'issuedAt': issuedAt.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'isUsed': isUsed,
      'metadata': metadata,
    };
  }
}

class QRTicketData {
  final String bookingId;
  final String pnr;
  final String passengerName;
  final String from;
  final String to;
  final DateTime departAt;
  final String seatNumber;
  final String carrierName;
  final DateTime issuedAt;

  const QRTicketData({
    required this.bookingId,
    required this.pnr,
    required this.passengerName,
    required this.from,
    required this.to,
    required this.departAt,
    required this.seatNumber,
    required this.carrierName,
    required this.issuedAt,
  });

  factory QRTicketData.fromJson(Map<String, dynamic> json) {
    return QRTicketData(
      bookingId: json['bookingId'] ?? '',
      pnr: json['pnr'] ?? '',
      passengerName: json['passengerName'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      departAt: DateTime.parse(
        json['departAt'] ?? DateTime.now().toIso8601String(),
      ),
      seatNumber: json['seatNumber'] ?? '',
      carrierName: json['carrierName'] ?? '',
      issuedAt: DateTime.parse(
        json['issuedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'pnr': pnr,
      'passengerName': passengerName,
      'from': from,
      'to': to,
      'departAt': departAt.toIso8601String(),
      'seatNumber': seatNumber,
      'carrierName': carrierName,
      'issuedAt': issuedAt.toIso8601String(),
    };
  }
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
