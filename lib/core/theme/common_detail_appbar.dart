// ── App Bar ───────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';

class CommonDetailAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  final TicketModel? ticket;
  final String? title;
  final bool issuffixStatus;
  final VoidCallback? onHistoryPressed;

  const CommonDetailAppbar({
    super.key,
    required this.ticket,
    required this.title,
    required this.issuffixStatus,
    this.onHistoryPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 57,
      child: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: ThemeColors.unifiedBorder),
        ),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeColors.unifiedBackground,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: ThemeColors.unifiedBorder,
                  width: 1.5,
                ),
              ),
              child: Text(
                '#${title ?? ticket?.id}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextMuted,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${title ?? ticket?.title}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: onHistoryPressed != null
                ? IconButton(
                    icon: const Icon(
                      Icons.history_rounded,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                    onPressed: onHistoryPressed,
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: issuffixStatus && ticket != null
                ? Row(
                    children: [
                      PriorityBadge(priority: ticket!.priority),
                      const SizedBox(width: 6),
                      StatusBadge(status: ticket!.status),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
