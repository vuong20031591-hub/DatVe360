import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
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
  TimeOfDay? _departureStart;
  TimeOfDay? _departureEnd;
  Set<String> _selectedCarriers = {};
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
    
    if (_filters['departureStart'] != null) {
      _departureStart = TimeOfDay.fromDateTime(_filters['departureStart']);
    }
    
    if (_filters['departureEnd'] != null) {
      _departureEnd = TimeOfDay.fromDateTime(_filters['departureEnd']);
    }
    
    _selectedCarriers = Set.from(_filters['carriers'] ?? []);
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
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
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
                  
                  // Departure time
                  _buildDepartureTimeFilter(theme),
                  
                  const SizedBox(height: 24),
                  
                  // Carriers
                  _buildCarrierFilter(theme),
                  
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
              border: Border(
                top: BorderSide(color: theme.dividerColor),
              ),
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
                  child: AppButton(
                    onPressed: _applyFilters,
                    text: 'Áp dụng',
                  ),
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

  Widget _buildDepartureTimeFilter(ThemeData theme) {
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
        Row(
          children: [
            Expanded(
              child: _buildTimeSelector(
                'Từ',
                _departureStart,
                (time) => setState(() => _departureStart = time),
                theme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeSelector(
                'Đến',
                _departureEnd,
                (time) => setState(() => _departureEnd = time),
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay? time,
    Function(TimeOfDay?) onChanged,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        onChanged(selectedTime);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time?.format(context) ?? 'Chọn giờ',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarrierFilter(ThemeData theme) {
    final carriers = ['Vietnam Airlines', 'VietJet Air', 'Bamboo Airways', 'Pacific Airlines'];
    
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
        ...carriers.map((carrier) {
          return CheckboxListTile(
            title: Text(carrier),
            value: _selectedCarriers.contains(carrier),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedCarriers.add(carrier);
                } else {
                  _selectedCarriers.remove(carrier);
                }
              });
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }).toList(),
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
      _departureStart = null;
      _departureEnd = null;
      _selectedCarriers.clear();
      _directFlightsOnly = false;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'minPrice': _priceRange.start.toInt(),
      'maxPrice': _priceRange.end.toInt(),
      'carriers': _selectedCarriers.toList(),
      'directFlightsOnly': _directFlightsOnly,
    };
    
    if (_departureStart != null) {
      filters['departureStart'] = DateTime(2024, 1, 1, _departureStart!.hour, _departureStart!.minute);
    }
    
    if (_departureEnd != null) {
      filters['departureEnd'] = DateTime(2024, 1, 1, _departureEnd!.hour, _departureEnd!.minute);
    }
    
    widget.onApply(filters);
    Navigator.pop(context);
  }
}
