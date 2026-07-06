import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_detail_appbar.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/sub_ticket_detail_section.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_detail_hero.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_detail_info.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;
  final UserModel user;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    required this.user,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TicketBloc>().add(LoadTicketDetail(widget.ticketId));
  }

  @override
  void dispose() {
    context.read<TicketBloc>().add(ClearTicketDetail());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 1000;

    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ThemeColors.unifiedPrimary,
            ),
          );
        } else if (state is TicketActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ThemeColors.unifiedDanger,
            ),
          );
        }
      },
      child: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          if (state is TicketDetailLoaded) {
            return _buildScaffold(state.ticket, isWide);
          }
          return const _LoadingScaffold();
        },
      ),
    );
  }

  Widget _buildScaffold(TicketModel ticket, bool isWide) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: CommonDetailAppbar(
        onHistoryPressed: null,
        ticket: ticket,
        title: null,
        issuffixStatus: true,
        userName: widget.user.name,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? MediaQuery.of(context).size.width * 0.1 : 16,
          vertical: 24,
        ),
        child: isWide
            ? _WideLayout(ticket: ticket, user: widget.user)
            : _NarrowLayout(ticket: ticket, user: widget.user),
      ),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        title: const Text(ConstStrings.loading),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: ThemeColors.unifiedBorder),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _WideLayout({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeroSection(ticket: ticket),
        const SizedBox(height: 24),
        if (ticket.isSubTicket || ticket.isMultiTaskTicket) ...[
          _ProgressSection(ticket: ticket),
          const SizedBox(height: 24),
        ],
        if (ticket.isSubTicket) ...[
          SubTicketDetailSection(ticket: ticket, user: user),
          const SizedBox(height: 24),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: LeftColumn(ticket: ticket, user: user),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: RightColumn(ticket: ticket, user: user),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _NarrowLayout({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeroSection(ticket: ticket),
        const SizedBox(height: 20),
        if (ticket.isSubTicket || ticket.isMultiTaskTicket) ...[
          _ProgressSection(ticket: ticket),
          const SizedBox(height: 20),
        ],
        if (ticket.isSubTicket) ...[
          SubTicketDetailSection(ticket: ticket, user: user),
          const SizedBox(height: 20),
        ],
        LeftColumn(ticket: ticket, user: user),
        const SizedBox(height: 20),
        RightColumn(ticket: ticket, user: user),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Progress Section ─────────────────────────────────────────────────────────
class _ProgressSection extends StatelessWidget {
  final TicketModel ticket;
  const _ProgressSection({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final progress = ticket.overallProgress;
    final deptColor = const Color(0xFF7C3AED);

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: deptColor.withOpacity(0.2), width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [deptColor, ThemeColors.unifiedSecondary],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: deptColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ticket.isMultiTaskTicket ? ConstStrings.multiTask : ConstStrings.subTicket,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: deptColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$progress% Complete',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: progress == 100
                            ? ThemeColors.unifiedSuccess
                            : deptColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${ticket.departmentCount} departments · '
                  '${ticket.completedDepartmentCount} completed',
                  style: const TextStyle(
                    fontSize: 13,
                    color: ThemeColors.unifiedTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 10,
                    backgroundColor: deptColor.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(
                      progress == 100 ? ThemeColors.unifiedSuccess : deptColor,
                    ),
                  ),
                ),
                if (ticket.subDepartments.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    ConstStrings.departmentBreakdown,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...ticket.subDepartments.map(
                    (dept) => _DeptMiniCard(dept: dept),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeptMiniCard extends StatelessWidget {
  final SubTicketDepartmentModel dept;
  const _DeptMiniCard({required this.dept});

  Color get _statusColor {
    if (dept.isCompleted) return ThemeColors.unifiedSuccess;
    if (dept.isApproved) return ThemeColors.unifiedSecondary;
    if (dept.isPendingApproval) return ThemeColors.unifiedWarning;
    if (dept.isInProgress) return const Color(0xFF7C3AED);
    return ThemeColors.unifiedTextMuted;
  }

  String get _statusLabel {
    if (dept.isCompleted) return 'DONE';
    if (dept.isApproved) return 'OK';
    if (dept.isPendingApproval) return 'REVIEW';
    if (dept.isInProgress) return 'ACTIVE';
    return 'OPEN';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  dept.departmentCode,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dept.departmentName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${dept.progressPercent}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: dept.progressPercent / 100,
              minHeight: 5,
              backgroundColor: const Color(0xFFEDE9FE),
              valueColor: AlwaysStoppedAnimation(_statusColor),
            ),
          ),
          if (dept.taskDescription.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              dept.taskDescription,
              style: const TextStyle(
                fontSize: 12,
                color: ThemeColors.unifiedTextMuted,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (dept.assignedToName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 12,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  dept.assignedToName!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
