import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/destination_admin.dart';

class DestinationFormDialog extends StatefulWidget {
  final DestinationAdmin? destination;
  final Position? currentPosition;
  final Function(DestinationAdmin) onSave;

  const DestinationFormDialog({
    super.key,
    this.destination,
    this.currentPosition,
    required this.onSave,
  });

  @override
  State<DestinationFormDialog> createState() => _DestinationFormDialogState();
}

class _DestinationFormDialogState extends State<DestinationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _codeController = TextEditingController();
  final _cityController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'bus_station';
  bool _isActive = true;
  bool _isPopular = false;
  String? _imageUrl;
  bool _isUploading = false;

  final List<String> _destinationTypes = [
    'airport',
    'bus_station',
    'train_station',
    'port',
  ];

  final Map<String, String> _typeNames = {
    'airport': 'Sân bay',
    'bus_station': 'Bến xe',
    'train_station': 'Ga tàu',
    'port': 'Cảng',
  };

  @override
  void initState() {
    super.initState();
    if (widget.destination != null) {
      _nameController.text = widget.destination!.name;
      _nameEnController.text = widget.destination!.nameEn ?? '';
      _codeController.text = widget.destination!.code;
      _cityController.text = widget.destination!.city;
      _latitudeController.text = widget.destination!.latitude?.toString() ?? '';
      _longitudeController.text = widget.destination!.longitude?.toString() ?? '';
      _descriptionController.text = widget.destination!.description ?? '';
      _selectedType = widget.destination!.type;
      _isActive = widget.destination!.active;
      _isPopular = widget.destination!.popular;
      _imageUrl = widget.destination!.imageUrl;
    } else if (widget.currentPosition != null) {
      // Pre-fill with current location
      _latitudeController.text = widget.currentPosition!.latitude.toString();
      _longitudeController.text = widget.currentPosition!.longitude.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnController.dispose();
    _codeController.dispose();
    _cityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _isUploading = true;
      });

      // TODO: Upload image to server
      // For now, just use local path
      setState(() {
        _imageUrl = image.path;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã chọn ảnh')),
        );
      }
    }
  }

  void _useCurrentLocation() {
    if (widget.currentPosition != null) {
      setState(() {
        _latitudeController.text = widget.currentPosition!.latitude.toString();
        _longitudeController.text = widget.currentPosition!.longitude.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã sử dụng vị trí hiện tại')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có vị trí hiện tại')),
      );
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final destination = DestinationAdmin(
        id: widget.destination?.id,
        name: _nameController.text.trim(),
        nameEn: _nameEnController.text.trim().isEmpty
            ? null
            : _nameEnController.text.trim(),
        code: _codeController.text.trim().toUpperCase(),
        type: _selectedType,
        city: _cityController.text.trim(),
        latitude: _latitudeController.text.isEmpty
            ? null
            : double.tryParse(_latitudeController.text),
        longitude: _longitudeController.text.isEmpty
            ? null
            : double.tryParse(_longitudeController.text),
        active: _isActive,
        popular: _isPopular,
        imageUrl: _imageUrl,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      widget.onSave(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.destination != null;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Sửa điểm đến' : 'Thêm điểm đến mới',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image picker
                      Center(
                        child: GestureDetector(
                          onTap: _isUploading ? null : _pickImage,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              image: _imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(_imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _isUploading
                                ? const Center(child: CircularProgressIndicator())
                                : _imageUrl == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate,
                                              size: 48, color: Colors.grey[600]),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Chọn ảnh',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      )
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên điểm đến *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên điểm đến';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Name (English)
                      TextFormField(
                        controller: _nameEnController,
                        decoration: const InputDecoration(
                          labelText: 'Tên tiếng Anh',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Code
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Mã điểm đến *',
                          border: OutlineInputBorder(),
                          hintText: 'VD: SGN, HAN, DAD',
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập mã điểm đến';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Type
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Loại điểm đến *',
                          border: OutlineInputBorder(),
                        ),
                        items: _destinationTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_typeNames[type] ?? type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // City
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Thành phố *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập thành phố';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location section
                      Row(
                        children: [
                          const Text(
                            'Tọa độ GPS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _useCurrentLocation,
                            icon: const Icon(Icons.my_location, size: 18),
                            label: const Text('Vị trí hiện tại'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Vĩ độ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _longitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Kinh độ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Switches
                      SwitchListTile(
                        title: const Text('Kích hoạt'),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                      SwitchListTile(
                        title: const Text('Điểm đến phổ biến'),
                        value: _isPopular,
                        onChanged: (value) => setState(() => _isPopular = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

