import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ThemeColors.unifiedBorder)),
      ),
      child: Column(
        children: [
          // ── Links ─────────────────────────────────────────────────────────
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children: ['Privacy', 'Terms', 'Cookies', 'Help']
                .map(
                  (item) => TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),

          // ── Brand names with color ────────────────────────────────────────
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '© 2025 ',
                  style: TextStyle(
                    fontSize: 11,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
                TextSpan(
                  text: 'UM Enterprises',
                  style: TextStyle(
                    fontSize: 11,
                    color: ThemeColors.unifiedPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' & ',
                  style: TextStyle(
                    fontSize: 11,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
                TextSpan(
                  text: 'Matrix Pharma',
                  style: TextStyle(
                    fontSize: 11,
                    color: ThemeColors.unifiedSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: '. All rights reserved.',
                  style: TextStyle(
                    fontSize: 11,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
