import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_state.dart';

class AdminUsersScreen extends StatefulWidget {
  final AdminBloc bloc;
  const AdminUsersScreen({super.key, required this.bloc});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    widget.bloc.add(LoadUsers());
    widget.bloc.add(LoadPendingUsers());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manage Users', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ThemeColors.unifiedTextPrimary)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () { widget.bloc.add(LoadUsers()); widget.bloc.add(LoadPendingUsers()); },
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All registered users in the system', style: TextStyle(fontSize: 14, color: ThemeColors.unifiedTextMuted)),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add User'),
                    onPressed: () => _showUserDialog(context, null),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _tabButton('All Users', 0),
                  const SizedBox(width: 8),
                  _tabButton('Pending Approval', 1),
                ],
              ),
              const SizedBox(height: 12),
              if (state is AdminLoading) const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_selectedTab == 0 && state is UsersLoaded) _buildTable(context, state.users)
              else if (_selectedTab == 1 && state is PendingUsersLoaded) _buildPendingTable(context, state.users)
              else if (state is AdminError) Expanded(child: Center(child: Text(state.message, style: const TextStyle(color: ThemeColors.unifiedDanger))))
              else const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _tabButton(String label, int index) {
    final active = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? ThemeColors.unifiedSecondary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? ThemeColors.unifiedSecondary : ThemeColors.unifiedBorder),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: active ? Colors.white : ThemeColors.unifiedTextPrimary)),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<AdminUserModel> users) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.unifiedBorder),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(ThemeColors.unifiedBackground),
              columns: const [
                DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Active', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
              ],
              rows: users.map((u) => DataRow(cells: [
                DataCell(Text('${u.id}')),
                DataCell(Text(u.name)),
                DataCell(Text(u.email, style: const TextStyle(fontSize: 13))),
                DataCell(_roleChip(u.roleName ?? 'N/A')),
                DataCell(Text(u.departmentName ?? '-')),
                DataCell(Text(u.companyName ?? '-')),
                DataCell(Icon(u.isActive ? Icons.check_circle : Icons.cancel, color: u.isActive ? ThemeColors.unifiedSuccess : ThemeColors.unifiedDanger, size: 20)),
                DataCell(Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showUserDialog(context, u), tooltip: 'Edit'),
                    IconButton(
                      icon: Icon(Icons.toggle_off, size: 18, color: u.isActive ? ThemeColors.unifiedWarning : ThemeColors.unifiedSuccess),
                      onPressed: () => _confirmToggle(context, u),
                      tooltip: u.isActive ? 'Deactivate' : 'Activate',
                    ),
                  ],
                )),
              ])).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingTable(BuildContext context, List<AdminUserModel> users) {
    if (users.isEmpty) {
      return const Expanded(child: Center(child: Text('No pending approvals', style: TextStyle(color: ThemeColors.unifiedTextMuted))));
    }
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.unifiedBorder),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(ThemeColors.unifiedBackground),
              columns: const [
                DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
              ],
              rows: users.map((u) => DataRow(cells: [
                DataCell(Text('${u.id}')),
                DataCell(Text(u.name)),
                DataCell(Text(u.email, style: const TextStyle(fontSize: 13))),
                DataCell(_roleChip(u.roleName ?? 'N/A')),
                DataCell(Text(u.departmentName ?? '-')),
                DataCell(Text(u.companyName ?? '-')),
                DataCell(Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.unifiedSuccess,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _confirmApprove(context, u),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: ThemeColors.unifiedDanger),
                      onPressed: () => _confirmToggle(context, u),
                      tooltip: 'Deactivate',
                    ),
                  ],
                )),
              ])).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmApprove(BuildContext context, AdminUserModel u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve User?'),
        content: Text('Approve "${u.name}" (${u.email})? They will be able to log in immediately.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.bloc.add(ApproveUser(u.id, context));
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Widget _roleChip(String role) {
    Color c;
    switch (role.toLowerCase()) {
      case 'ceo': c = Colors.purple; break;
      case 'manager': c = ThemeColors.unifiedSecondary; break;
      default: c = ThemeColors.unifiedTextMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(role, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w600)),
    );
  }

  void _confirmToggle(BuildContext context, AdminUserModel u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(u.isActive ? 'Deactivate User?' : 'Activate User?'),
        content: Text('${u.isActive ? "Deactivate" : "Activate"} "${u.name}" (${u.email})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.bloc.add(UpdateUser(u.id, {'isActive': !u.isActive}, context));
            },
            child: Text(u.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _showUserDialog(BuildContext context, AdminUserModel? existing) {
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final emailCtl = TextEditingController(text: existing?.email ?? '');
    final passwordCtl = TextEditingController();
    int? roleId = existing?.roleId ?? 2;
    int? deptId = existing?.departmentId;
    int companyId = existing?.companyId ?? 0;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(existing == null ? 'Add User' : 'Edit User'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: emailCtl, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  if (existing == null)
                    TextFormField(controller: passwordCtl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: roleId,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('CEO')),
                      DropdownMenuItem(value: 1, child: Text('Manager')),
                      DropdownMenuItem(value: 2, child: Text('Employee')),
                    ],
                    onChanged: (v) => setDlgState(() => roleId = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Department ID'),
                    initialValue: deptId?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => deptId = v.isEmpty ? null : int.tryParse(v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: companyId,
                    decoration: const InputDecoration(labelText: 'Company'),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('UM Enterprises')),
                      DropdownMenuItem(value: 1, child: Text('Matrix Pharma')),
                    ],
                    onChanged: (v) => setDlgState(() => companyId = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final body = <String, dynamic>{
                  'name': nameCtl.text,
                  'email': emailCtl.text,
                  'roleId': roleId,
                  'departmentId': deptId,
                  'companyId': companyId,
                };
                if (passwordCtl.text.isNotEmpty) body['password'] = passwordCtl.text;
                Navigator.pop(ctx);
                if (existing == null) {
                  widget.bloc.add(CreateUser(body, context));
                } else {
                  widget.bloc.add(UpdateUser(existing.id, body, context));
                }
              },
              child: Text(existing == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
