import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';

class TicketsManagementScreen extends ConsumerStatefulWidget {
  const TicketsManagementScreen({super.key});

  @override
  ConsumerState<TicketsManagementScreen> createState() =>
      _TicketsManagementScreenState();
}

class _TicketsManagementScreenState
    extends ConsumerState<TicketsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentType = 'plane';
  List<dynamic> _schedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadSchedules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final newType = ['plane', 'train', 'bus'][_tabController.index];
      print('🔄 Tab changed to index ${_tabController.index}, type: $newType');
      setState(() {
        _currentType = newType;
      });
      _loadSchedules();
    }
  }

  Future<void> _loadSchedules() async {
    print('🔍 Loading schedules for type: $_currentType');
    setState(() => _isLoading = true);

    try {
      final dioClient = DioClient.instance;
      final response = await dioClient.get(
        '/admin/schedules-by-type/$_currentType',
        queryParameters: {'page': 1, 'limit': 50},
      );

      final data = response.data;
      final schedules = data is Map ? (data['data'] ?? []) : [];

      print('✅ Loaded ${schedules.length} schedules for $_currentType');
      if (schedules.isNotEmpty) {
        final first = schedules[0];
        print('   First schedule: ${first['vehicleNumber']} - ${first['routeId']?['transportType']}');
      }

      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading schedules for $_currentType: $e');
      setState(() {
        _schedules = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Vé'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.flight), text: 'Máy bay'),
            Tab(icon: Icon(Icons.train), text: 'Tàu hỏa'),
            Tab(icon: Icon(Icons.directions_bus), text: 'Xe khách'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getIcon(), size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Chưa có vé ${_getLabel()}'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSchedules,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      return _buildScheduleCard(schedule);
                    },
                  ),
                ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final route = schedule['routeId'] ?? {};
    final from = route['fromDestination'] ?? {};
    final to = route['toDestination'] ?? {};
    final operator = schedule['operatorId'] ?? {};
    final seatConfig = schedule['seatConfiguration'] ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${from['name'] ?? ''} → ${to['name'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(schedule['status'] ?? 'scheduled'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              operator['name'] ?? '',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfo(
                    Icons.flight_takeoff,
                    'Khởi hành',
                    dateFormat.format(
                      DateTime.parse(schedule['departureTime']),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildInfo(
                    Icons.flight_land,
                    'Đến',
                    dateFormat.format(
                      DateTime.parse(schedule['arrivalTime']),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfo(
                    Icons.confirmation_number,
                    'Số hiệu',
                    schedule['vehicleNumber'] ?? '',
                  ),
                ),
                Expanded(
                  child: _buildInfo(
                    Icons.event_seat,
                    'Ghế trống',
                    '${seatConfig['availableSeats'] ?? 0}/${seatConfig['totalSeats'] ?? 0}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'scheduled':
        color = Colors.blue;
        label = 'Đã lên lịch';
        break;
      case 'delayed':
        color = Colors.orange;
        label = 'Trễ';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontSize: 12),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  IconData _getIcon() {
    switch (_currentType) {
      case 'plane':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      default:
        return Icons.confirmation_number;
    }
  }

  String _getLabel() {
    switch (_currentType) {
      case 'plane':
        return 'máy bay';
      case 'train':
        return 'tàu hỏa';
      case 'bus':
        return 'xe khách';
      default:
        return _currentType;
    }
  }
}

