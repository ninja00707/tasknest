import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final Function(String) onChanged;

  const InputField({
    super.key,
    required this.hint,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,

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
