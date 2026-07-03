import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/data/datasource/socket_service.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/ticket/widgets/notification_panel.dart';

class LiveNotificationShell extends StatefulWidget {
  final Widget child;
  const LiveNotificationShell({super.key, required this.child});

  @override
  State<LiveNotificationShell> createState() => _LiveNotificationShellState();
}

class _LiveNotificationShellState extends State<LiveNotificationShell> {
  StreamSubscription<SocketEvent>? _sub;
  final List<_ToastData> _toasts = [];
  int _idSeq = 0;
  final Set<int> _recentNotificationIds = {};

  @override
  void initState() {
    super.initState();
    _sub = SocketService().events.listen(_onSocketEvent);
    html.document.onVisibilityChange.listen((_) {
      if (html.document.hidden == false && !SocketService().isConnected) {
        SocketService().reconnect();
      }
    });
  }

  void _requestBrowserPermission() {
    html.Notification.requestPermission().then((perm) {
      if (mounted) setState(() {});
    });
  }

  void _showBrowserNotification(SocketEvent event) {
    if (html.Notification.permission != 'granted') return;
    final data = event.data is Map ? event.data as Map : <dynamic, dynamic>{};
    final title = _labelFor(event.type);
    final message = data['message'] as String? ?? title;
    try {
      html.Notification(title, body: message);
    } catch (_) {} // Chrome can throw if called from non-secure context or during tab switch
  }

  void _onSocketEvent(SocketEvent event) {
    if (event.type == 'NOTIFICATION_COUNT' || event.type == 'SOCKET_CONNECTED') return;

    final data = event.data is Map ? event.data as Map : <dynamic, dynamic>{};

    // Only show toast/browser notification when a real notification record exists
    final notifId = data['notificationId'];
    if (notifId == null) return;

    // Deduplicate: skip if we already showed a toast for this notificationId
    if (_recentNotificationIds.contains(notifId)) return;
    _recentNotificationIds.add(notifId);
    if (_recentNotificationIds.length > 50) {
      _recentNotificationIds.remove(_recentNotificationIds.first);
    }

    _showBrowserNotification(event);

    final id = ++_idSeq;

    final toast = _ToastData(
      id: id,
      type: event.type,
      ticketNumber: data['ticketNumber'] as String?,
      message: data['message'] as String? ?? _labelFor(event.type),
    );

    if (!mounted) return;
    setState(() => _toasts.add(toast));

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _toasts.removeWhere((t) => t.id == id));
      }
    });
  }

  String _labelFor(String type) {
    switch (type) {
      case 'TICKET_CREATED': return 'New ticket created';
      case 'TICKET_ASSIGNED': return 'Ticket assigned';
      case 'TICKET_STATUS_UPDATED': return 'Ticket status updated';
      case 'TICKET_REOPENED': return 'Ticket reopened';
      case 'SUB_TICKET_CREATED': return 'Sub-ticket created';
      case 'SUB_TICKET_ASSIGNED': return 'Sub-ticket assigned';
      case 'SUB_TICKET_PROGRESS': return 'Sub-ticket progress updated';
      case 'SUB_TICKET_COMPLETED': return 'Sub-ticket completed';
      case 'SUB_TICKET_REOPENED': return 'Sub-ticket reopened';
      case 'COMMENT_ADDED': return 'New comment added';
      case 'NOTIFICATION': return 'New notification';
      case 'TICKET_UPDATED': return 'Ticket details updated';
      default: return type;
    }
  }

  IconData _iconFor(String type) {
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

  Color _colorFor(String type) {
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
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // ── Browser notification permission banner ───────────────
        if (html.Notification.permission == 'default')
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              child: InkWell(
                onTap: _requestBrowserPermission,
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
        // Toast stack — bottom-right, above FAB
        if (_toasts.isNotEmpty)
          Positioned(
            right: 16,
            bottom: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final t in _toasts.reversed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ToastCard(toast: t, icon: _iconFor(t.type), color: _colorFor(t.type)),
                  ),
              ],
            ),
          ),
        // Square FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: BlocSelector<DashboardBloc, DashboardState, int>(
            selector: (state) => state is DashboardLoaded ? state.unreadNotificationCount : 0,
            builder: (context, count) => SquareNotificationFab(count: count),
          ),
        ),
      ],
    );
  }
}

class SquareNotificationFab extends StatelessWidget {
  final int count;
  const SquareNotificationFab({super.key, required this.count});

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

class _ToastData {
  final int id;
  final String type;
  final String? ticketNumber;
  final String message;
  _ToastData({required this.id, required this.type, this.ticketNumber, required this.message});
}

class _ToastCard extends StatelessWidget {
  final _ToastData toast;
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
