import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../models/search_query.dart';
import '../../../results/data/models/trip.dart';

class SearchRepository {
  final DioClient _dioClient;
  final CacheService _cacheService;
  final ConnectivityService _connectivityService;

  SearchRepository(this._dioClient)
    : _cacheService = CacheService.instance,
      _connectivityService = ConnectivityService.instance;

  // Search for trips with caching
  Future<List<Trip>> searchTrips(SearchQuery query) async {
    try {
      final cacheKey = query.cacheKey;

      // Try to get from cache first
      final cachedResults = _cacheService.getCachedSearchResults(cacheKey);
      if (cachedResults != null) {
        return cachedResults.map((json) => Trip.fromJson(json)).toList();
      }

      // If offline and no cache, throw error
      if (!_connectivityService.isOnline) {
        throw Exception(
          'Không có kết nối mạng và không tìm thấy dữ liệu đã lưu',
        );
      }

      // Get fresh data (for now, use mock data)
      final trips = await _getMockTrips(query);

      // Cache the results
      final tripsJson = trips.map((trip) => trip.toJson()).toList();
      await _cacheService.cacheSearchResults(cacheKey, tripsJson);

      return trips;

      // TODO: Implement real API call
      // final response = await _dioClient.post('/search', data: query.toJson());
      // final List<dynamic> data = response.data['trips'];
      // final trips = data.map((json) => Trip.fromJson(json)).toList();
      // await _cacheService.cacheSearchResults(cacheKey, data);
      // return trips;
    } catch (e) {
      throw Exception('Failed to search trips: $e');
    }
  }

  // Get popular destinations with caching
  Future<List<Map<String, dynamic>>> getPopularDestinations() async {
    try {
      // Try to get from cache first
      final cachedDestinations = _cacheService.getCachedDestinations();
      if (cachedDestinations != null) {
        return cachedDestinations;
      }

      // Load from assets (fallback for offline)
      final String response = await rootBundle.loadString(
        'assets/data/mock_data.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      final destinations = List<Map<String, dynamic>>.from(
        data['popular_routes'],
      );

      // Cache the results
      await _cacheService.cacheDestinations(destinations);

      return destinations;
    } catch (e) {
      throw Exception('Failed to load popular destinations: $e');
    }
  }

