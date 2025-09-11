import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class SearchCard extends ConsumerStatefulWidget {
  const SearchCard({
    super.key,
    required this.mode,
    required this.onSearch,
  });

  final TransportMode mode;
  final Function(Map<String, dynamic>) onSearch;

  @override
  ConsumerState<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends ConsumerState<SearchCard> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  
  DateTime? _departDate;
  DateTime? _returnDate;
  bool _isRoundTrip = false;
  int _adults = 1;
  int _children = 0;
  int _infants = 0;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip type toggle
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(l10n.oneWay),
                      value: false,
                      groupValue: _isRoundTrip,
                      onChanged: (value) {
                        setState(() {
                          _isRoundTrip = value!;
                          if (!_isRoundTrip) {
                            _returnDate = null;
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(l10n.roundTrip),
                      value: true,
                      groupValue: _isRoundTrip,
                      onChanged: (value) {
                        setState(() {
                          _isRoundTrip = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // From and To fields
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _fromController,
                      label: l10n.from,
                      prefixIcon: Icons.flight_takeoff,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.fieldRequired;
                        }
                        if (value == _toController.text) {
                          return l10n.fromToSame;
                        }
                        return null;
                      },
                      onTap: () => _showLocationPicker(true),
                      readOnly: true,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Swap button
                  IconButton(
                    onPressed: _swapLocations,
                    icon: const Icon(Icons.swap_horiz),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  Expanded(
                    child: AppTextField(
                      controller: _toController,
                      label: l10n.to,
                      prefixIcon: Icons.flight_land,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.fieldRequired;
                        }
                        if (value == _fromController.text) {
                          return l10n.fromToSame;
                        }
                        return null;
                      },
                      onTap: () => _showLocationPicker(false),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Date fields
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: l10n.departDate,
                      date: _departDate,
                      onTap: () => _selectDate(true),
                      icon: Icons.calendar_today,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: _buildDateField(
                      label: l10n.returnDate,
                      date: _returnDate,
                      onTap: _isRoundTrip ? () => _selectDate(false) : null,
                      icon: Icons.calendar_today,
                      enabled: _isRoundTrip,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Passengers field
              InkWell(
                onTap: _showPassengerPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.passengers,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              _getPassengerText(),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Passenger hint
              Text(
                'Đi cùng trẻ em? Chọn đúng số lượng để áp dụng chính sách giá phù hợp.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Search button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: _handleSearch,
                  text: l10n.searchTrips,
                  icon: Icons.search,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback? onTap,
    required IconData icon,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? theme.dividerColor : theme.disabledColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled
                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                  : theme.disabledColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurface.withOpacity(0.6)
                          : theme.disabledColor,
                    ),
                  ),
                  Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Chọn ngày',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.disabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPassengerText() {
    final parts = <String>[];
    if (_adults > 0) parts.add('$_adults người lớn');
    if (_children > 0) parts.add('$_children trẻ em');
    if (_infants > 0) parts.add('$_infants em bé');
    return parts.join(', ');
  }

  void _swapLocations() {
    final temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
  }

  void _showLocationPicker(bool isFrom) {
    // TODO: Implement location picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFrom ? 'Chọn điểm đi' : 'Chọn điểm đến'),
        content: const Text('Tính năng chọn địa điểm sẽ được cập nhật sau.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _selectDate(bool isDeparture) async {
    final now = DateTime.now();
    final firstDate = isDeparture ? now : (_departDate ?? now);
    
    final date = await showDatePicker(
      context: context,
      initialDate: isDeparture
          ? (_departDate ?? now.add(const Duration(days: 1)))
          : (_returnDate ?? (_departDate?.add(const Duration(days: 1)) ?? now.add(const Duration(days: 2)))),
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        if (isDeparture) {
          _departDate = date;
          // Reset return date if it's before departure date
          if (_returnDate != null && _returnDate!.isBefore(date)) {
            _returnDate = null;
          }
        } else {
          _returnDate = date;
        }
      });
    }
  }

  void _showPassengerPicker() {
    // TODO: Implement passenger picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn số lượng hành khách'),
        content: const Text('Tính năng chọn hành khách sẽ được cập nhật sau.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _handleSearch() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_departDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày đi')),
      );
      return;
    }
    
    if (_isRoundTrip && _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày về')),
      );
      return;
    }
    
    final searchData = {
      'mode': widget.mode,
      'from': _fromController.text,
      'to': _toController.text,
      'departDate': _departDate,
      'returnDate': _returnDate,
      'isRoundTrip': _isRoundTrip,
      'adults': _adults,
      'children': _children,
      'infants': _infants,
    };
    
    widget.onSearch(searchData);
  }
}
