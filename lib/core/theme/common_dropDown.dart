import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class DropdownItem<T> {
  final T value;
  final String label;

  DropdownItem({required this.value, required this.label});
}

class CommonDropdown<T> extends StatelessWidget {
  final List<DropdownItem<T>> items;
  final T? value;
  final String hint;
  final Function(T value) onChanged;

  const CommonDropdown({
    super.key,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,

      // IMPORTANT
      hint: Text(
        hint,
        style: const TextStyle(
          color: ThemeColors.unifiedTextMuted,
          fontSize: 14,
        ),
      ),

      isExpanded: true,

      dropdownColor: ThemeColors.unifiedSurface,

      style: const TextStyle(
        fontSize: 14,
        color: ThemeColors.unifiedTextPrimary,
      ),

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: ThemeColors.unifiedTextMuted,
      ),

      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item.value,
          child: Text(
            item.label,
            style: const TextStyle(
              fontSize: 14,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
        );
      }).toList(),

      onChanged: (selectedValue) {
        if (selectedValue != null) {
          onChanged(selectedValue);
        }
      },

      decoration: InputDecoration(
        filled: true,
        fillColor: ThemeColors.unifiedInputBg,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

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
      ),
    );
  }
}
