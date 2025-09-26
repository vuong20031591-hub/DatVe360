import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  
  bool _isLoading = false;
  bool _hasChanges = false;

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
              backgroundImage: user.avatar != null 
                ? NetworkImage(user.avatar!) 
                : null,
              child: user.avatar == null
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

  void _changeAvatar() {
    // TODO: Implement avatar change functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(localeProvider).languageCode == 'vi'
            ? 'Tính năng thay đổi ảnh đại diện sẽ được cập nhật sớm'
            : 'Avatar change feature coming soon',
        ),
      ),
    );
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
      
      final updatedUser = currentUser.copyWith(
        displayName: _displayNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim(),
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
