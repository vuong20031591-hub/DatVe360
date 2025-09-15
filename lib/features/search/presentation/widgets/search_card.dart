import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class SearchCard extends ConsumerStatefulWidget {
  const SearchCard({super.key, required this.mode, required this.onSearch});

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

  // Get appropriate icons based on transport mode
  IconData get _fromIcon {
    switch (widget.mode) {
      case TransportMode.flight:
        return Icons.flight_takeoff;
      case TransportMode.train:
        return Icons.train;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.ferry:
        return Icons.directions_boat;
    }
  }

  IconData get _toIcon {
    switch (widget.mode) {
      case TransportMode.flight:
        return Icons.flight_land;
      case TransportMode.train:
        return Icons.train;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.ferry:
        return Icons.directions_boat;
    }
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
                      prefixIcon: _fromIcon,
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
                      prefixIcon: _toIcon,
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
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
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
    final locations = [
      {'code': 'HAN', 'name': 'Hà Nội', 'fullName': 'Hà Nội (HAN)'},
      {'code': 'SGN', 'name': 'TP.HCM', 'fullName': 'TP. Hồ Chí Minh (SGN)'},
      {'code': 'DAD', 'name': 'Đà Nẵng', 'fullName': 'Đà Nẵng (DAD)'},
      {'code': 'CXR', 'name': 'Nha Trang', 'fullName': 'Nha Trang (CXR)'},
      {'code': 'DLI', 'name': 'Đà Lạt', 'fullName': 'Đà Lạt (DLI)'},
      {'code': 'PQC', 'name': 'Phú Quốc', 'fullName': 'Phú Quốc (PQC)'},
      {'code': 'VCA', 'name': 'Cần Thơ', 'fullName': 'Cần Thơ (VCA)'},
      {'code': 'HPH', 'name': 'Hải Phòng', 'fullName': 'Hải Phòng (HPH)'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFrom ? 'Chọn điểm đi' : 'Chọn điểm đến'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return ListTile(
                title: Text(location['fullName']!),
                onTap: () {
                  if (isFrom) {
                    _fromController.text = location['fullName']!;
                  } else {
                    _toController.text = location['fullName']!;
                  }
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
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
          : (_returnDate ??
                (_departDate?.add(const Duration(days: 1)) ??
                    now.add(const Duration(days: 2)))),
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
    int tempAdults = _adults;
    int tempChildren = _children;
    int tempInfants = _infants;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Chọn số lượng hành khách'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Adults
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Người lớn',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Từ 12 tuổi trở lên',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: tempAdults > 1
                            ? () => setState(() => tempAdults--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$tempAdults',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: (tempAdults + tempChildren + tempInfants) < 9
                            ? () => setState(() => tempAdults++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Children
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trẻ em',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Từ 2-11 tuổi',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: tempChildren > 0
                            ? () => setState(() => tempChildren--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$tempChildren',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: (tempAdults + tempChildren + tempInfants) < 9
                            ? () => setState(() => tempChildren++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Infants
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Em bé',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Dưới 2 tuổi',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: tempInfants > 0
                            ? () => setState(() => tempInfants--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$tempInfants',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed:
                            tempInfants < tempAdults &&
                                (tempAdults + tempChildren + tempInfants) < 9
                            ? () => setState(() => tempInfants++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Tối đa 9 hành khách. Em bé không được vượt quá số người lớn.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                this.setState(() {
                  _adults = tempAdults;
                  _children = tempChildren;
                  _infants = tempInfants;
                });
                Navigator.pop(context);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearch() {
    print('DEBUG: _handleSearch called');

    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      return;
    }

    if (_departDate == null) {
      print('DEBUG: Depart date is null');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày đi')));
      return;
    }

    if (_isRoundTrip && _returnDate == null) {
      print('DEBUG: Round trip but return date is null');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày về')));
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

    print('DEBUG: Search data: $searchData');
    widget.onSearch(searchData);
  }
}
