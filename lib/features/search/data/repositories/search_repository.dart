import '../../../../core/network/dio_client.dart';
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

      // TODO: Implement real API call
      final trips = <Trip>[];

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

      // TODO: Implement real API call
      return <Map<String, dynamic>>[];
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

      // TODO: Implement real API call
      return <Map<String, dynamic>>[];
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
}
