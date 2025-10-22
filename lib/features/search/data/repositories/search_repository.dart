import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../models/search_query.dart';
import '../../../results/data/models/trip.dart';
import './real_search_repository.dart';

// Provider for SearchRepository (uses RealSearchRepository for popular destinations)
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(DioClient.instance);
});

// Provider for RealSearchRepository (has getPopularDestinations)
final realSearchRepositoryProvider = Provider<RealSearchRepository>((ref) {
  return RealSearchRepository(DioClient.instance);
});

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

      // Make API call to search schedules
      final response = await _dioClient.get(
        '/schedules/search',
        queryParameters: {
          'from': query.from,
          'to': query.to,
          'departDate': query.departDate.toIso8601String(),
          'mode': query.mode.value,
          'passengers': query.passengers.total,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> schedulesData =
            response.data['data']['schedules'] ?? [];

        // Convert schedules to Trip objects
        final trips = schedulesData.map((json) => Trip.fromJson(json)).toList();

        // Cache the results
        final tripsJson = trips.map((trip) => trip.toJson()).toList();
        await _cacheService.cacheSearchResults(cacheKey, tripsJson);

        return trips;
      } else {
        throw Exception(
          response.data['message'] ?? 'Không tìm thấy chuyến đi phù hợp',
        );
      }
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

      // If offline and no cache, throw error
      if (!_connectivityService.isOnline) {
        throw Exception(
          'Không có kết nối mạng và không tìm thấy dữ liệu đã lưu',
        );
      }

      // Make API call to get popular destinations
      final response = await _dioClient.get('/destinations/popular');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> destinationsData = response.data['data'] ?? [];
        final destinations = List<Map<String, dynamic>>.from(destinationsData);

        // Cache the results
        await _cacheService.cacheDestinations(destinations);

        return destinations;
      } else {
        throw Exception('Không thể tải danh sách điểm đến');
      }
    } catch (e) {
      rethrow;
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

      // If offline and no cache, throw error
      if (!_connectivityService.isOnline) {
        throw Exception(
          'Không có kết nối mạng và không tìm thấy dữ liệu đã lưu',
        );
      }

      // Make API call to get all destinations (airports, stations, ports)
      final response = await _dioClient.get('/destinations');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> destinationsData = response.data['data'] ?? [];
        final airports = List<Map<String, dynamic>>.from(destinationsData);

        // Cache the results
        await _cacheService.cacheAirports(airports);

        return airports;
      } else {
        throw Exception('Không thể tải danh sách điểm đến');
      }
    } catch (e) {
      rethrow;
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

  // Get destinations that have outgoing routes (có route đi)
  Future<List<Map<String, dynamic>>> getDestinationsFrom(
    String transportType,
  ) async {
    try {
      // Check connectivity
      if (!_connectivityService.isOnline) {
        throw Exception('Không có kết nối mạng. Vui lòng kiểm tra lại.');
      }

      final response = await _dioClient.get(
        '/destinations/from',
        queryParameters: {'transportType': transportType},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Không thể tải danh sách điểm đi');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Không thể tải danh sách điểm đi');
    }
  }

  // Get destinations that have routes from a specific origin
  Future<List<Map<String, dynamic>>> getDestinationsTo(
    String fromCode,
    String transportType,
  ) async {
    try {
      // Check connectivity
      if (!_connectivityService.isOnline) {
        throw Exception('Không có kết nối mạng. Vui lòng kiểm tra lại.');
      }

      final response = await _dioClient.get(
        '/destinations/to',
        queryParameters: {'from': fromCode, 'transportType': transportType},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Không thể tải danh sách điểm đến');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Không thể tải danh sách điểm đến');
    }
  }
}
