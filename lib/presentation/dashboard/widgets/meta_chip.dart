import 'package:flutter/material.dart';

class MetaChip extends StatelessWidget {
  final String text;
  final bool emphasis;
  const MetaChip(this.text, {super.key, this.emphasis = false});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: emphasis ? 0.24 : 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
