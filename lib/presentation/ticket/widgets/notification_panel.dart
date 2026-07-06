import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/data/datasource/ticketdatasource/notification_remote_data_source.dart';
import 'package:tasknest/injection.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class NotificationPanel extends StatefulWidget {
  const NotificationPanel({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const NotificationPanel(),
    );
  }

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  final NotificationRemoteDataSource _dataSource = sl<NotificationRemoteDataSource>();
  List<NotificationModel>? _notifications;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final response = await _dataSource.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = response.notifications;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _dataSource.markAsRead(ids: [id]);
      _fetch();
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      await _dataSource.markAsRead();
      if (mounted) {
        context.read<DashboardBloc>().add(UpdateNotificationCount(0));
      }
      _fetch();
    } catch (_) {}
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _notifications == null || _notifications!.isEmpty ? 0.3 : 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_outlined, size: 20, color: ThemeColors.unifiedTextPrimary),
                const SizedBox(width: 8),
                Text(
                  ConstStrings.navNotifications,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
                const Spacer(),
                if (_notifications != null && _notifications!.any((n) => !n.isRead))
                  TextButton(
                    onPressed: _markAllRead,
                    child: const Text(ConstStrings.markAllRead, style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : _notifications == null || _notifications!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notifications_off_outlined,
                                  size: 40, color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.5)),
                              const SizedBox(height: 8),
                              Text(ConstStrings.noNotifications,
                                  style: AppTextStyles.bodyMuted),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: _notifications!.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final n = _notifications![i];
                            return InkWell(
                              onTap: n.isRead ? null : () => _markAsRead(n.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: n.isRead ? Colors.transparent : ThemeColors.unifiedPrimary.withValues(alpha: 0.04),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: n.isRead ? Colors.transparent : ThemeColors.unifiedPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (n.ticketNumber != null)
                                            Text(
                                              '#${n.ticketNumber}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: ThemeColors.unifiedSecondary,
                                              ),
                                            ),
                                          Text(
                                            n.message,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: ThemeColors.unifiedTextPrimary,
                                              fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _timeAgo(n.createdAt),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
