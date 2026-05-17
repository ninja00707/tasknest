import 'package:flutter/material.dart';

import 'package:tasknest/core/theme/color.dart';

class CommonTextFormField extends StatelessWidget {
  final String hint;

  final IconData icon;

  final Function(String)? onChanged;

  final String? Function(String?)? validator;

  final bool obscurePassword;

  final VoidCallback? onToggle;

  final TextInputType keyboardType;

  final TextEditingController? controller;

  const CommonTextFormField({
    super.key,

    required this.hint,

    required this.icon,

    this.onChanged,

    this.validator,

    this.obscurePassword = false,

    this.onToggle,

    this.keyboardType = TextInputType.text,

    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,

      onChanged: onChanged,

      validator: validator,

      obscureText: obscurePassword,

      keyboardType: keyboardType,

      style: const TextStyle(
        fontSize: 15,
        color: ThemeColors.unifiedTextPrimary,
      ),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: const TextStyle(
          color: ThemeColors.unifiedTextMuted,
          fontSize: 15,
        ),

        prefixIcon: Icon(icon, color: ThemeColors.unifiedAccent, size: 20),

        suffixIcon: onToggle != null
            ? IconButton(
                onPressed: onToggle,

                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,

                  color: ThemeColors.unifiedAccent,
                  size: 20,
                ),
              )
            : null,

        filled: true,

        fillColor: ThemeColors.unifiedInputBg,

        errorMaxLines: 5,

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

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),

          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),

          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
