import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/notification/bloc/notification_bloc.dart';
import 'package:tasknest/presentation/notification/models/notification_model.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  static void show(BuildContext context) {
    context.read<NotificationBloc>().add(LoadNotifications());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<NotificationBloc>(),
        child: const NotificationPanel(),
      ),
    );
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
      initialChildSize: 0.5,
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
                BlocBuilder<NotificationBloc, NotificationState>(
                  buildWhen: (prev, curr) => prev != curr,
                  builder: (context, state) {
                    if (state is NotificationLoaded && state.notifications.any((n) => !n.isRead)) {
                      return TextButton(
                        onPressed: () => context.read<NotificationBloc>().add(MarkAllReadEvent()),
                        child: const Text(ConstStrings.markAllRead, style: TextStyle(fontSize: 13)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<NotificationBloc, NotificationState>(
                buildWhen: (prev, curr) => prev != curr,
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (state is NotificationError) {
                    return Center(child: Text(state.message, style: AppTextStyles.bodyMuted));
                  }
                  if (state is NotificationLoaded) {
                    if (state.notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_off_outlined,
                                size: 40, color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            Text(ConstStrings.noNotifications, style: AppTextStyles.bodyMuted),
                          ],
                        ),
                      );
                    }
                    return _NotificationList(
                      notifications: state.notifications,
                      scrollController: scrollController,
                      timeAgo: _timeAgo,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final ScrollController scrollController;
  final String Function(DateTime) timeAgo;

  const _NotificationList({
    required this.notifications,
    required this.scrollController,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      itemCount: notifications.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final n = notifications[i];
        return InkWell(
          onTap: n.isRead ? null : () => context.read<NotificationBloc>().add(MarkAsReadEvent(n.id)),
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
                        timeAgo(n.createdAt),
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
    );
  }
}
