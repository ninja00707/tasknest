import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';

// ── Empty state ───────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final bool filterActive;
  final VoidCallback onClear;

  const EmptyState({required this.filterActive, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ThemeColors.unifiedPrimary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ThemeColors.unifiedPrimary.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Icon(
                filterActive
                    ? Icons.filter_alt_off_rounded
                    : Icons.inbox_rounded,
                size: 34,
                color: ThemeColors.unifiedPrimary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              filterActive ? ConstStrings.noMatchingTickets : ConstStrings.noTicketsYet,
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: 6),
            Text(
              filterActive
                  ? ConstStrings.tryAdjustingFilters
                  : ConstStrings.ticketsWillAppear,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: ThemeColors.unifiedTextMuted,
                height: 1.5,
              ),
            ),
            if (filterActive) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ThemeColors.unifiedGradStart,
                        ThemeColors.unifiedGradEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeColors.unifiedPrimary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.filter_alt_off_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 7),
                      Text(
                        ConstStrings.clearFilters,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
