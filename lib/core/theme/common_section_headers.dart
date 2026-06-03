import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class CommaonSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const CommaonSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: ThemeColors.unifiedPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 15, color: ThemeColors.unifiedPrimary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: ThemeColors.unifiedTextPrimary,
            letterSpacing: -0.2,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}
