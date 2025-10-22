import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../auth/data/models/user.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  bool _hasChanges = false;
  XFile? _selectedImage;
  bool _avatarRemoved = false; // Track if user explicitly removed avatar

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && authState.user != null) {
      final user = authState.user!;
      _displayNameController.text = user.displayName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
    }

    // Listen for changes
    _displayNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && authState.user != null) {
      final user = authState.user!;
      final hasChanges = _displayNameController.text != user.displayName ||
          _emailController.text != user.email ||
          _phoneController.text != (user.phoneNumber ?? '');
      
      if (hasChanges != _hasChanges) {
        setState(() {
          _hasChanges = hasChanges;
        });
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated || authState.user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.locale.languageCode == 'vi' 
            ? 'Chỉnh sửa hồ sơ' 
            : 'Edit Profile'),
        ),
        body: const Center(
          child: Text('Vui lòng đăng nhập để chỉnh sửa hồ sơ'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.locale.languageCode == 'vi' 
          ? 'Chỉnh sửa hồ sơ' 
          : 'Edit Profile'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: Text(
                localizations.locale.languageCode == 'vi' ? 'Lưu' : 'Save',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar section
              _buildAvatarSection(theme, authState.user!),
              
              const SizedBox(height: 32),
              
              // Form fields
              _buildFormFields(localizations),
              
              const SizedBox(height: 32),
              
              // Save button
              if (_hasChanges)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            localizations.locale.languageCode == 'vi' 
                              ? 'Lưu thay đổi' 
                              : 'Save Changes',
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(ThemeData theme, User user) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: _selectedImage != null
                ? FileImage(File(_selectedImage!.path))
                : (user.avatar != null 
                  ? NetworkImage(user.avatar!) 
                  : null) as ImageProvider?,
              child: _selectedImage == null && user.avatar == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: theme.colorScheme.onPrimaryContainer,
                  )
                : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  onPressed: _changeAvatar,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(AppLocalizations localizations) {
    return Column(
      children: [
        // Display Name
        TextFormField(
          controller: _displayNameController,
          decoration: InputDecoration(
            labelText: localizations.fullName,
            prefixIcon: const Icon(Icons.person_outline),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localizations.locale.languageCode == 'vi'
                ? 'Vui lòng nhập họ tên'
                : 'Please enter your full name';
            }
            if (value.trim().length < 2) {
              return localizations.locale.languageCode == 'vi'
                ? 'Họ tên phải có ít nhất 2 ký tự'
                : 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Email
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: localizations.email,
            prefixIcon: const Icon(Icons.email_outlined),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localizations.locale.languageCode == 'vi'
                ? 'Vui lòng nhập email'
                : 'Please enter your email';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
              return localizations.locale.languageCode == 'vi'
                ? 'Email không hợp lệ'
                : 'Invalid email format';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Phone Number
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: localizations.phoneNumber,
            prefixIcon: const Icon(Icons.phone_outlined),
            border: const OutlineInputBorder(),
            hintText: localizations.locale.languageCode == 'vi'
              ? 'Tùy chọn'
              : 'Optional',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
                return localizations.locale.languageCode == 'vi'
                  ? 'Số điện thoại không hợp lệ'
                  : 'Invalid phone number';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _changeAvatar() async {
    final locale = ref.read(localeProvider);
    final isVi = locale.languageCode == 'vi';

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(isVi ? 'Chụp ảnh' : 'Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(isVi ? 'Chọn từ thư viện' : 'Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null || (ref.read(authProvider).user?.avatar != null))
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    isVi ? 'Xóa ảnh' : 'Remove Photo',
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _avatarRemoved = true; // Mark as removed
                      _hasChanges = true;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _avatarRemoved = false; // Reset removal flag
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(localeProvider).languageCode == 'vi'
                ? 'Lỗi chọn ảnh: ${e.toString()}'
                : 'Error picking image: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authProvider);
      final currentUser = authState.user!;
      
      // Handle avatar update logic
      String? avatarBase64;
      
      if (_avatarRemoved) {
        // User explicitly removed avatar
        avatarBase64 = null;
      } else if (_selectedImage != null) {
        // User selected new image: convert to base64
        final bytes = await File(_selectedImage!.path).readAsBytes();
        avatarBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else {
        // No change: keep current avatar
        avatarBase64 = currentUser.avatar;
      }
      
      final updatedUser = currentUser.copyWith(
        displayName: _displayNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim(),
        avatar: avatarBase64,
      );

      await ref.read(authProvider.notifier).updateProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(localeProvider).languageCode == 'vi'
                ? 'Cập nhật hồ sơ thành công'
                : 'Profile updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(localeProvider).languageCode == 'vi'
                ? 'Lỗi cập nhật hồ sơ: ${e.toString()}'
                : 'Error updating profile: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
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
