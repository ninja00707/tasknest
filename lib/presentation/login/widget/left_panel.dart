import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dual brand logo row ──────────────────────────────────────────
          Row(
            children: [
              // UM logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedPrimary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColors.unifiedPrimary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  ConstStrings.appShortName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Link icon
              Container(
                width: 28,
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      ThemeColors.unifiedPrimary,
                      ThemeColors.unifiedSecondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),

              // Matrix logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ThemeColors.navySecondary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColors.navyAccent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'MX',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Company names ────────────────────────────────────────────────
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${ConstStrings.umEnterprises}\n',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedPrimary,
                    height: 1.15,
                  ),
                ),
                TextSpan(
                  text: '& ${ConstStrings.matrixPharma}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Tagline ──────────────────────────────────────────────────────
          Text(
            'One platform. Two companies. Seamless collaboration — manage tasks, track tickets, and keep every department in sync.',
            style: AppTextStyles.bodyMuted.copyWith(height: 1.65),
          ),
          const SizedBox(height: 28),

          // ── Feature chips ────────────────────────────────────────────────
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FeatureChip(
                icon: Icons.verified_user_outlined,
                label: 'Secure Login',
                useNavy: false,
              ),
              FeatureChip(
                icon: Icons.groups_outlined,
                label: 'Team Access',
                useNavy: true,
              ),
              FeatureChip(
                icon: Icons.analytics_outlined,
                label: 'Analytics',
                useNavy: false,
              ),
              FeatureChip(
                icon: Icons.task_alt_outlined,
                label: 'Ticket System',
                useNavy: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Feature Chip ──────────────────────────────────────────────────────────────
class FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool useNavy; // alternates between green and navy accent

  const FeatureChip({
    super.key,
    required this.icon,
    required this.label,
    this.useNavy = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = useNavy
        ? ThemeColors.unifiedSecondary
        : ThemeColors.unifiedPrimary;
    final bg = useNavy ? ThemeColors.statusOpenBg : ThemeColors.statusDoneBg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
