import 'package:flutter/material.dart';

// Colors from Figma design
const Color kPrimaryColor = Color(0xFF2C2C2C);
const Color kSecondaryColor = Color(0xFFF5F5F5);
const Color kAccentColor = Color(0xFFFF6B2C);
const Color kTextPrimary = Color(0xFF2C2C2C);
const Color kTextSecondary = Color(0xFF666666);
const Color kBorderColor = Color(0xFFE0E0E0);

// Text styles from Figma
class AuthTextStyles {
  static const TextStyle mainHeading = TextStyle(
    fontSize: 60,
    height: 60 / 60,
    fontWeight: FontWeight.bold,
    color: kTextPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontSize:26,
    height: 48 / 48,
    fontWeight: FontWeight.bold,
    color: kTextPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 14,
    height: 28 / 20,
    fontWeight: FontWeight.normal,
    color: kTextPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 30,
    height: 36 / 30,
    fontWeight: FontWeight.bold,
    color: kTextPrimary,
  );

  static const TextStyle stat1 = TextStyle(
    fontSize: 16,
    height: 28 / 20,
    fontWeight: FontWeight.normal,
    color: kTextSecondary,
  );

  static const TextStyle stat2 = TextStyle(
    fontSize: 14,
    height: 24 / 16,
    fontWeight: FontWeight.normal,
    color: kTextSecondary,
  );

  static const TextStyle stat3 = TextStyle(
    fontSize: 12 ,
    height: 22.5 / 18,
    fontWeight: FontWeight.normal,
    color: kTextSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

// Custom input field widget
class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onSuffixIconPressed;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onSuffixIconPressed,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AuthTextStyles.h2),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AuthTextStyles.stat2.copyWith(
              color: kTextSecondary.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: kTextSecondary, size: 20)
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: kTextSecondary, size: 20),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

// Primary button widget
class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 327, // fixed width
      height: 48, // fixed height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B1A18),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48),
            side: const BorderSide(
              color: Colors.white,
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(text, style: AuthTextStyles.button),
      ),
    );
  }
}

// Secondary button widget
class AuthSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: kPrimaryColor,
          side: const BorderSide(color: kPrimaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: AuthTextStyles.button.copyWith(color: kPrimaryColor),
              ),
      ),
    );
  }
}

// Google sign-in button
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 327,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: kTextPrimary,
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.g_mobiledata, size: 24);
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: AuthTextStyles.button.copyWith(color: kTextPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// Divider with "or" text
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: kBorderColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: AuthTextStyles.stat2.copyWith(color: kTextSecondary),
          ),
        ),
        Expanded(child: Container(height: 1, color: kBorderColor)),
      ],
    );
  }
}

// Checkbox with terms text
class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: kPrimaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AuthTextStyles.stat3,
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Services',
                  style: AuthTextStyles.stat3.copyWith(
                    color: kPrimaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AuthTextStyles.stat3.copyWith(
                    color: kPrimaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Error message widget
class AuthErrorMessage extends StatelessWidget {
  final String message;

  const AuthErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AuthTextStyles.stat2.copyWith(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