  // Get airports with caching
  Future<List<Map<String, dynamic>>> getAirports() async {
    try {
      // Try to get from cache first
      final cachedAirports = _cacheService.getCachedAirports();
      if (cachedAirports != null) {
        return cachedAirports;
      }

      // Load from assets (fallback for offline)
      final String response = await rootBundle.loadString(
        'assets/data/mock_data.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      final airports = List<Map<String, dynamic>>.from(data['airports']);

      // Cache the results
      await _cacheService.cacheAirports(airports);

      return airports;
    } catch (e) {
      throw Exception('Failed to load airports: $e');
    }
  }

  // Search airports by query
  Future<List<Map<String, dynamic>>> searchAirports(String query) async {
    try {
      final airports = await getAirports();
      if (query.isEmpty) return airports;

      return airports.where((airport) {
        final name = airport['name'].toString().toLowerCase();
        final city = airport['city'].toString().toLowerCase();
        final code = airport['code'].toString().toLowerCase();
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
            city.contains(searchQuery) ||
            code.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search airports: $e');
    }
  }

  // Mock data for development
  Future<List<Trip>> _getMockTrips(SearchQuery query) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final String response = await rootBundle.loadString(
      'assets/data/mock_data.json',
    );
    final Map<String, dynamic> data = json.decode(response);
    final List<dynamic> sampleTrips = data['sample_trips'];

    // Filter trips based on search query
    final filteredTrips = sampleTrips.where((tripData) {
      return tripData['from'] == query.from && tripData['to'] == query.to;
    }).toList();

    // Convert to Trip objects
    final trips = <Trip>[];
    for (final tripData in filteredTrips) {
      final classes = (tripData['classes'] as List).map((classData) {
        return ClassOption(
          id: classData['id'],
          name: classData['name'],
          displayName: classData['displayName'] ?? classData['name'],
          price: (classData['price'] as num).toDouble(),
          priceAddon: (classData['priceAddon'] as num?)?.toDouble() ?? 0,
          amenities: List<String>.from(classData['amenities']),
          metadata: {
            'availableSeats': classData['availableSeats'],
            'baggage': classData['baggage'],
            'refundPolicy': classData['refundPolicy'],
            'changePolicy': classData['changePolicy'],
          },
        );
      }).toList();

      final departDate = DateTime.parse(tripData['departDate']);
      final arriveDate = DateTime.parse(tripData['arriveDate']);

      trips.add(
        Trip(
          id: tripData['id'],
          carrierId: tripData['carrierCode'],
          carrierName: tripData['carrier'],
          carrierLogo: tripData['carrierLogo'],
          mode: TransportMode.flight,
          from: tripData['fromName'],
          fromCode: tripData['from'],
          to: tripData['toName'],
          toCode: tripData['to'],
          departAt: departDate,
          arriveAt: arriveDate,
          duration: arriveDate.difference(departDate),
          basePrice: (tripData['basePrice'] as num?)?.toDouble() ?? 1200000,
          currency: 'VND',
          stops: List<String>.from(tripData['stops'] ?? []),
          classOptions: classes,
          metadata: {
            'aircraft': tripData['aircraft'],
            'flightNumber': tripData['flightNumber'],
          },
        ),
      );
    }

    // If no trips found, return some sample data
    if (trips.isEmpty) {
      return _generateSampleTrips(query);
    }

    return trips;
  }

  List<Trip> _generateSampleTrips(SearchQuery query) {
    final basePrice = _getBasePrice(query.from, query.to);
    final departAt = query.departDate.copyWith(hour: 6, minute: 0);
    final arriveAt = query.departDate.copyWith(hour: 8, minute: 15);

    return [
      Trip(
        id: 'VN210_${query.departDate.millisecondsSinceEpoch}',
        carrierId: 'VN',
        carrierName: 'Vietnam Airlines',
        carrierLogo: null,
        mode: TransportMode.flight,
        from: '${_getCityName(query.from)} (${query.from})',
        fromCode: query.from,
        to: '${_getCityName(query.to)} (${query.to})',
        toCode: query.to,
        departAt: departAt,
        arriveAt: arriveAt,
        duration: arriveAt.difference(departAt),
        basePrice: basePrice.toDouble(),
        currency: 'VND',
        stops: [],
        classOptions: [
          ClassOption(
            id: 'economy',
            name: 'economy',
            displayName: 'Phổ thông',
            price: basePrice.toDouble(),
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
            price: (basePrice * 2.1),
            priceAddon: (basePrice * 1.1),
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
        ],
        metadata: {'aircraft': 'Airbus A321', 'flightNumber': 'VN210'},
      ),
      Trip(
        id: 'VJ150_${query.departDate.millisecondsSinceEpoch}',
        carrierId: 'VJ',
        carrierName: 'VietJet Air',
        carrierLogo: null,
        mode: TransportMode.flight,
        from: '${_getCityName(query.from)} (${query.from})',
        fromCode: query.from,
        to: '${_getCityName(query.to)} (${query.to})',
        toCode: query.to,
        departAt: query.departDate.copyWith(hour: 7, minute: 30),
        arriveAt: query.departDate.copyWith(hour: 9, minute: 45),
        duration: const Duration(hours: 2, minutes: 15),
        basePrice: (basePrice * 0.83),
        currency: 'VND',
        stops: [],
        classOptions: [
          ClassOption(
            id: 'economy',
            name: 'economy',
            displayName: 'Eco',
            price: (basePrice * 0.83),
            priceAddon: 0,
            amenities: ['Hành lý xách tay 7kg'],
            metadata: {
              'availableSeats': 38,
              'baggage': 'Không bao gồm',
              'refundPolicy': 'Không hoàn vé',
              'changePolicy': 'Đổi vé phí 300.000đ',
            },
          ),
          ClassOption(
            id: 'skyboss',
            name: 'skyboss',
            displayName: 'SkyBoss',
            price: (basePrice * 1.58),
            priceAddon: (basePrice * 0.75),
            amenities: [
              'Hành lý xách tay 10kg',
              'Suất ăn',
              'Chọn ghế miễn phí',
            ],
            metadata: {
              'availableSeats': 8,
              'baggage': '20kg hành lý ký gửi',
              'refundPolicy': 'Hoàn 50% phí vé trước 24h',
              'changePolicy': 'Đổi vé phí 150.000đ',
            },
          ),
        ],
        metadata: {'aircraft': 'Airbus A320', 'flightNumber': 'VJ150'},
      ),
    ];
  }

  int _getBasePrice(String from, String to) {
    // Simple price calculation based on route
    if ((from == 'HAN' && to == 'SGN') || (from == 'SGN' && to == 'HAN')) {
      return 1200000;
    } else if ((from == 'HAN' && to == 'DAD') ||
        (from == 'DAD' && to == 'HAN')) {
      return 800000;
    } else if ((from == 'SGN' && to == 'PQC') ||
        (from == 'PQC' && to == 'SGN')) {
      return 900000;
    }
    return 1000000; // Default price
  }

  String _getCityName(String airportCode) {
    switch (airportCode) {
      case 'HAN':
        return 'Hà Nội';
      case 'SGN':
        return 'TP.HCM';
      case 'DAD':
        return 'Đà Nẵng';
      case 'CXR':
        return 'Nha Trang';
      case 'PQC':
        return 'Phú Quốc';
      default:
        return airportCode;
    }
  }
}
