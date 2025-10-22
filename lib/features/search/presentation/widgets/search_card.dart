import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/repositories/search_repository.dart';

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

  // Lưu code riêng để gửi lên backend
  String? _fromCode;
  String? _toCode;

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

  Future<void> _showLocationPicker(bool isFrom) async {
    // Fetch destinations from API
    List<Map<String, dynamic>> locations = [];
    bool isLoading = true;
    String? errorMessage;

    // Show dialog with loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          // Fetch data on first build
          if (isLoading && locations.isEmpty && errorMessage == null) {
            _fetchDestinations(isFrom)
                .then((destinations) {
                  setState(() {
                    locations = destinations;
                    isLoading = false;
                  });
                })
                .catchError((error) {
                  setState(() {
                    errorMessage = error.toString();
                    isLoading = false;
                  });
                });
          }

          return AlertDialog(
            title: Text(isFrom ? 'Chọn điểm đi' : 'Chọn điểm đến'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không thể tải danh sách điểm đến',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                errorMessage = null;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  : locations.isEmpty
                  ? const Center(child: Text('Không có điểm đến nào'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        final location = locations[index];
                        final code = location['code'] ?? '';
                        final name = location['name'] ?? '';
                        final city = location['city'] ?? '';
                        final displayName = '$city - $name ($code)';

                        return ListTile(
                          leading: Icon(
                            _getDestinationIcon(location['type'] ?? ''),
                          ),
                          title: Text(displayName),
                          subtitle: Text(location['type'] ?? ''),
                          onTap: () {
                            // Lưu displayName để hiển thị, code để gửi backend
                            if (isFrom) {
                              _fromController.text = displayName;
                              _fromCode = code;
                            } else {
                              _toController.text = displayName;
                              _toCode = code;
                            }
                            Navigator.pop(dialogContext);
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchDestinations(bool isFrom) async {
    try {
      final searchRepo = ref.read(searchRepositoryProvider);

      // Map transport mode to API transportType
      String transportType;
      switch (widget.mode) {
        case TransportMode.flight:
          transportType = 'flight';
          break;
        case TransportMode.train:
          transportType = 'train';
          break;
        case TransportMode.bus:
          transportType = 'bus';
          break;
      }

      // Nếu chọn điểm đi, lấy tất cả destinations có route đi
      if (isFrom) {
        return await searchRepo.getDestinationsFrom(transportType);
      }

      // Nếu chọn điểm đến, lấy destinations có route từ điểm đi đã chọn
      if (_fromCode != null) {
        return await searchRepo.getDestinationsTo(_fromCode!, transportType);
      }

      // Fallback: Nếu chưa chọn điểm đi, lấy tất cả
      return await searchRepo.getDestinationsFrom(transportType);
    } catch (e) {
      throw Exception('Lỗi kết nối: ${e.toString()}');
    }
  }

  IconData _getDestinationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'airport':
        return Icons.flight;
      case 'bus_station':
        return Icons.directions_bus;
      case 'train_station':
        return Icons.train;
      case 'port':
        return Icons.directions_boat;
      default:
        return Icons.location_on;
    }
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_departDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày đi')));
      return;
    }

    if (_isRoundTrip && _returnDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày về')));
      return;
    }

    final searchData = {
      'mode': widget.mode,
      'from':
          _fromCode ??
          _fromController.text, // Dùng code nếu có, fallback displayName
      'to':
          _toCode ??
          _toController.text, // Dùng code nếu có, fallback displayName
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
