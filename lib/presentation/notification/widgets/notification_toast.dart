import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/notification/bloc/notification_bloc.dart';
import 'package:tasknest/presentation/notification/widgets/notification_panel.dart';

class LiveNotificationShell extends StatelessWidget {
  final Widget child;
  const LiveNotificationShell({super.key, required this.child});

  static IconData iconFor(String type) {
    switch (type) {
      case 'TICKET_CREATED':
      case 'SUB_TICKET_CREATED':
        return Icons.add_circle_outline;
      case 'TICKET_ASSIGNED':
      case 'SUB_TICKET_ASSIGNED':
        return Icons.person_outline;
      case 'TICKET_STATUS_UPDATED':
      case 'SUB_TICKET_PROGRESS':
        return Icons.update;
      case 'TICKET_REOPENED':
      case 'SUB_TICKET_REOPENED':
        return Icons.replay;
      case 'SUB_TICKET_COMPLETED':
        return Icons.check_circle_outline;
      case 'COMMENT_ADDED':
        return Icons.chat_bubble_outline;
      case 'NOTIFICATION':
        return Icons.notifications_outlined;
      case 'TICKET_UPDATED':
        return Icons.edit_outlined;
      default:
        return Icons.circle;
    }
  }

  static Color colorFor(String type) {
    switch (type) {
      case 'TICKET_CREATED':
      case 'SUB_TICKET_CREATED':
        return ThemeColors.unifiedPrimary;
      case 'TICKET_ASSIGNED':
      case 'SUB_TICKET_ASSIGNED':
        return ThemeColors.unifiedSecondary;
      case 'TICKET_STATUS_UPDATED':
      case 'SUB_TICKET_PROGRESS':
        return ThemeColors.unifiedWarning;
      case 'TICKET_REOPENED':
      case 'SUB_TICKET_REOPENED':
        return ThemeColors.unifiedSecondary;
      case 'SUB_TICKET_COMPLETED':
        return ThemeColors.unifiedSuccess;
      case 'COMMENT_ADDED':
        return ThemeColors.unifiedAccent;
      case 'NOTIFICATION':
        return ThemeColors.unifiedPrimary;
      case 'TICKET_UPDATED':
        return ThemeColors.unifiedInfo;
      default:
        return ThemeColors.unifiedTextMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (html.Notification.permission == 'default')
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              child: InkWell(
                onTap: () => html.Notification.requestPermission(),
                child: Container(
                  color: ThemeColors.unifiedPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: const Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Enable desktop notifications for real-time updates',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is! NotificationLoaded || state.toasts.isEmpty) {
              return const SizedBox.shrink();
            }
            return Positioned(
              right: 16,
              bottom: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final t in state.toasts.reversed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ToastCard(
                        toast: t,
                        icon: iconFor(t.type),
                        color: colorFor(t.type),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: BlocSelector<DashboardBloc, DashboardState, int>(
            selector: (state) => state is DashboardLoaded ? state.unreadNotificationCount : 0,
            builder: (context, count) => _SquareNotificationFab(count: count),
          ),
        ),
      ],
    );
  }
}

class _SquareNotificationFab extends StatelessWidget {
  final int count;
  const _SquareNotificationFab({required this.count});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: ThemeColors.unifiedPrimary,
      child: InkWell(
        onTap: () => NotificationPanel.show(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
              if (count > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: ThemeColors.unifiedDanger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  final ToastData toast;
  final IconData icon;
  final Color color;
  const _ToastCard({required this.toast, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 300,
        constraints: const BoxConstraints(maxHeight: 80),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (toast.ticketNumber != null)
                    Text(
                      '#${toast.ticketNumber}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.unifiedSecondary,
                      ),
                    ),
                  Text(
                    toast.message,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
