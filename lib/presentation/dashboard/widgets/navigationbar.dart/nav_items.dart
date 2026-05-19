import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, selected;
  final void Function(int) onTap;
  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    ThemeColors.unifiedGradStart,
                    ThemeColors.unifiedGradEnd,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? Colors.white : ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
