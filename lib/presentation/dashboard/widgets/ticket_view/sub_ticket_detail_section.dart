import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class SubTicketDetailSection extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;

  const SubTicketDetailSection({
    super.key,
    required this.ticket,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
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
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SUB TICKET',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7C3AED),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${ticket.overallProgress}% Complete',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7C3AED),
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
                    value: ticket.overallProgress / 100,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFEDE9FE),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Department Breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...ticket.subDepartments.map(
                  (dept) => _DeptProgressCard(
                    ticket: ticket,
                    dept: dept,
                    user: user,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeptProgressCard extends StatefulWidget {
  final TicketModel ticket;
  final SubTicketDepartmentModel dept;
  final UserModel user;

  const _DeptProgressCard({
    required this.ticket,
    required this.dept,
    required this.user,
  });

  @override
  State<_DeptProgressCard> createState() => _DeptProgressCardState();
}

class _DeptProgressCardState extends State<_DeptProgressCard> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.dept.progressPercent.toDouble();
  }

  bool get _canEdit {
    if (widget.ticket.isClosed || widget.ticket.isCompleted) return false;
    if (widget.user.roleId == 0) return true;
    return widget.user.departmentId == widget.dept.departmentId ||
        widget.user.departmentId == widget.ticket.assignedDeptId;
  }

  void _updateProgress(int percent) {
    context.read<DashboardBloc>().add(
      UpdateSubDeptProgressEvent(
        ticketId: widget.ticket.id,
        departmentId: widget.dept.departmentId,
        progressPercent: percent,
        status: percent >= 100
            ? 'completed'
            : percent > 0
            ? 'in_progress'
            : 'open',
      ),
    );
  }

  void _markComplete() {
    context.read<DashboardBloc>().add(
      UpdateSubDeptProgressEvent(
        ticketId: widget.ticket.id,
        departmentId: widget.dept.departmentId,
        progressPercent: 100,
        status: 'completed',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dept = widget.dept;
    final statusColor = dept.isCompleted
        ? const Color(0xFF16A34A)
        : dept.isInProgress
        ? const Color(0xFF7C3AED)
        : ThemeColors.unifiedTextMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dept.departmentCode,
                  style: const TextStyle(
                    fontSize: 11,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dept.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dept.taskDescription,
            style: const TextStyle(
              fontSize: 13,
              color: ThemeColors.unifiedTextMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: dept.progressPercent / 100,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFEDE9FE),
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${dept.progressPercent}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (_canEdit && !dept.isCompleted) ...[
            const SizedBox(height: 10),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: const Color(0xFF7C3AED),
              inactiveColor: const Color(0xFFEDE9FE),
              label: '${_sliderValue.round()}%',
              onChanged: (v) => setState(() => _sliderValue = v),
              onChangeEnd: (v) => _updateProgress(v.round()),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _markComplete,
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Mark Complete'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF16A34A),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
