import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/trip.dart';

class TripRepository {
  // ignore: unused_field
  final DioClient _dioClient;

  TripRepository(this._dioClient);

  // Get trip details by ID
  Future<Trip?> getTripById(String tripId) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.get('/trips/$tripId');
      // return Trip.fromJson(response.data);

      // For now, return mock data
      return _getMockTripById(tripId);
    } catch (e) {
      throw Exception('Failed to get trip details: $e');
    }
  }

  // Get seat map for a trip and class
  Future<Map<String, dynamic>> getSeatMap(String tripId, String classId) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.get('/trips/$tripId/seats/$classId');
      // return response.data;

      // For now, return mock seat map
      return _getMockSeatMap(tripId, classId);
    } catch (e) {
      throw Exception('Failed to get seat map: $e');
    }
  }

  // Update seat selection
  Future<bool> updateSeatSelection(
    String tripId,
    String classId,
    List<String> seatIds,
  ) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.post('/trips/$tripId/seats/$classId/select',
      //   data: {'seats': seatIds});
      // return response.data['success'] ?? false;

      // For now, simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      throw Exception('Failed to update seat selection: $e');
    }
  }

  // Get available classes for a trip
  Future<List<ClassOption>> getTripClasses(String tripId) async {
    try {
      // TODO: Implement real API call
      // final response = await _dioClient.get('/trips/$tripId/classes');
      // final List<dynamic> data = response.data['classes'];
      // return data.map((json) => ClassOption.fromJson(json)).toList();

      // For now, return mock classes
      return _getMockTripClasses(tripId);
    } catch (e) {
      throw Exception('Failed to get trip classes: $e');
    }
  }

  // Mock data methods
  Trip? _getMockTripById(String tripId) {
    // Extract basic info from trip ID
    final parts = tripId.split('_');
    if (parts.length < 3) return null;

    final flightNumber = parts[0];
    final carrier = _getCarrierFromFlightNumber(flightNumber);
    final departDate = DateTime.now().add(const Duration(days: 7));

    return Trip(
      id: tripId,
      carrierId: flightNumber.substring(0, 2),
      carrierName: carrier,
      carrierLogo: null,
      mode: TransportMode.flight,
      from: 'Hà Nội (HAN)',
      fromCode: 'HAN',
      to: 'TP.HCM (SGN)',
      toCode: 'SGN',
      departAt: departDate.copyWith(hour: 6, minute: 0),
      arriveAt: departDate.copyWith(hour: 8, minute: 15),
      duration: const Duration(hours: 2, minutes: 15),
      basePrice: 1430000,
      currency: 'VND',
      stops: [],
      classOptions: _getMockTripClasses(tripId),
      metadata: {'aircraft': 'Airbus A321', 'flightNumber': flightNumber},
    );
  }

  List<ClassOption> _getMockTripClasses(String tripId) {
    return [
      ClassOption(
        id: 'economy',
        name: 'economy',
        displayName: 'Phổ thông',
        price: 1200000,
        priceAddon: 0,
        amenities: ['Hành lý xách tay 7kg', 'Suất ăn nhẹ', 'Nước uống'],
        metadata: {
          'availableSeats': 45,
          'baggage': '20kg hành lý ký gửi',
          'refundPolicy': 'Hoàn 70% phí vé trước 24h',
          'changePolicy': 'Đổi vé phí 200.000đ',
        },
      ),
      ClassOption(
        id: 'business',
        name: 'business',
        displayName: 'Thương gia',
        price: 2500000,
        priceAddon: 1300000,
        amenities: [
          'Hành lý xách tay 10kg',
          'Suất ăn cao cấp',
          'Rượu vang',
          'Ghế nằm',
        ],
        metadata: {
          'availableSeats': 12,
          'baggage': '30kg hành lý ký gửi',
          'refundPolicy': 'Hoàn 90% phí vé trước 2h',
          'changePolicy': 'Đổi vé miễn phí',
        },
      ),
    ];
  }

  Map<String, dynamic> _getMockSeatMap(String tripId, String classId) {
    if (classId == 'business') {
      return {
        'rows': 3,
        'columns': ['A', 'B', 'C', 'D'],
        'occupied_seats': ['2B', '3A'],
        'premium_seats': [],
        'exit_rows': [],
        'seats': _generateSeatData(3, ['A', 'B', 'C', 'D'], ['2B', '3A']),
      };
    } else {
      return {
        'rows': 20,
        'columns': ['A', 'B', 'C', 'D', 'E', 'F'],
        'occupied_seats': ['5A', '8F', '12C', '15B', '18E'],
        'premium_seats': [
          '1A',
          '1B',
          '1C',
          '1D',
          '1E',
          '1F',
          '2A',
          '2B',
          '2C',
          '2D',
          '2E',
          '2F',
        ],
        'exit_rows': [12, 13],
        'seats': _generateSeatData(
          20,
          ['A', 'B', 'C', 'D', 'E', 'F'],
          ['5A', '8F', '12C', '15B', '18E'],
        ),
      };
    }
  }

  List<Map<String, dynamic>> _generateSeatData(
    int rows,
    List<String> columns,
    List<String> occupiedSeats,
  ) {
    final seats = <Map<String, dynamic>>[];

    for (int row = 1; row <= rows; row++) {
      for (final col in columns) {
        final seatId = '$row$col';
        final isOccupied = occupiedSeats.contains(seatId);

        seats.add({
          'id': seatId,
          'row': row,
          'column': col,
          'status': isOccupied ? 'booked' : 'available',
          'type': 'standard',
          'price_addon': 0,
        });
      }
    }

    return seats;
  }

  String _getCarrierFromFlightNumber(String flightNumber) {
    final code = flightNumber.substring(0, 2);
    switch (code) {
      case 'VN':
        return 'Vietnam Airlines';
      case 'VJ':
        return 'VietJet Air';
      case 'BL':
        return 'Jetstar Pacific';
      case 'QH':
        return 'Bamboo Airways';
      default:
        return 'Unknown Carrier';
    }
  }
}
