import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/network/dio_client.dart';
import '../models/search_query.dart';
import '../../../results/data/models/trip.dart';

class SearchRepository {
  final DioClient _dioClient;

  SearchRepository(this._dioClient);

  // Search for trips
  Future<List<Trip>> searchTrips(SearchQuery query) async {
    try {
      // For now, use mock data
      return await _getMockTrips(query);
      
      // TODO: Implement real API call
      // final response = await _dioClient.post('/search', data: query.toJson());
      // final List<dynamic> data = response.data['trips'];
      // return data.map((json) => Trip.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search trips: $e');
    }
  }

  // Get popular destinations
  Future<List<Map<String, dynamic>>> getPopularDestinations() async {
    try {
      final String response = await rootBundle.loadString('assets/data/mock_data.json');
      final Map<String, dynamic> data = json.decode(response);
      return List<Map<String, dynamic>>.from(data['popular_routes']);
    } catch (e) {
      throw Exception('Failed to load popular destinations: $e');
    }
  }

  // Get airports
  Future<List<Map<String, dynamic>>> getAirports() async {
    try {
      final String response = await rootBundle.loadString('assets/data/mock_data.json');
      final Map<String, dynamic> data = json.decode(response);
      return List<Map<String, dynamic>>.from(data['airports']);
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
    
    final String response = await rootBundle.loadString('assets/data/mock_data.json');
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
          price: classData['price'],
          availableSeats: classData['availableSeats'],
          amenities: List<String>.from(classData['amenities']),
          baggage: classData['baggage'],
          refundPolicy: classData['refundPolicy'],
          changePolicy: classData['changePolicy'],
        );
      }).toList();
      
      trips.add(Trip(
        id: tripData['id'],
        carrier: tripData['carrier'],
        carrierCode: tripData['carrierCode'],
        flightNumber: tripData['flightNumber'],
        from: tripData['from'],
        to: tripData['to'],
        fromName: tripData['fromName'],
        toName: tripData['toName'],
        departTime: tripData['departTime'],
        arriveTime: tripData['arriveTime'],
        departDate: DateTime.parse(tripData['departDate']),
        arriveDate: DateTime.parse(tripData['arriveDate']),
        duration: tripData['duration'],
        aircraft: tripData['aircraft'],
        classes: classes,
      ));
    }
    
    // If no trips found, return some sample data
    if (trips.isEmpty) {
      return _generateSampleTrips(query);
    }
    
    return trips;
  }

  List<Trip> _generateSampleTrips(SearchQuery query) {
    final basePrice = _getBasePrice(query.from, query.to);
    
    return [
      Trip(
        id: 'VN210_${query.departDate.millisecondsSinceEpoch}',
        carrier: 'Vietnam Airlines',
        carrierCode: 'VN',
        flightNumber: 'VN210',
        from: query.from,
        to: query.to,
        fromName: '${_getCityName(query.from)} (${query.from})',
        toName: '${_getCityName(query.to)} (${query.to})',
        departTime: '06:00',
        arriveTime: '08:15',
        departDate: query.departDate,
        arriveDate: query.departDate,
        duration: '2h 15m',
        aircraft: 'Airbus A321',
        classes: [
          ClassOption(
            id: 'economy',
            name: 'Phổ thông',
            price: basePrice,
            availableSeats: 45,
            amenities: ['Hành lý xách tay 7kg', 'Suất ăn nhẹ', 'Nước uống'],
            baggage: '20kg hành lý ký gửi',
            refundPolicy: 'Hoàn 70% phí vé trước 24h',
            changePolicy: 'Đổi vé phí 200.000đ',
          ),
          ClassOption(
            id: 'business',
            name: 'Thương gia',
            price: (basePrice * 2.1).round(),
            availableSeats: 12,
            amenities: ['Hành lý xách tay 10kg', 'Suất ăn cao cấp', 'Rượu vang', 'Ghế nằm'],
            baggage: '30kg hành lý ký gửi',
            refundPolicy: 'Hoàn 90% phí vé trước 2h',
            changePolicy: 'Đổi vé miễn phí',
          ),
        ],
      ),
      Trip(
        id: 'VJ150_${query.departDate.millisecondsSinceEpoch}',
        carrier: 'VietJet Air',
        carrierCode: 'VJ',
        flightNumber: 'VJ150',
        from: query.from,
        to: query.to,
        fromName: '${_getCityName(query.from)} (${query.from})',
        toName: '${_getCityName(query.to)} (${query.to})',
        departTime: '07:30',
        arriveTime: '09:45',
        departDate: query.departDate,
        arriveDate: query.departDate,
        duration: '2h 15m',
        aircraft: 'Airbus A320',
        classes: [
          ClassOption(
            id: 'economy',
            name: 'Eco',
            price: (basePrice * 0.83).round(),
            availableSeats: 38,
            amenities: ['Hành lý xách tay 7kg'],
            baggage: 'Không bao gồm',
            refundPolicy: 'Không hoàn vé',
            changePolicy: 'Đổi vé phí 300.000đ',
          ),
          ClassOption(
            id: 'skyboss',
            name: 'SkyBoss',
            price: (basePrice * 1.58).round(),
            availableSeats: 8,
            amenities: ['Hành lý xách tay 10kg', 'Suất ăn', 'Chọn ghế miễn phí'],
            baggage: '20kg hành lý ký gửi',
            refundPolicy: 'Hoàn 50% phí vé trước 24h',
            changePolicy: 'Đổi vé phí 150.000đ',
          ),
        ],
      ),
    ];
  }

  int _getBasePrice(String from, String to) {
    // Simple price calculation based on route
    if ((from == 'HAN' && to == 'SGN') || (from == 'SGN' && to == 'HAN')) {
      return 1200000;
    } else if ((from == 'HAN' && to == 'DAD') || (from == 'DAD' && to == 'HAN')) {
      return 800000;
    } else if ((from == 'SGN' && to == 'PQC') || (from == 'PQC' && to == 'SGN')) {
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
