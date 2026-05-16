import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class PasswordField extends StatelessWidget {
  final bool obscurePassword;

  final Function(String) onChanged;

  final VoidCallback onToggle;

  const PasswordField({
    super.key,
    required this.obscurePassword,
    required this.onChanged,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscurePassword,

      onChanged: onChanged,

      style: const TextStyle(
        fontSize: 15,
        color: ThemeColors.unifiedTextPrimary,
      ),

      decoration: InputDecoration(
        hintText: 'Password',

        hintStyle: const TextStyle(
          color: ThemeColors.unifiedTextMuted,
          fontSize: 15,
        ),

        prefixIcon: const Icon(
          Icons.lock_outline,
          color: ThemeColors.unifiedAccent,
          size: 20,
        ),

        suffixIcon: IconButton(
          onPressed: onToggle,

          icon: Icon(
            obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,

            color: ThemeColors.unifiedAccent,
            size: 20,
          ),
        ),

        filled: true,
        fillColor: ThemeColors.unifiedInputBg,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),

          borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),

          borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),

          borderSide: const BorderSide(
            color: ThemeColors.unifiedPrimary,
            width: 2,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
