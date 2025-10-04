import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/providers/destinations_admin_provider.dart';
import '../../data/models/destination_admin.dart';
import '../widgets/destination_form_dialog.dart';

class DestinationsManagementScreen extends ConsumerStatefulWidget {
  const DestinationsManagementScreen({super.key});

  @override
  ConsumerState<DestinationsManagementScreen> createState() =>
      _DestinationsManagementScreenState();
}

class _DestinationsManagementScreenState
    extends ConsumerState<DestinationsManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(destinationsAdminProvider.notifier).loadDestinations();
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng cấp quyền truy cập vị trí trong cài đặt'),
            ),
          );
        }
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lấy vị trí: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showAddDestinationDialog() {
    showDialog(
      context: context,
      builder: (context) => DestinationFormDialog(
        currentPosition: _currentPosition,
        onSave: (destination) async {
          final success = await ref
              .read(destinationsAdminProvider.notifier)
              .createDestination(destination);

          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã thêm điểm đến mới')),
            );
          }
        },
      ),
    );
  }

  void _showEditDestinationDialog(DestinationAdmin destination) {
    showDialog(
      context: context,
      builder: (context) => DestinationFormDialog(
        destination: destination,
        currentPosition: _currentPosition,
        onSave: (updatedDestination) async {
          final success = await ref
              .read(destinationsAdminProvider.notifier)
              .updateDestination(destination.id!, updatedDestination);

          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật điểm đến')),
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteDestination(DestinationAdmin destination) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${destination.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(destinationsAdminProvider.notifier)
          .deleteDestination(destination.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa điểm đến')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(destinationsAdminProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Quản lý điểm đến'),
        actions: [
          if (_isLoadingLocation)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(
                _currentPosition != null
                    ? Icons.location_on
                    : Icons.location_off,
                color: _currentPosition != null ? Colors.green : null,
              ),
              onPressed: _getCurrentLocation,
              tooltip: 'Lấy vị trí hiện tại',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(destinationsAdminProvider.notifier).loadDestinations();
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm điểm đến...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(destinationsAdminProvider.notifier)
                              .loadDestinations();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  ref.read(destinationsAdminProvider.notifier).loadDestinations();
                } else {
                  ref
                      .read(destinationsAdminProvider.notifier)
                      .searchDestinations(value);
                }
              },
            ),
          ),

          // Error message
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                state.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),

          // Loading indicator
          if (state.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          // Destinations list
          else if (state.destinations.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Chưa có điểm đến nào'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: state.destinations.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final destination = state.destinations[index];
                  final distance = _currentPosition != null
                      ? destination.getDistanceFrom(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        )
                      : null;

                  return _buildDestinationCard(
                    destination,
                    distance,
                    theme,
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDestinationDialog,
        icon: const Icon(Icons.add),
        label: const Text('Thêm điểm đến'),
      ),
    );
  }

  Widget _buildDestinationCard(
    DestinationAdmin destination,
    double? distance,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: destination.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  destination.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.location_city),
                  ),
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_city,
                  color: theme.primaryColor,
                ),
              ),
        title: Text(
          destination.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${destination.typeDisplayName} • ${destination.city}'),
            if (distance != null)
              Text(
                'Cách ${distance.toStringAsFixed(1)} km',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDestinationDialog(destination);
            } else if (value == 'delete') {
              _deleteDestination(destination);
            }
          },
        ),
      ),
    );
  }
}

