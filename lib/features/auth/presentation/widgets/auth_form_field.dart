import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom form field for authentication forms
class AuthFormField extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;

  const AuthFormField({
    super.key,
    required this.label,
    this.hintText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
  });

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          textCapitalization: widget.textCapitalization,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            errorText: widget.errorText,
            counterText: '', // Hide character counter
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }
    
    if (widget.suffixIcon != null) {
      return widget.onSuffixIconPressed != null
          ? IconButton(
              onPressed: widget.onSuffixIconPressed,
              icon: widget.suffixIcon!,
            )
          : widget.suffixIcon;
    }
    
    return null;
  }
}

/// Password strength indicator
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strength = _calculatePasswordStrength(password);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength.score / 4,
                backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(strength.color),
                minHeight: 4,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              strength.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: strength.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (password.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...strength.requirements.map((req) => _buildRequirement(
            context,
            req.text,
            req.isMet,
          )),
        ],
      ],
    );
  }

  Widget _buildRequirement(BuildContext context, String text, bool isMet) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isMet
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        score: 0,
        label: '',
        color: Colors.transparent,
        requirements: [],
      );
    }

    int score = 0;
    final requirements = <PasswordRequirement>[];

    // Length requirement
    final hasMinLength = password.length >= 8;
    requirements.add(PasswordRequirement('Ít nhất 8 ký tự', hasMinLength));
    if (hasMinLength) score++;

    // Uppercase requirement
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    requirements.add(PasswordRequirement('Chứa chữ hoa', hasUppercase));
    if (hasUppercase) score++;

    // Lowercase requirement
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    requirements.add(PasswordRequirement('Chứa chữ thường', hasLowercase));
    if (hasLowercase) score++;

    // Number requirement
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    requirements.add(PasswordRequirement('Chứa số', hasNumber));
    if (hasNumber) score++;

    // Special character (optional)
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    if (hasSpecialChar) score++;

    String label;
    Color color;

    switch (score) {
      case 0:
      case 1:
        label = 'Yếu';
        color = Colors.red;
        break;
      case 2:
        label = 'Trung bình';
        color = Colors.orange;
        break;
      case 3:
        label = 'Khá';
        color = Colors.yellow[700]!;
        break;
      case 4:
      default:
        label = 'Mạnh';
        color = Colors.green;
        break;
    }

    return PasswordStrength(
      score: score,
      label: label,
      color: color,
      requirements: requirements,
    );
  }
}

class PasswordStrength {
  final int score;
  final String label;
  final Color color;
  final List<PasswordRequirement> requirements;

  PasswordStrength({
    required this.score,
    required this.label,
    required this.color,
    required this.requirements,
  });
}

class PasswordRequirement {
  final String text;
  final bool isMet;

  PasswordRequirement(this.text, this.isMet);
}
