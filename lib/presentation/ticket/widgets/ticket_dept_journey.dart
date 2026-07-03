import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class DeptJourneySection extends StatelessWidget {
  final List<dynamic> journey;
  const DeptJourneySection({required this.journey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_rounded,
                size: 12,
                color: ThemeColors.unifiedTextMuted,
              ),
              const SizedBox(width: 6),
              Text(
                'LIFECYCLE PATH',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: ThemeColors.unifiedTextMuted.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(journey.length, (index) {
                final dept = journey[index] as Map<String, dynamic>;
                final role = (dept['role'] ?? 'LINK').toString();
                final isLast = index == journey.length - 1;

                Color activeColor;
                String label = role;

                if (role == 'ORIGIN') {
                  activeColor = ThemeColors.unifiedPrimary;
                  label = 'ORIGIN';
                } else if (role == 'CURRENT') {
                  activeColor = ThemeColors.unifiedSecondary;
                  label = 'CURRENT';
                } else if (role == 'TRANSFER') {
                  activeColor = ThemeColors.unifiedWarning;
                  label = 'TRANSFER';
                } else {
                  activeColor = ThemeColors.unifiedTextMuted;
                  label = 'LINK';
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isLast
                                ? activeColor.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isLast
                                  ? activeColor.withOpacity(0.4)
                                  : ThemeColors.unifiedBorder,
                              width: isLast ? 1.5 : 1,
                            ),
                            boxShadow: isLast
                                ? [
                                    BoxShadow(
                                      color: activeColor.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            dept['code'] ?? '??',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isLast
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: isLast
                                  ? activeColor
                                  : ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            color: isLast
                                ? activeColor
                                : ThemeColors.unifiedTextMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: ThemeColors.unifiedBorder.withOpacity(0.8),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
