import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/user.dart';
import '../../data/models/auth_state.dart';
import '../../domain/providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final formValidation = ref.watch(loginFormProvider);

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
                  _buildHeader(theme),
                  const SizedBox(height: 32),
                  _buildFormContainer(theme, formValidation, authState),
                  const SizedBox(height: 24),
                  _buildDivider(theme),
                  const SizedBox(height: 24),
                  _buildSocialLogin(),
                  const SizedBox(height: 32),
                  _buildSignUpLink(theme),
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
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(Icons.flight_takeoff, size: 60, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào mừng trở lại!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Đăng nhập để tiếp tục sử dụng DatVe360',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
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
          _buildLoginForm(formValidation),
          const SizedBox(height: 24),
          _buildRememberMeAndForgotPassword(theme),
          const SizedBox(height: 24),
          _buildLoginButton(authState),
        ],
      ),
    );
  }

  Widget _buildLoginForm(FormValidationState formValidation) {
    return Column(
      children: [
        AuthFormField(
          label: 'Email hoặc số điện thoại',
          hintText: 'Nhập email hoặc số điện thoại',
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.person_outline),
          errorText: formValidation.getError('emailOrPhone'),
          onChanged: (value) {
            ref.read(loginFormProvider.notifier).validateEmailOrPhone(value);
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
            ref.read(loginFormProvider.notifier).validatePassword(value);
          },
          onSubmitted: (_) {
            _handleLogin();
          },
        ),
      ],
    );
  }

  Widget _buildRememberMeAndForgotPassword(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            value: _rememberMe,
            onChanged: (value) {
              setState(() {
                _rememberMe = value ?? false;
              });
            },
            title: Text('Ghi nhớ đăng nhập', style: theme.textTheme.bodyMedium),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        LinkButton(text: 'Quên mật khẩu?', onPressed: _handleForgotPassword),
      ],
    );
  }

  Widget _buildLoginButton(AuthState authState) {
    return AuthButton.primary(
      text: 'Đăng nhập',
      isLoading: authState.isLoading,
      onPressed: _handleLogin,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.colorScheme.outline.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Hoặc',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.colorScheme.outline.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SocialLoginButton(
              text: 'Google',
              icon: const Icon(Icons.g_mobiledata, size: 24),
              onPressed: _handleGoogleLogin,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SocialLoginButton(
              text: 'Facebook',
              icon: const Icon(Icons.facebook, size: 24),
              onPressed: _handleFacebookLogin,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chưa có tài khoản? ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          LinkButton(
            text: 'Đăng ký ngay',
            onPressed: () => context.push('/register'),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    // Clear previous errors
    ref.read(authProvider.notifier).clearError();

    // Validate form
    ref
        .read(loginFormProvider.notifier)
        .validateEmailOrPhone(_emailController.text);
    ref
        .read(loginFormProvider.notifier)
        .validatePassword(_passwordController.text);

    final formValidation = ref.read(loginFormProvider);
    if (!formValidation.isValid) return;

    // Perform login
    final request = LoginRequest(
      emailOrPhone: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    ref.read(authProvider.notifier).login(request);
  }

  void _handleForgotPassword() {
    context.push('/forgot-password');
  }

  void _handleGoogleLogin() {
    // TODO: Implement Google login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng nhập Google sẽ được cập nhật sớm')),
    );
  }

  void _handleFacebookLogin() {
    // TODO: Implement Facebook login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng nhập Facebook sẽ được cập nhật sớm')),
    );
  }
}
