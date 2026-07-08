// ── Section Card ──────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class CommonSectionCardContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const CommonSectionCardContainer({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ThemeColors.unifiedBorder,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 14, color: ThemeColors.unifiedTextMuted),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextMuted,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}
