import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../results/data/models/trip.dart';

class SearchHistoryPage extends ConsumerStatefulWidget {
  const SearchHistoryPage({super.key});

  @override
  ConsumerState<SearchHistoryPage> createState() => _SearchHistoryPageState();
}

class _SearchHistoryPageState extends ConsumerState<SearchHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử tìm kiếm'),
        actions: [
          IconButton(
            onPressed: _clearAllHistory,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Xóa tất cả',
          ),
        ],
      ),
      body: _buildBody(context, theme),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    final searchHistory = _getSearchHistory();

    if (searchHistory.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return Column(
      children: [
        // Filter tabs
        _buildFilterTabs(context, theme),
        
        // Search history list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: searchHistory.length,
            itemBuilder: (context, index) {
              final search = searchHistory[index];
              return _buildSearchHistoryItem(context, theme, search);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch sử tìm kiếm',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Các tìm kiếm của bạn sẽ xuất hiện ở đây',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            text: 'Bắt đầu tìm kiếm',
            icon: Icons.search,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Tất cả', true, theme),
          const SizedBox(width: 8),
          _buildFilterChip('Máy bay', false, theme),
          const SizedBox(width: 8),
          _buildFilterChip('Tàu hỏa', false, theme),
          const SizedBox(width: 8),
          _buildFilterChip('Xe khách', false, theme),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, ThemeData theme) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Implement filter logic
      },
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  Widget _buildSearchHistoryItem(BuildContext context, ThemeData theme, Map<String, dynamic> search) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _repeatSearch(search),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getTransportIcon(search['mode']),
                    color: _getTransportColor(search['mode']),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${search['from']} → ${search['to']}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeSearchHistory(search),
                    icon: const Icon(Icons.close, size: 18),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    search['date'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.people,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${search['passengers']} người',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    search['searchTime'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSearchHistory() {
    // TODO: Get from provider/repository
    return [
      {
        'from': 'Hà Nội',
        'to': 'Hồ Chí Minh',
        'mode': 'flight',
        'date': '15/12/2024',
        'passengers': 2,
        'searchTime': '2 giờ trước',
      },
      {
        'from': 'Đà Nẵng',
        'to': 'Nha Trang',
        'mode': 'train',
        'date': '20/12/2024',
        'passengers': 1,
        'searchTime': '1 ngày trước',
      },
      {
        'from': 'Hà Nội',
        'to': 'Hải Phòng',
        'mode': 'bus',
        'date': '18/12/2024',
        'passengers': 3,
        'searchTime': '3 ngày trước',
      },
    ];
  }

  IconData _getTransportIcon(String mode) {
    switch (mode) {
      case 'flight':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      case 'ferry':
        return Icons.directions_boat;
      default:
        return Icons.search;
    }
  }

  Color _getTransportColor(String mode) {
    switch (mode) {
      case 'flight':
        return AppColors.flightColor;
      case 'train':
        return AppColors.trainColor;
      case 'bus':
        return AppColors.busColor;
      case 'ferry':
        return AppColors.ferryColor;
      default:
        return Colors.grey;
    }
  }

  void _repeatSearch(Map<String, dynamic> search) {
    // TODO: Navigate to search with pre-filled data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tìm kiếm lại: ${search['from']} → ${search['to']}'),
      ),
    );
  }

  void _removeSearchHistory(Map<String, dynamic> search) {
    // TODO: Remove from provider/repository
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa lịch sử tìm kiếm'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            // TODO: Restore search history
          },
        ),
      ),
    );
  }

  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả lịch sử'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả lịch sử tìm kiếm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Clear all history from provider/repository
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa tất cả lịch sử tìm kiếm')),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
