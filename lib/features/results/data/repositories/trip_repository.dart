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

      // For now, return null
      return null;
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

      // For now, return empty seat map
      return {};
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

      // For now, return empty list
      return [];
    } catch (e) {
      throw Exception('Failed to get trip classes: $e');
    }
  }
}
