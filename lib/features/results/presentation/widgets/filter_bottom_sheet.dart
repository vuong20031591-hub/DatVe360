import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_button.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApply;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, dynamic> _filters;
  RangeValues _priceRange = const RangeValues(500000, 2000000);
  Set<String> _selectedTimeSlots = {};
  Set<String> _selectedOperators = {};
  double _maxDuration = 12.0; // hours
  bool _directFlightsOnly = false;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _initializeFilters();
  }

  void _initializeFilters() {
    _priceRange = RangeValues(
      _filters['minPrice']?.toDouble() ?? 500000,
      _filters['maxPrice']?.toDouble() ?? 2000000,
    );

    _selectedTimeSlots = Set.from(_filters['departureTime'] ?? []);
    _selectedOperators = Set.from(_filters['operators'] ?? []);
    _maxDuration = _filters['maxDuration']?.toDouble() ?? 12.0;
    _directFlightsOnly = _filters['directFlightsOnly'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Bộ lọc',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Xóa tất cả'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price range
                  _buildPriceFilter(theme),

                  const SizedBox(height: 24),

                  // Departure time slots
                  _buildTimeSlotFilter(theme),

                  const SizedBox(height: 24),

                  // Duration filter
                  _buildDurationFilter(theme),

                  const SizedBox(height: 24),

                  // Operators
                  _buildOperatorFilter(theme),

                  const SizedBox(height: 24),

                  // Direct flights
                  _buildDirectFlightsFilter(theme),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () => Navigator.pop(context),
                    text: 'Hủy',
                    type: AppButtonType.outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(onPressed: _applyFilters, text: 'Áp dụng'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khoảng giá',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: _priceRange,
          min: 200000,
          max: 5000000,
          divisions: 48,
          labels: RangeLabels(
            _formatPrice(_priceRange.start.toInt()),
            _formatPrice(_priceRange.end.toInt()),
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatPrice(_priceRange.start.toInt()),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatPrice(_priceRange.end.toInt()),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSlotFilter(ThemeData theme) {
    final timeSlots = [
      {
        'key': 'morning',
        'label': 'Sáng (6:00 - 12:00)',
        'icon': Icons.wb_sunny,
      },
      {
        'key': 'afternoon',
        'label': 'Chiều (12:00 - 18:00)',
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'key': 'evening',
        'label': 'Tối (18:00 - 24:00)',
        'icon': Icons.nights_stay_outlined,
      },
      {'key': 'night', 'label': 'Đêm (0:00 - 6:00)', 'icon': Icons.nights_stay},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giờ khởi hành',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...timeSlots.map((slot) {
          return CheckboxListTile(
            title: Row(
              children: [
                Icon(slot['icon'] as IconData, size: 20),
                const SizedBox(width: 8),
                Text(slot['label'] as String),
              ],
            ),
            value: _selectedTimeSlots.contains(slot['key']),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedTimeSlots.add(slot['key'] as String);
                } else {
                  _selectedTimeSlots.remove(slot['key']);
                }
              });
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }),
      ],
    );
  }

  Widget _buildDurationFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thời gian bay tối đa',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _maxDuration,
          min: 1.0,
          max: 24.0,
          divisions: 23,
          label: '${_maxDuration.toInt()}h',
          onChanged: (value) {
            setState(() {
              _maxDuration = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1h',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${_maxDuration.toInt()}h',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              '24h',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOperatorFilter(ThemeData theme) {
    final operators = [
      'Vietnam Airlines',
      'VietJet Air',
      'Bamboo Airways',
      'Pacific Airlines',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hãng hàng không',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...operators.map((operator) {
          return CheckboxListTile(
            title: Text(operator),
            value: _selectedOperators.contains(operator),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedOperators.add(operator);
                } else {
                  _selectedOperators.remove(operator);
                }
              });
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }),
      ],
    );
  }

  Widget _buildDirectFlightsFilter(ThemeData theme) {
    return SwitchListTile(
      title: Text(
        'Chỉ chuyến bay thẳng',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: const Text('Không có điểm dừng'),
      value: _directFlightsOnly,
      onChanged: (value) {
        setState(() {
          _directFlightsOnly = value;
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  String _formatPrice(int price) {
    return '${(price / 1000).toStringAsFixed(0)}K';
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(500000, 2000000);
      _selectedTimeSlots.clear();
      _selectedOperators.clear();
      _maxDuration = 12.0;
      _directFlightsOnly = false;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'minPrice': _priceRange.start.toInt(),
      'maxPrice': _priceRange.end.toInt(),
      'departureTime': _selectedTimeSlots.toList(),
      'operators': _selectedOperators.toList(),
      'maxDuration': _maxDuration,
      'directFlightsOnly': _directFlightsOnly,
    };

    widget.onApply(filters);
    Navigator.pop(context);
  }
}
