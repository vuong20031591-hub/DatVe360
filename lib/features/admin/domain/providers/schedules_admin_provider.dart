import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/schedule_admin.dart';
import '../../data/services/schedules_admin_service.dart';

// Service provider
final schedulesAdminServiceProvider = Provider<SchedulesAdminService>((ref) {
  return SchedulesAdminService();
});

// State class
class SchedulesAdminState {
  final List<ScheduleAdmin> schedules;
  final bool isLoading;
  final String? error;
  final ScheduleAdmin? selectedSchedule;
  final Map<String, int>? stats;
  final String? currentTransportType;

  const SchedulesAdminState({
    this.schedules = const [],
    this.isLoading = false,
    this.error,
    this.selectedSchedule,
    this.stats,
    this.currentTransportType,
  });

  SchedulesAdminState copyWith({
    List<ScheduleAdmin>? schedules,
    bool? isLoading,
    String? error,
    ScheduleAdmin? selectedSchedule,
    Map<String, int>? stats,
    String? currentTransportType,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return SchedulesAdminState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedSchedule:
          clearSelected ? null : (selectedSchedule ?? this.selectedSchedule),
      stats: stats ?? this.stats,
      currentTransportType: currentTransportType ?? this.currentTransportType,
    );
  }

  List<ScheduleAdmin> get flightSchedules =>
      schedules.where((s) => s.transportType == 'flight').toList();

  List<ScheduleAdmin> get trainSchedules =>
      schedules.where((s) => s.transportType == 'train').toList();

  List<ScheduleAdmin> get busSchedules =>
      schedules.where((s) => s.transportType == 'bus').toList();
}

// Notifier
class SchedulesAdminNotifier extends Notifier<SchedulesAdminState> {
  late final SchedulesAdminService _service;

  @override
  SchedulesAdminState build() {
    _service = ref.read(schedulesAdminServiceProvider);
    return const SchedulesAdminState();
  }

  Future<void> loadSchedules({String? transportType}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentTransportType: transportType,
    );

    try {
      final schedules = await _service.getSchedules(
        transportType: transportType,
      );
      state = state.copyWith(
        schedules: schedules,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStatistics() async {
    try {
      final stats = await _service.getStatistics();
      state = state.copyWith(stats: stats);
    } catch (e) {
      // Ignore stats errors
    }
  }

  Future<void> createSchedule(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final schedule = await _service.createSchedule(data);

      state = state.copyWith(
        schedules: [...state.schedules, schedule],
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

  Future<void> updateSchedule(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final schedule = await _service.updateSchedule(id, data);

      state = state.copyWith(
        schedules: state.schedules
            .map((s) => s.id == id ? schedule : s)
            .toList(),
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

  Future<void> deleteSchedule(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _service.deleteSchedule(id);

      state = state.copyWith(
        schedules: state.schedules.where((s) => s.id != id).toList(),
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

  Future<void> toggleActive(String id, bool isActive) async {
    try {
      final schedule = await _service.toggleActive(id, isActive);

      state = state.copyWith(
        schedules: state.schedules
            .map((s) => s.id == id ? schedule : s)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      final schedule = await _service.updateStatus(id, status);

      state = state.copyWith(
        schedules: state.schedules
            .map((s) => s.id == id ? schedule : s)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void selectSchedule(ScheduleAdmin? schedule) {
    state = state.copyWith(
      selectedSchedule: schedule,
      clearSelected: schedule == null,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider
final schedulesAdminProvider =
    NotifierProvider<SchedulesAdminNotifier, SchedulesAdminState>(
  SchedulesAdminNotifier.new,
);

