// ── Mobile Top Bar ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class MobileTopBar extends StatelessWidget {
  const MobileTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Taskify',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
