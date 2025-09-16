import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';

class StepPassenger extends StatefulWidget {
  const StepPassenger({
    super.key,
    required this.bookingData,
    required this.onDataChanged,
  });

  final Map<String, dynamic> bookingData;
  final Function(Map<String, dynamic>) onDataChanged;

  @override
  State<StepPassenger> createState() => _StepPassengerState();
}

class _StepPassengerState extends State<StepPassenger> {
  final _formKey = GlobalKey<FormState>();
  final List<GlobalKey<FormState>> _passengerFormKeys = [];
  final List<Map<String, TextEditingController>> _passengerControllers = [];

  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactFirstNameController = TextEditingController();
  final _contactLastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePassengers();
    _loadExistingData();
  }

  @override
  void dispose() {
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _contactFirstNameController.dispose();
    _contactLastNameController.dispose();

    for (final controllers in _passengerControllers) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }

    super.dispose();
  }

  void _initializePassengers() {
    final selectedSeats = widget.bookingData['selectedSeats'] is List
        ? List<String>.from(widget.bookingData['selectedSeats'])
        : <String>[];
    final passengerCount = selectedSeats.isNotEmpty ? selectedSeats.length : 1;

    _passengerFormKeys.clear();
    _passengerControllers.clear();

    for (int i = 0; i < passengerCount; i++) {
      _passengerFormKeys.add(GlobalKey<FormState>());
      _passengerControllers.add({
        'firstName': TextEditingController(),
        'lastName': TextEditingController(),
        'dateOfBirth': TextEditingController(),
        'nationality': TextEditingController(text: 'Việt Nam'),
        'documentNumber': TextEditingController(),
        'documentType': TextEditingController(text: 'id_card'),
        'type': TextEditingController(text: 'adult'),
        'gender': TextEditingController(text: 'male'),
      });
    }
  }

  void _loadExistingData() {
    final contactInfo =
        widget.bookingData['contactInfo'] as Map<String, dynamic>? ?? {};
    final passengers =
        widget.bookingData['passengers'] as List<Map<String, dynamic>>? ?? [];

    _contactEmailController.text = contactInfo['email'] ?? '';
    _contactPhoneController.text = contactInfo['phone'] ?? '';
    _contactFirstNameController.text = contactInfo['firstName'] ?? '';
    _contactLastNameController.text = contactInfo['lastName'] ?? '';

    for (
      int i = 0;
      i < passengers.length && i < _passengerControllers.length;
      i++
    ) {
      final passenger = passengers[i];
      final controllers = _passengerControllers[i];

      controllers['firstName']?.text = passenger['firstName'] ?? '';
      controllers['lastName']?.text = passenger['lastName'] ?? '';
      controllers['dateOfBirth']?.text = _convertISOToDisplayDate(
        passenger['dateOfBirth'] ?? '',
      );
      controllers['nationality']?.text = passenger['nationality'] ?? 'Việt Nam';
      controllers['documentNumber']?.text = passenger['documentNumber'] ?? '';
      controllers['documentType']?.text =
          passenger['documentType'] ?? 'id_card';
      controllers['type']?.text = passenger['type'] ?? 'adult';
      controllers['gender']?.text = passenger['gender'] ?? 'male';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedSeats =
        widget.bookingData['selectedSeats'] as List<String>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.contact_phone,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thông tin liên hệ',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _contactLastNameController,
                            label: 'Họ người liên hệ',
                            hint: 'Nguyễn',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập họ';
                              }
                              return null;
                            },
                            onChanged: _saveData,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            controller: _contactFirstNameController,
                            label: 'Tên người liên hệ',
                            hint: 'Văn A',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên';
                              }
                              return null;
                            },
                            onChanged: _saveData,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    AppEmailField(
                      controller: _contactEmailController,
                      label: 'Email nhận vé',
                      onChanged: _saveData,
                    ),

                    const SizedBox(height: 16),

                    AppPhoneField(
                      controller: _contactPhoneController,
                      label: 'Số điện thoại',
                      onChanged: _saveData,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Passenger information
            ...selectedSeats.asMap().entries.map((entry) {
              final index = entry.key;
              final seat = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _passengerFormKeys[index],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.airline_seat_recline_normal,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hành khách ${index + 1} - Ghế $seat',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller:
                                      _passengerControllers[index]['lastName']!,
                                  label: 'Họ',
                                  hint: 'Nguyễn',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập họ';
                                    }
                                    return null;
                                  },
                                  onChanged: _saveData,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller:
                                      _passengerControllers[index]['firstName']!,
                                  label: 'Tên',
                                  hint: 'Văn A',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập tên';
                                    }
                                    return null;
                                  },
                                  onChanged: _saveData,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          AppTextField(
                            controller:
                                _passengerControllers[index]['dateOfBirth']!,
                            label: 'Ngày sinh',
                            hint: 'dd/mm/yyyy',
                            prefixIcon: Icons.calendar_today,
                            readOnly: true,
                            onTap: () => _selectDate(context, index),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng chọn ngày sinh';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue:
                                      _passengerControllers[index]['documentType']!
                                          .text
                                          .isNotEmpty
                                      ? _passengerControllers[index]['documentType']!
                                            .text
                                      : 'id_card',
                                  decoration: const InputDecoration(
                                    labelText: 'Loại giấy tờ',
                                    prefixIcon: Icon(Icons.badge),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'id_card',
                                      child: Text('CCCD'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'passport',
                                      child: Text('Hộ chiếu'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'driver_license',
                                      child: Text('Bằng lái xe'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      _passengerControllers[index]['documentType']!
                                              .text =
                                          value;
                                      _saveData();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller:
                                      _passengerControllers[index]['documentNumber']!,
                                  label: 'Số giấy tờ',
                                  hint: '001234567890',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập số giấy tờ';
                                    }
                                    return null;
                                  },
                                  onChanged: _saveData,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          AppTextField(
                            controller:
                                _passengerControllers[index]['nationality']!,
                            label: 'Quốc tịch',
                            hint: 'Việt Nam',
                            prefixIcon: Icons.flag,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập quốc tịch';
                              }
                              return null;
                            },
                            onChanged: _saveData,
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue:
                                      _passengerControllers[index]['type']!
                                          .text
                                          .isNotEmpty
                                      ? _passengerControllers[index]['type']!
                                            .text
                                      : 'adult',
                                  decoration: const InputDecoration(
                                    labelText: 'Loại hành khách',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'adult',
                                      child: Text('Người lớn'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'child',
                                      child: Text('Trẻ em'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'infant',
                                      child: Text('Em bé'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      _passengerControllers[index]['type']!
                                              .text =
                                          value;
                                      _saveData();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue:
                                      _passengerControllers[index]['gender']!
                                          .text
                                          .isNotEmpty
                                      ? _passengerControllers[index]['gender']!
                                            .text
                                      : 'male',
                                  decoration: const InputDecoration(
                                    labelText: 'Giới tính',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'male',
                                      child: Text('Nam'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'female',
                                      child: Text('Nữ'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'other',
                                      child: Text('Khác'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      _passengerControllers[index]['gender']!
                                              .text =
                                          value;
                                      _saveData();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Quick fill button
            if (_passengerControllers.length > 1)
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: _quickFillFromContact,
                  text: 'Điền nhanh từ thông tin liên hệ',
                  type: AppButtonType.outline,
                  icon: Icons.auto_fix_high,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, int passengerIndex) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      _passengerControllers[passengerIndex]['dateOfBirth']!.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      _saveData();
    }
  }

  void _quickFillFromContact() {
    if ((_contactFirstNameController.text.isNotEmpty ||
            _contactLastNameController.text.isNotEmpty) &&
        _passengerControllers.isNotEmpty) {
      _passengerControllers[0]['lastName']!.text =
          _contactLastNameController.text;
      _passengerControllers[0]['firstName']!.text =
          _contactFirstNameController.text;
      _saveData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã điền thông tin hành khách đầu tiên từ thông tin liên hệ',
          ),
        ),
      );
    }
  }

  void _saveData([String? _]) {
    final contactInfo = {
      'firstName': _contactFirstNameController.text,
      'lastName': _contactLastNameController.text,
      'email': _contactEmailController.text,
      'phone': _contactPhoneController.text,
    };

    final passengers = _passengerControllers
        .map(
          (controllers) => {
            'firstName': controllers['firstName']!.text,
            'lastName': controllers['lastName']!.text,
            'dateOfBirth': _convertDateToISO(controllers['dateOfBirth']!.text),
            'nationality': controllers['nationality']!.text,
            'documentNumber': controllers['documentNumber']!.text,
            'documentType': controllers['documentType']!.text,
            'type': controllers['type']!.text,
            'gender': controllers['gender']!.text,
          },
        )
        .toList();

    widget.onDataChanged({
      'contactInfo': contactInfo,
      'passengers': passengers,
    });
  }

  /// Convert date from dd/mm/yyyy format to ISO8601 string
  String _convertDateToISO(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      // Parse dd/mm/yyyy format
      final parts = dateString.split('/');
      if (parts.length != 3) return dateString;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final date = DateTime(year, month, day);
      return date.toIso8601String();
    } catch (e) {
      // Return original string if parsing fails
      return dateString;
    }
  }

  /// Convert ISO8601 date string to dd/mm/yyyy display format
  String _convertISOToDisplayDate(String isoString) {
    if (isoString.isEmpty) return '';

    try {
      final date = DateTime.parse(isoString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      // Return original string if parsing fails
      return isoString;
    }
  }
}
