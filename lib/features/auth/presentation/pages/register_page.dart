import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../data/models/user.dart';
import '../../data/models/auth_state.dart';
import '../../domain/providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _agreeToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final formValidation = ref.watch(registerFormProvider);
    final locale = ref.watch(localeProvider);
    final localizations = ref.watch(localizationsProvider(locale));

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/');
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.1),
              theme.colorScheme.tertiary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildIllustration(theme),
                  const SizedBox(height: 32),
                  _buildHeader(theme, localizations),
                  const SizedBox(height: 32),
                  _buildFormContainer(theme, formValidation, authState),
                  const SizedBox(height: 24),
                  _buildDivider(theme),
                  const SizedBox(height: 24),
                  _buildSocialLogin(),
                  const SizedBox(height: 32),
                  _buildLoginLink(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.secondary, theme.colorScheme.tertiary],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(Icons.person_add, size: 60, color: Colors.white),
      ),
    );
  }

  Widget _buildFormContainer(
    ThemeData theme,
    FormValidationState formValidation,
    AuthState authState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildRegisterForm(formValidation),
          const SizedBox(height: 24),
          _buildTermsAgreement(theme, formValidation),
          const SizedBox(height: 24),
          _buildRegisterButton(authState),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.createAccount,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.joinDatVe360,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(FormValidationState formValidation) {
    return Column(
      children: [
        AuthFormField(
          label: 'Họ và tên',
          hintText: 'Nhập họ và tên đầy đủ',
          controller: _fullNameController,
          focusNode: _fullNameFocusNode,
          textCapitalization: TextCapitalization.words,
          prefixIcon: const Icon(Icons.person_outline),
          errorText: formValidation.getError('fullName'),
          onChanged: (value) {
            ref.read(registerFormProvider.notifier).validateFullName(value);
          },
          onSubmitted: (_) {
            _emailFocusNode.requestFocus();
          },
        ),
        const SizedBox(height: 20),
        AuthFormField(
          label: 'Email',
          hintText: 'Nhập địa chỉ email',
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          errorText: formValidation.getError('email'),
          onChanged: (value) {
            ref.read(registerFormProvider.notifier).validateEmail(value);
          },
          onSubmitted: (_) {
            _phoneFocusNode.requestFocus();
          },
        ),
        const SizedBox(height: 20),
        AuthFormField(
          label: 'Số điện thoại (tùy chọn)',
          hintText: 'Nhập số điện thoại',
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined),
          errorText: formValidation.getError('phone'),
          onChanged: (value) {
            ref.read(registerFormProvider.notifier).validatePhone(value);
          },
          onSubmitted: (_) {
            _passwordFocusNode.requestFocus();
          },
        ),
        const SizedBox(height: 20),
        AuthFormField(
          label: 'Mật khẩu',
          hintText: 'Nhập mật khẩu',
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_outline),
          errorText: formValidation.getError('password'),
          onChanged: (value) {
            ref.read(registerFormProvider.notifier).validatePassword(value);
            // Also validate confirm password if it has value
            if (_confirmPasswordController.text.isNotEmpty) {
              ref
                  .read(registerFormProvider.notifier)
                  .validateConfirmPassword(
                    _confirmPasswordController.text,
                    value,
                  );
            }
          },
          onSubmitted: (_) {
            _confirmPasswordFocusNode.requestFocus();
          },
        ),
        const SizedBox(height: 8),
        PasswordStrengthIndicator(password: _passwordController.text),
        const SizedBox(height: 20),
        AuthFormField(
          label: 'Xác nhận mật khẩu',
          hintText: 'Nhập lại mật khẩu',
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_outline),
          errorText: formValidation.getError('confirmPassword'),
          onChanged: (value) {
            ref
                .read(registerFormProvider.notifier)
                .validateConfirmPassword(value, _passwordController.text);
          },
          onSubmitted: (_) {
            _handleRegister();
          },
        ),
      ],
    );
  }

  Widget _buildTermsAgreement(
    ThemeData theme,
    FormValidationState formValidation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
            ref
                .read(registerFormProvider.notifier)
                .validateTermsAgreement(_agreeToTerms);
          },
          title: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'Tôi đồng ý với '),
                TextSpan(
                  text: 'Điều khoản sử dụng',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' và '),
                TextSpan(
                  text: 'Chính sách bảo mật',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        if (formValidation.hasError('agreeToTerms'))
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              formValidation.getError('agreeToTerms')!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRegisterButton(AuthState authState) {
    return AuthButton.primary(
      text: 'Đăng ký',
      isLoading: authState.isLoading,
      onPressed: _handleRegister,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Hoặc',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        SocialLoginButton(
          text: 'Đăng ký với Google',
          icon: const Icon(Icons.g_mobiledata, size: 24),
          onPressed: _handleGoogleRegister,
        ),
        const SizedBox(height: 12),
        SocialLoginButton(
          text: 'Đăng ký với Facebook',
          icon: const Icon(Icons.facebook, size: 24),
          onPressed: _handleFacebookRegister,
        ),
      ],
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Đã có tài khoản? ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          LinkButton(text: 'Đăng nhập ngay', onPressed: () => context.pop()),
        ],
      ),
    );
  }

  void _handleRegister() {
    // Clear previous errors
    ref.read(authProvider.notifier).clearError();

    // Validate all fields
    ref
        .read(registerFormProvider.notifier)
        .validateFullName(_fullNameController.text);
    ref
        .read(registerFormProvider.notifier)
        .validateEmail(_emailController.text);
    ref
        .read(registerFormProvider.notifier)
        .validatePhone(_phoneController.text);
    ref
        .read(registerFormProvider.notifier)
        .validatePassword(_passwordController.text);
    ref
        .read(registerFormProvider.notifier)
        .validateConfirmPassword(
          _confirmPasswordController.text,
          _passwordController.text,
        );
    ref
        .read(registerFormProvider.notifier)
        .validateTermsAgreement(_agreeToTerms);

    final formValidation = ref.read(registerFormProvider);
    if (!formValidation.isValid) return;

    // Perform registration
    final request = RegisterRequest(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      agreeToTerms: _agreeToTerms,
    );

    ref.read(authProvider.notifier).register(request);
  }

  void _handleGoogleRegister() {
    // TODO: Implement Google registration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng ký Google sẽ được cập nhật sớm')),
    );
  }

  void _handleFacebookRegister() {
    // TODO: Implement Facebook registration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng ký Facebook sẽ được cập nhật sớm')),
    );
  }
}
