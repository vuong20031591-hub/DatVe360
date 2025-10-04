import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transport_operator.dart';
import '../../domain/providers/categories_admin_provider.dart';

class OperatorFormDialog extends ConsumerStatefulWidget {
  final TransportOperator? operator;
  final String initialType;

  const OperatorFormDialog({
    super.key,
    this.operator,
    required this.initialType,
  });

  @override
  ConsumerState<OperatorFormDialog> createState() =>
      _OperatorFormDialogState();
}

class _OperatorFormDialogState extends ConsumerState<OperatorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  late final TextEditingController _addressController;
  late final TextEditingController _logoController;
  late final TextEditingController _descriptionController;

  final Set<String> _selectedTypes = {};
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.operator?.name ?? '');
    _codeController = TextEditingController(text: widget.operator?.code ?? '');
    _phoneController =
        TextEditingController(text: widget.operator?.contactInfo?.phone ?? '');
    _emailController =
        TextEditingController(text: widget.operator?.contactInfo?.email ?? '');
    _websiteController = TextEditingController(
        text: widget.operator?.contactInfo?.website ?? '');
    _addressController = TextEditingController(
        text: widget.operator?.contactInfo?.address ?? '');
    _logoController =
        TextEditingController(text: widget.operator?.logo ?? '');
    _descriptionController =
        TextEditingController(text: widget.operator?.description ?? '');

    if (widget.operator != null) {
      _selectedTypes.addAll(widget.operator!.transportTypes);
      _isActive = widget.operator!.isActive;
    } else {
      _selectedTypes.add(widget.initialType);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _logoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.operator == null
          ? 'Thêm nhà cung cấp'
          : 'Sửa nhà cung cấp'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên nhà cung cấp *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Mã *',
                  border: OutlineInputBorder(),
                  hintText: 'VD: VN, FUTA',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Loại phương tiện *',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Máy bay'),
                    selected: _selectedTypes.contains('flight'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTypes.add('flight');
                        } else {
                          _selectedTypes.remove('flight');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Tàu hỏa'),
                    selected: _selectedTypes.contains('train'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTypes.add('train');
                        } else {
                          _selectedTypes.remove('train');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Xe khách'),
                    selected: _selectedTypes.contains('bus'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTypes.add('bus');
                        } else {
                          _selectedTypes.remove('bus');
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _logoController,
                decoration: const InputDecoration(
                  labelText: 'URL Logo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Đang hoạt động'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.operator == null ? 'Thêm' : 'Cập nhật'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 loại phương tiện')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim().toUpperCase(),
        'transportTypes': _selectedTypes.toList(),
        'contactInfo': {
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'website': _websiteController.text.trim(),
          'address': _addressController.text.trim(),
        },
        'metadata': {
          'logo': _logoController.text.trim(),
          'description': _descriptionController.text.trim(),
        },
        'isActive': _isActive,
      };

      if (widget.operator == null) {
        await ref.read(categoriesAdminProvider.notifier).createOperator(data);
      } else {
        await ref
            .read(categoriesAdminProvider.notifier)
            .updateOperator(widget.operator!.id, data);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

