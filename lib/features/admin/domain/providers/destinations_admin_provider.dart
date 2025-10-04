import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/destination_admin.dart';
import '../../data/services/destinations_admin_service.dart';

// Service provider
final destinationsAdminServiceProvider = Provider<DestinationsAdminService>((ref) {
  return DestinationsAdminService();
});

// State class
class DestinationsAdminState {
  final List<DestinationAdmin> destinations;
  final bool isLoading;
  final String? error;
  final DestinationAdmin? selectedDestination;

  const DestinationsAdminState({
    this.destinations = const [],
    this.isLoading = false,
    this.error,
    this.selectedDestination,
  });

  DestinationsAdminState copyWith({
    List<DestinationAdmin>? destinations,
    bool? isLoading,
    String? error,
    DestinationAdmin? selectedDestination,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return DestinationsAdminState(
      destinations: destinations ?? this.destinations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedDestination: clearSelected ? null : (selectedDestination ?? this.selectedDestination),
    );
  }
}

// Notifier
class DestinationsAdminNotifier extends Notifier<DestinationsAdminState> {
  late final DestinationsAdminService _service;

  @override
  DestinationsAdminState build() {
    _service = ref.read(destinationsAdminServiceProvider);
    return const DestinationsAdminState();
  }

  // Load all destinations
  Future<void> loadDestinations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final destinations = await _service.getAllDestinations();
      state = state.copyWith(
        destinations: destinations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load popular destinations
  Future<void> loadPopularDestinations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final destinations = await _service.getPopularDestinations();
      state = state.copyWith(
        destinations: destinations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Search destinations
  Future<void> searchDestinations(String query) async {
    if (query.isEmpty) {
      await loadDestinations();
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final destinations = await _service.searchDestinations(query);
      state = state.copyWith(
        destinations: destinations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Select destination
  Future<void> selectDestination(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final destination = await _service.getDestinationById(id);
      state = state.copyWith(
        selectedDestination: destination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Create destination
  Future<bool> createDestination(DestinationAdmin destination) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final newDestination = await _service.createDestination(destination);
      final updatedList = [...state.destinations, newDestination];
      state = state.copyWith(
        destinations: updatedList,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Update destination
  Future<bool> updateDestination(String id, DestinationAdmin destination) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final updatedDestination = await _service.updateDestination(id, destination);
      final updatedList = state.destinations.map((d) {
        return d.id == id ? updatedDestination : d;
      }).toList();
      
      state = state.copyWith(
        destinations: updatedList,
        selectedDestination: updatedDestination,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Delete destination
  Future<bool> deleteDestination(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final success = await _service.deleteDestination(id);
      if (success) {
        final updatedList = state.destinations.where((d) => d.id != id).toList();
        state = state.copyWith(
          destinations: updatedList,
          isLoading: false,
          clearSelected: true,
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Upload image
  Future<String?> uploadImage(String filePath) async {
    try {
      return await _service.uploadDestinationImage(filePath);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Clear selected
  void clearSelected() {
    state = state.copyWith(clearSelected: true);
  }
}

// Provider
final destinationsAdminProvider = NotifierProvider<DestinationsAdminNotifier, DestinationsAdminState>(() {
  return DestinationsAdminNotifier();
});

