import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transport_operator.dart';
import '../../data/services/categories_admin_service.dart';

// Service provider
final categoriesAdminServiceProvider = Provider<CategoriesAdminService>((ref) {
  return CategoriesAdminService();
});

// State class
class CategoriesAdminState {
  final Map<String, List<TransportOperator>> categories;
  final bool isLoading;
  final String? error;
  final TransportOperator? selectedOperator;
  final Map<String, int>? stats;

  CategoriesAdminState({
    this.categories = const {'flight': [], 'train': [], 'bus': []},
    this.isLoading = false,
    this.error,
    this.selectedOperator,
    this.stats,
  });

  CategoriesAdminState copyWith({
    Map<String, List<TransportOperator>>? categories,
    bool? isLoading,
    String? error,
    TransportOperator? selectedOperator,
    Map<String, int>? stats,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return CategoriesAdminState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedOperator:
          clearSelected ? null : (selectedOperator ?? this.selectedOperator),
      stats: stats ?? this.stats,
    );
  }
}

// Notifier
class CategoriesAdminNotifier extends Notifier<CategoriesAdminState> {
  late final CategoriesAdminService _service;

  @override
  CategoriesAdminState build() {
    _service = ref.read(categoriesAdminServiceProvider);
    return CategoriesAdminState();
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final categories = await _service.getAllCategories();
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadOperatorsByType(String type) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final operators = await _service.getOperatorsByType(type);
      final updatedCategories = Map<String, List<TransportOperator>>.from(state.categories);
      updatedCategories[type] = operators;
      
      state = state.copyWith(
        categories: updatedCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createOperator(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final operator = await _service.createOperator(data);
      
      // Add to appropriate category
      final updatedCategories = Map<String, List<TransportOperator>>.from(state.categories);
      for (final type in operator.transportTypes) {
        if (updatedCategories.containsKey(type)) {
          updatedCategories[type] = [...updatedCategories[type]!, operator];
        }
      }

      state = state.copyWith(
        categories: updatedCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateOperator(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final operator = await _service.updateOperator(id, data);
      
      // Update in all categories
      final updatedCategories = Map<String, List<TransportOperator>>.from(state.categories);
      for (final type in updatedCategories.keys) {
        updatedCategories[type] = updatedCategories[type]!
            .map((op) => op.id == id ? operator : op)
            .toList();
      }

      state = state.copyWith(
        categories: updatedCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteOperator(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _service.deleteOperator(id);
      
      // Remove from all categories
      final updatedCategories = Map<String, List<TransportOperator>>.from(state.categories);
      for (final type in updatedCategories.keys) {
        updatedCategories[type] =
            updatedCategories[type]!.where((op) => op.id != id).toList();
      }

      state = state.copyWith(
        categories: updatedCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> loadStats() async {
    try {
      final stats = await _service.getStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      // Silently fail for stats
    }
  }

  void selectOperator(TransportOperator? operator) {
    state = state.copyWith(
      selectedOperator: operator,
      clearSelected: operator == null,
    );
  }
}

// Provider
final categoriesAdminProvider =
    NotifierProvider<CategoriesAdminNotifier, CategoriesAdminState>(
  CategoriesAdminNotifier.new,
);

