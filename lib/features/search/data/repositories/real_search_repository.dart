import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../models/search_query.dart';
import '../models/schedule.dart';

class RealSearchRepository {
  final DioClient _dioClient;
  final CacheService _cacheService;
  final ConnectivityService _connectivityService;

  RealSearchRepository(this._dioClient)
    : _cacheService = CacheService.instance,
      _connectivityService = ConnectivityService.instance;

  /// Search schedules using Backend API
  Future<SearchResponse> searchSchedules(
    SearchQuery query, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final cacheKey = query.cacheKey;

      // Try to get from cache first
      final cachedResults = _cacheService.getCachedSearchResults(cacheKey);
      if (cachedResults != null) {
        return SearchResponse.fromJson({
          'data': {
            'schedules': cachedResults,
            'pagination': {
              'total': cachedResults.length,
              'current': 1,
              'pages': 1,
              'limit': 50,
            },
            'filters': {},
          },
        });
      }

      // If offline and no cache, throw error
      if (!_connectivityService.isOnline) {
        throw Exception(
          'Không có kết nối mạng và không tìm thấy dữ liệu đã lưu',
        );
      }

      // Prepare API parameters
      final params = {
        'from': query.from,
        'to': query.to,
        'departureDate': query.departDate.toIso8601String().split('T')[0],
        'passengers': query.passengers.total,
        'transportType': _mapTransportMode(query.mode),
        'limit': limit,
        'page': page,
      };

      if (query.returnDate != null) {
        params['returnDate'] = query.returnDate!.toIso8601String().split(
          'T',
        )[0];
      }

      // Make API call
      final response = await _dioClient.get(
        '/schedules/search',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final searchResponse = SearchResponse.fromJson(response.data);

        // Cache the results (only cache the schedules list)
        final schedules = response.data['data']['schedules'] as List? ?? [];
        await _cacheService.cacheSearchResults(
          cacheKey,
          List<Map<String, dynamic>>.from(schedules),
        );

        return searchResponse;
      } else {
        throw Exception('API returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy chuyến bay phù hợp');
      } else if (e.response?.statusCode == 400) {
        final errorMessage =
            e.response?.data['message'] ?? 'Thông tin tìm kiếm không hợp lệ';
        throw Exception(errorMessage);
      } else {
        throw Exception('Lỗi kết nối: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi tìm kiếm: $e');
    }
  }

  /// Get popular destinations
  Future<List<Map<String, dynamic>>> getPopularDestinations() async {
    try {
      // Try to get from cache first
      final cachedDestinations = _cacheService.getCachedDestinations();
      if (cachedDestinations != null) {
        return cachedDestinations;
      }

      // If offline, return empty list
      if (!_connectivityService.isOnline) {
        return [];
      }

      // Make API call to get destinations
      final response = await _dioClient.get('/destinations/popular');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        List<Map<String, dynamic>> destinations = [];

        if (data is List) {
          destinations = List<Map<String, dynamic>>.from(data);
        }

        // Cache the results
        await _cacheService.cacheDestinations(destinations);

        return destinations;
      } else {
        return [];
      }
    } catch (e) {
      // Return empty list on error, don't throw
      return [];
    }
  }

  /// Search destinations/airports
  Future<List<Map<String, dynamic>>> searchDestinations(String query) async {
    try {
      if (query.isEmpty) return [];

      // If offline, return empty list
      if (!_connectivityService.isOnline) {
        return [];
      }

      // Make API call to search destinations
      final response = await _dioClient.get(
        '/destinations/search',
        queryParameters: {'q': query, 'limit': 20},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      // Return empty list on error, don't throw
      return [];
    }
  }

  /// Map TransportMode to API transport type
  String _mapTransportMode(TransportMode mode) {
    switch (mode) {
      case TransportMode.flight:
        return 'flight';
      case TransportMode.train:
        return 'train';
      case TransportMode.bus:
        return 'bus';
      case TransportMode.ferry:
        return 'ferry';
    }
  }
}

/// Search repository interface
abstract class SearchRepositoryInterface {
  Future<SearchResponse> searchSchedules(
    SearchQuery query, {
    int page = 1,
    int limit = 50,
  });
  Future<List<Map<String, dynamic>>> getPopularDestinations();
  Future<List<Map<String, dynamic>>> searchDestinations(String query);
}

/// Implementation that uses real API
class SearchRepositoryImpl implements SearchRepositoryInterface {
  final RealSearchRepository _realRepository;

  SearchRepositoryImpl(DioClient dioClient)
    : _realRepository = RealSearchRepository(dioClient);

  @override
  Future<SearchResponse> searchSchedules(
    SearchQuery query, {
    int page = 1,
    int limit = 50,
  }) async {
    return _realRepository.searchSchedules(query, page: page, limit: limit);
  }

  @override
  Future<List<Map<String, dynamic>>> getPopularDestinations() {
    return _realRepository.getPopularDestinations();
  }

  @override
  Future<List<Map<String, dynamic>>> searchDestinations(String query) {
    return _realRepository.searchDestinations(query);
  }
}
