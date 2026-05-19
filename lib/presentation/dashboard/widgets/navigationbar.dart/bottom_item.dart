import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class BotItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, selected;
  final void Function(int) onTap;
  const BotItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSel = index == selected;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSel
                  ? ThemeColors.unifiedPrimary
                  : ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSel
                    ? ThemeColors.unifiedPrimary
                    : ThemeColors.unifiedTextMuted,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
