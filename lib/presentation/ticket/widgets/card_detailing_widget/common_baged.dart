import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class CommonBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  /// If true, uses neutral background like HeroBadge.
  final bool outlined;

  const CommonBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = outlined
        ? ThemeColors.unifiedBackground
        : color.withValues(alpha: 0.1);

    final borderColor = outlined
        ? ThemeColors.unifiedBorder
        : color.withValues(alpha: 0.25);

    final textColor = outlined ? ThemeColors.unifiedTextMuted : color;

    final iconColor = outlined ? ThemeColors.unifiedTextMuted : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: iconColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: outlined ? 11 : 10,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
