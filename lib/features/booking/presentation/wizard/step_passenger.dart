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
  final _contactNameController = TextEditingController();

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
    _contactNameController.dispose();

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
        'idNumber': TextEditingController(),
        'idType': TextEditingController(text: 'CCCD'),
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
    _contactNameController.text = contactInfo['name'] ?? '';

    for (
      int i = 0;
      i < passengers.length && i < _passengerControllers.length;
      i++
    ) {
      final passenger = passengers[i];
      final controllers = _passengerControllers[i];

      controllers['firstName']?.text = passenger['firstName'] ?? '';
      controllers['lastName']?.text = passenger['lastName'] ?? '';
      controllers['dateOfBirth']?.text = passenger['dateOfBirth'] ?? '';
      controllers['nationality']?.text = passenger['nationality'] ?? 'Việt Nam';
      controllers['idNumber']?.text = passenger['idNumber'] ?? '';
      controllers['idType']?.text = passenger['idType'] ?? 'CCCD';
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

                    AppTextField(
                      controller: _contactNameController,
                      label: 'Họ và tên người liên hệ',
                      hint: 'Nhập họ và tên đầy đủ',
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập họ và tên';
                        }
                        return null;
                      },
                      onChanged: _saveData,
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
                                      _passengerControllers[index]['idType']!
                                          .text
                                          .isNotEmpty
                                      ? _passengerControllers[index]['idType']!
                                            .text
                                      : 'CCCD',
                                  decoration: const InputDecoration(
                                    labelText: 'Loại giấy tờ',
                                    prefixIcon: Icon(Icons.badge),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'CCCD',
                                      child: Text('CCCD'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'CMND',
                                      child: Text('CMND'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Passport',
                                      child: Text('Hộ chiếu'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      _passengerControllers[index]['idType']!
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
                                      _passengerControllers[index]['idNumber']!,
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
    if (_contactNameController.text.isNotEmpty &&
        _passengerControllers.isNotEmpty) {
      final nameParts = _contactNameController.text.split(' ');
      if (nameParts.length >= 2) {
        _passengerControllers[0]['lastName']!.text = nameParts.first;
        _passengerControllers[0]['firstName']!.text = nameParts
            .skip(1)
            .join(' ');
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
  }

  void _saveData([String? _]) {
    final contactInfo = {
      'name': _contactNameController.text,
      'email': _contactEmailController.text,
      'phone': _contactPhoneController.text,
    };

    final passengers = _passengerControllers
        .map(
          (controllers) => {
            'firstName': controllers['firstName']!.text,
            'lastName': controllers['lastName']!.text,
            'dateOfBirth': controllers['dateOfBirth']!.text,
            'nationality': controllers['nationality']!.text,
            'idNumber': controllers['idNumber']!.text,
            'idType': controllers['idType']!.text,
          },
        )
        .toList();

    widget.onDataChanged({
      'contactInfo': contactInfo,
      'passengers': passengers,
    });
  }
}
