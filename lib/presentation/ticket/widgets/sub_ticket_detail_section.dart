import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class SubTicketDetailSection extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;

  const SubTicketDetailSection({
    super.key,
    required this.ticket,
    required this.user,
  });

  bool _canCompleteTicket(UserModel user, TicketModel t) {
    if (t.isClosed || t.isCompleted) return false;
    final isCreator = t.createdById == user.id;
    final isCeo = user.roleId == 0 || user.roleId == 3;
    if (!isCreator && !isCeo) return false;
    if (t.subDepartments.isEmpty) return false;
    return t.subDepartments.every((d) => d.isApproved || d.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
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
                        ConstStrings.subTicket,
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
                  ConstStrings.departmentBreakdown,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...ticket.subDepartments.map(
                  (dept) =>
                      _DeptProgressCard(ticket: ticket, dept: dept, user: user),
                ),
                // ── Creator "Complete Ticket" Button ────────────
                if (_canCompleteTicket(user, ticket))
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.read<TicketBloc>().add(
                          CompleteSubTicket(ticket.id),
                        ),
                        icon: const Icon(Icons.verified, size: 20),
                        label: const Text(ConstStrings.completeTicket),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  int? _selectedEmployeeId;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _isAssignedToMe =>
      widget.dept.assignedToId == widget.user.id && widget.dept.isAssigned;

  bool get _isMyDept => widget.user.departmentId == widget.dept.departmentId;

  bool get _isManager => widget.user.roleId == 1;
  bool get _isCeo => widget.user.roleId == 0 || widget.user.roleId == 3;
  bool get _isEmployee => widget.user.roleId == 2;
  bool get _isCreator => widget.ticket.createdById == widget.user.id;

  bool get _canEdit {
    if (widget.ticket.isClosed || widget.ticket.isCompleted) return false;
    if (_isCeo) return true;
    if (widget.dept.isCompleted || widget.dept.isApproved) return false;
    return _isMyDept ||
        _isAssignedToMe ||
        widget.user.departmentId == widget.ticket.assignedDeptId;
  }

  // in_progress -> pending_approval: only assigned employee
  bool get _canMarkDone =>
      _canEdit && widget.dept.isInProgress && _isAssignedToMe;

  // pending_approval -> approved: only this department's manager or CEO
  bool get _canApprove =>
      _canEdit &&
      widget.dept.isPendingApproval &&
      (_isManager || _isCeo) &&
      _isMyDept;

  // Creator can reopen an approved/completed department (48h, once)
  bool get _canCreatorReopen {
    if (!_isCreator && !_isCeo) return false;
    if (!widget.dept.isApproved && !widget.dept.isCompleted) return false;
    return true;
  }

  // Self-assign: employee in same dept, task is open and unassigned
  bool get _canSelfAssign =>
      _isEmployee && _isMyDept && widget.dept.isOpen && !widget.dept.isAssigned;

  // Manager assign: manager in same dept, task is open and unassigned
  bool get _canAssignEmployee =>
      _isManager && _isMyDept && widget.dept.isOpen && !widget.dept.isAssigned;

  void _markDone() {
    if (!_formKey.currentState!.validate()) return;
    context.read<TicketBloc>().add(
      UpdateSubDeptProgressEvent(
        ticketId: widget.ticket.id,
        departmentId: widget.dept.departmentId,
        status: 'pending_approval',
        note: _noteController.text.trim(),
      ),
    );
  }

  void _approveCompletion() {
    context.read<TicketBloc>().add(
      UpdateSubDeptProgressEvent(
        ticketId: widget.ticket.id,
        departmentId: widget.dept.departmentId,
        status: 'approved',
        note: 'Approved by ${widget.user.name}',
      ),
    );
  }

  void _selfAssign() {
    context.read<TicketBloc>().add(
      SelfAssignSubDept(widget.ticket.id, widget.dept.departmentId),
    );
  }

  void _reopenDept() {
    context.read<TicketBloc>().add(
      ReopenSubDept(
        ticketId: widget.ticket.id,
        departmentId: widget.dept.departmentId,
      ),
    );
  }

  void _assignEmployee() {
    if (_selectedEmployeeId == null) return;
    context.read<TicketBloc>().add(
      AssignSubDeptEmployeeEvent(
        ticketId: widget.ticket.id,
        departmentId: widget.dept.departmentId,
        employeeId: _selectedEmployeeId!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dept = widget.dept;
    final statusColor = dept.isCompleted
        ? const Color(0xFF16A34A)
        : dept.isApproved
        ? const Color(0xFF2563EB)
        : dept.isPendingApproval
        ? const Color(0xFFF59E0B)
        : dept.isInProgress
        ? const Color(0xFF7C3AED)
        : ThemeColors.unifiedTextMuted;

    final statusLabel = dept.isCompleted
        ? 'COMPLETED'
        : dept.isApproved
        ? 'APPROVED'
        : dept.isPendingApproval
        ? 'PENDING APPROVAL'
        : dept.isInProgress
        ? 'IN PROGRESS'
        : 'OPEN';

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
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
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
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
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
          // Assigned employee info
          if (dept.isAssigned && dept.assignedToName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Assigned to: ${dept.assignedToName}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
              ],
            ),
          ],
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
          if (_canAssignEmployee) ...[
            const SizedBox(height: 10),
            BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                final employees = state is DashboardLoaded
                    ? state.employees
                    : <EmployeeModel>[];
                if (employees.isEmpty) return const SizedBox.shrink();
                _selectedEmployeeId ??= dept.assignedToId ?? employees.first.id;
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedEmployeeId,
                        items: employees
                            .map(
                              (e) => DropdownMenuItem<int>(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedEmployeeId = v),
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: ConstStrings.assignToEmployee,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _assignEmployee,
                      child: const Text(ConstStrings.assign),
                    ),
                  ],
                );
              },
            ),
          ],
          // ── Self-Assign Button (employee, open, unassigned) ─────
          if (_canSelfAssign)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selfAssign,
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text(ConstStrings.selfAssignToTask),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.unifiedPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          // ── Mark as Done (in_progress + assigned employee) ──
          if (_canMarkDone) ...[
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: ConstStrings.completionRemarkHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: ThemeColors.unifiedInputBg,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? ConstStrings.completionRemarkRequired
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _markDone,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text(ConstStrings.markAsDone),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
          // ── Approve Button (pending_approval + manager/ceo) ────
          if (_canApprove)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _approveCompletion,
                  icon: const Icon(Icons.verified_outlined, size: 18),
                  label: const Text(ConstStrings.approveCompletion),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          // ── Info for pending_approval state (non-manager view) ──
          if (dept.isPendingApproval && !_canApprove)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 16,
                      color: Color(0xFF92400E),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ConstStrings.workSubmittedWaitingApproval,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // ── Info for approved state ────────────────────────────
          if (dept.isApproved)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Color(0xFF1E40AF),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isCreator || _isCeo
                            ? ConstStrings.managerApprovedYouCanComplete
                            : ConstStrings.managerApprovedWaitingFinalize,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // ── Creator Reopen Button (approved/completed) ─────────
          if (_canCreatorReopen)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _reopenDept,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text(ConstStrings.reopenThisDept),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
