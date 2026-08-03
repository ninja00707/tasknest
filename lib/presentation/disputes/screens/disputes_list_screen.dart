import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/data/repositories/ticket/ticket_realtime_repository.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/injection.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_bloc.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_event.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_state.dart';
import 'package:tasknest/presentation/disputes/models/dispute_model.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';

class DisputesContent extends StatefulWidget {
  final UserModel user;
  const DisputesContent({super.key, required this.user});

  @override
  State<DisputesContent> createState() => _DisputesContentState();
}

class _DisputesContentState extends State<DisputesContent> {
  late final DisputeBloc _bloc;
  StreamSubscription<dynamic>? _disputeSub;

  @override
  void initState() {
    super.initState();
    _bloc = DisputeBloc(sl<TicketRepositoryImpl>());
    _bloc.add(LoadDisputes());
    _disputeSub = TicketRealtimeRepository()
        .disputeEvents
        .listen((_) {
          if (mounted) _bloc.add(LoadDisputes());
        });
  }

  @override
  void dispose() {
    _disputeSub?.cancel();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DisputeBloc>.value(
      value: _bloc,
      child: BlocListener<DisputeBloc, DisputeState>(
        listenWhen: (prev, curr) => curr is DisputeActionError,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((state as DisputeActionError).message),
              backgroundColor: ThemeColors.unifiedDanger,
            ),
          );
        },
        child: BlocBuilder<DisputeBloc, DisputeState>(
          builder: (context, state) {
            if (state is DisputeLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ThemeColors.unifiedPrimary,
                ),
              );
            }
            if (state is DisputeActionError) {
              return _DisputesError(
                onRetry: () => _bloc.add(LoadDisputes()),
              );
            }
            final disputes = state is DisputeListLoaded
                ? state.disputes
                : <DisputeModel>[];
            return Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DisputesHeader(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: disputes.isEmpty
                        ? const _DisputesEmpty()
                        : RefreshIndicator(
                            onRefresh: () async =>
                                _bloc.add(LoadDisputes()),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 4),
                              itemCount: disputes.length,
                              itemBuilder: (context, index) =>
                                  _DisputeCard(dispute: disputes[index]),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DisputesHeader extends StatelessWidget {
  const _DisputesHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.gavel_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              ConstStrings.navDisputes,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Disputes raised across your tickets',
              style: AppTextStyles.bodySmallMuted,
            ),
          ],
        ),
      ],
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final DisputeModel dispute;
  const _DisputeCard({required this.dispute});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => context.push('/ticket/${dispute.ticketId}'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeColors.unifiedSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeColors.unifiedBorder.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    dispute.ticketNumber.isNotEmpty
                        ? dispute.ticketNumber
                        : '#${dispute.ticketId}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(dispute.status).$1,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dispute.statusLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: _statusColor(dispute.status).$2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(dispute.createdAt),
                    style: AppTextStyles.micro,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dispute.ticketTitle.isNotEmpty
                    ? dispute.ticketTitle
                    : 'Ticket #${dispute.ticketId}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                dispute.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.unifiedTextMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedBackground,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ThemeColors.unifiedBorder),
                    ),
                    child: Text(
                      dispute.reasonLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ThemeColors.unifiedAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 13,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dispute.raisedByName,
                    style: AppTextStyles.micro,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color) _statusColor(String status) {
    switch (status) {
      case 'open':
        return (ThemeColors.statusOpenBg, ThemeColors.statusOpenFg);
      case 'under_review':
        return (ThemeColors.statusProgressBg, ThemeColors.statusProgressFg);
      case 'resolved':
        return (ThemeColors.statusDoneBg, ThemeColors.statusDoneFg);
      case 'rejected':
        return (ThemeColors.priorityUrgentBg, ThemeColors.priorityUrgentFg);
      case 'escalated':
        return (ThemeColors.priorityHighBg, ThemeColors.priorityHighFg);
      case 'disputed':
        return (ThemeColors.priorityUrgentBg, ThemeColors.priorityUrgentFg);
      default:
        return (ThemeColors.statusClosedBg, ThemeColors.statusClosedFg);
    }
  }

  static String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _DisputesEmpty extends StatelessWidget {
  const _DisputesEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.gavel_rounded,
            size: 64,
            color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          const Text(
            ConstStrings.noDisputes,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            ConstStrings.disputesWillAppear,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _DisputesError extends StatelessWidget {
  final VoidCallback onRetry;
  const _DisputesError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: ThemeColors.unifiedDanger,
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
