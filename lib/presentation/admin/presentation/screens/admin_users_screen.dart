import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
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
  final TextEditingController _searchCtl = TextEditingController();
  final ScrollController _hScrollCtl = ScrollController();
  String _searchQuery = '';
  bool _showMissingCodeOnly = false;
  int _page = 0;
  static const int _pageSize = 30;
  List<AdminUserModel> _allUsers = [];

  @override
  void initState() {
    super.initState();
    widget.bloc.add(LoadUsers());
    widget.bloc.add(LoadPendingUsers());
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _hScrollCtl.dispose();
    super.dispose();
  }

  List<AdminUserModel> _filter(List<AdminUserModel> users) {
    var result = users;
    if (_showMissingCodeOnly) {
      result = result.where((u) => u.code == null || u.code!.isEmpty).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((u) =>
        u.name.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q) ||
        (u.code?.toLowerCase().contains(q) ?? false) ||
        (u.designation?.toLowerCase().contains(q) ?? false) ||
        (u.departmentName?.toLowerCase().contains(q) ?? false) ||
        (u.roleName?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    return result;
  }

  List<AdminUserModel> _pageOf(List<AdminUserModel> users) {
    final pages = (users.length / _pageSize).ceil();
    if (_page >= pages) _page = (pages - 1).clamp(0, pages);
    final start = _page * _pageSize;
    if (start >= users.length) return [];
    return users.sublist(start, (start + _pageSize).clamp(0, users.length));
  }

  Widget _pageNav(int total) {
    final pages = (total / _pageSize).ceil();
    if (pages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _page <= 0 ? null : () => setState(() => _page--),
          ),
          Text('Page ${_page + 1} of $pages ($total users)',
            style: AppTextStyles.bodySmallMuted),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _page >= pages - 1 ? null : () => setState(() => _page++),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is UsersLoaded) _allUsers = state.users;
        if (state is PendingUsersLoaded) _allUsers = state.users;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manage Users', style: AppTextStyles.pageTitle),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () { _page = 0; widget.bloc.add(LoadUsers()); widget.bloc.add(LoadPendingUsers()); },
                    tooltip: ConstStrings.refresh,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showMissingCodeOnly ? 'Showing users without employee code' : 'All registered users in the system',
                    style: TextStyle(fontSize: 14, color: _showMissingCodeOnly ? ThemeColors.unifiedWarning : ThemeColors.unifiedTextMuted),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(ConstStrings.addUser),
                    onPressed: () => _showUserDialog(context, null, _allUsers),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _tabButton('All Users', 0),
                  const SizedBox(width: 8),
                  _tabButton('Pending Approval', 1),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() { _showMissingCodeOnly = !_showMissingCodeOnly; _page = 0; }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _showMissingCodeOnly ? ThemeColors.unifiedWarning : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _showMissingCodeOnly ? ThemeColors.unifiedWarning : ThemeColors.unifiedBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_off, size: 16, color: _showMissingCodeOnly ? Colors.white : ThemeColors.unifiedWarning),
                          const SizedBox(width: 4),
                          Text('Missing Code', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _showMissingCodeOnly ? Colors.white : ThemeColors.unifiedWarning)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 320,
                    child: TextField(
                      controller: _searchCtl,
                      decoration: InputDecoration(
                        hintText: ConstStrings.searchByNameEmailCodeDept,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchCtl.clear();
                                  setState(() { _searchQuery = ''; _page = 0; });
                                },
                              )
                            : null,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) => setState(() { _searchQuery = v; _page = 0; }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state is AdminLoading) const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_selectedTab == 0 && state is UsersLoaded) _buildTable(context, _filter(state.users))
              else if (_selectedTab == 1 && state is PendingUsersLoaded) _buildPendingTable(context, _filter(state.users))
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
      onTap: () => setState(() { _selectedTab = index; _page = 0; }),
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
    final pageItems = _pageOf(users);
    return Expanded(
      child: Column(
        children: [
          Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.unifiedBorder),
        ),
        child: Scrollbar(
          controller: _hScrollCtl,
          thumbVisibility: true,
          child: SingleChildScrollView(
          controller: _hScrollCtl,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(ThemeColors.unifiedBackground),
              columns: const [
                 DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Designation', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Access', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Reports To', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Active', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
               ],
               rows: pageItems.map((u) => DataRow(cells: [
                 DataCell(Text('${u.id}')),
                 DataCell(
                   u.code != null && u.code!.isNotEmpty
                       ? Text(u.code!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
                       : Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(
                             color: ThemeColors.unifiedDanger.withOpacity(0.15),
                             borderRadius: BorderRadius.circular(4),
                             border: Border.all(color: ThemeColors.unifiedDanger.withOpacity(0.4)),
                           ),
                           child: const Text('EMPTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ThemeColors.unifiedDanger)),
                         ),
                 ),
                 DataCell(Text(u.name)),
                 DataCell(Text(u.designation ?? '-')),
                  DataCell(Text(u.email, style: AppTextStyles.bodyMedium)),
                  DataCell(_roleChip(u.roleName ?? 'N/A')),
                  DataCell(Text(u.departmentName ?? '-')),
                  DataCell(Text(u.companyName ?? '-')),
                  DataCell(u.seeAllCompanies
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedSecondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: ThemeColors.unifiedSecondary.withOpacity(0.4)),
                        ),
                        child: const Text('ALL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ThemeColors.unifiedSecondary)),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedTextMuted.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: ThemeColors.unifiedTextMuted.withOpacity(0.3)),
                        ),
                        child: const Text('OWN', style: AppTextStyles.label),
                      )),
                  DataCell(Text(u.reportsToName ?? '-')),
                  DataCell(Icon(u.isActive ? Icons.check_circle : Icons.cancel, color: u.isActive ? ThemeColors.unifiedSuccess : ThemeColors.unifiedDanger, size: 20)),
                  DataCell(Row(
                   children: [
                     IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showUserDialog(context, u, _allUsers), tooltip: ConstStrings.edit),
                     IconButton(
                       icon: Icon(Icons.lock_reset, size: 18, color: ThemeColors.unifiedWarning),
                       onPressed: () => _confirmResetPassword(context, u),
                       tooltip: 'Reset Password',
                     ),
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
       ),
     ),
     _pageNav(users.length),
     ],
     ),
     );
   }

   Widget _buildPendingTable(BuildContext context, List<AdminUserModel> users) {
    if (users.isEmpty) {
      return const Expanded(child: Center(child: Text('No pending approvals', style: TextStyle(color: ThemeColors.unifiedTextMuted))));
    }
    final pageItems = _pageOf(users);
    return Expanded(
      child: Column(
        children: [
          Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.unifiedBorder),
        ),
        child: Scrollbar(
          controller: _hScrollCtl,
          thumbVisibility: true,
          child: SingleChildScrollView(
          controller: _hScrollCtl,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(ThemeColors.unifiedBackground),
              columns: const [
                 DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Designation', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Access', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Reports To', style: TextStyle(fontWeight: FontWeight.w700))),
                 DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
               ],
               rows: pageItems.map((u) => DataRow(cells: [
                 DataCell(Text('${u.id}')),
                 DataCell(
                   u.code != null && u.code!.isNotEmpty
                       ? Text(u.code!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
                       : Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(
                             color: ThemeColors.unifiedDanger.withOpacity(0.15),
                             borderRadius: BorderRadius.circular(4),
                             border: Border.all(color: ThemeColors.unifiedDanger.withOpacity(0.4)),
                           ),
                           child: const Text('EMPTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ThemeColors.unifiedDanger)),
                         ),
                 ),
                 DataCell(Text(u.name)),
                 DataCell(Text(u.designation ?? '-')),
                  DataCell(Text(u.email, style: AppTextStyles.bodyMedium)),
                  DataCell(_roleChip(u.roleName ?? 'N/A')),
                  DataCell(Text(u.departmentName ?? '-')),
                  DataCell(Text(u.companyName ?? '-')),
                  DataCell(u.seeAllCompanies
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedSecondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: ThemeColors.unifiedSecondary.withOpacity(0.4)),
                        ),
                        child: const Text('ALL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ThemeColors.unifiedSecondary)),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedTextMuted.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: ThemeColors.unifiedTextMuted.withOpacity(0.3)),
                        ),
                        child: const Text('OWN', style: AppTextStyles.label),
                      )),
                  DataCell(Text(u.reportsToName ?? '-')),
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
      ),
    ),
    _pageNav(users.length),
    ],
    ),
    );
  }

  void _confirmApprove(BuildContext context, AdminUserModel u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ConstStrings.approveUser),
        content: Text('Approve "${u.name}" (${u.email})? They will be able to log in immediately.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(ConstStrings.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.bloc.add(ApproveUser(u.id, context));
            },
            child: const Text(ConstStrings.approve),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(ConstStrings.cancel)),
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

  void _confirmResetPassword(BuildContext context, AdminUserModel u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ConstStrings.resetPasswordTitle),
        content: Text('Reset password for "${u.name}" (${u.email}) to UM@2024? They will be forced to change it on next login.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(ConstStrings.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.bloc.add(UpdateUser(u.id, {'password': 'UM@2024', 'mustResetPassword': true}, context));
            },
            child: const Text(ConstStrings.reset),
          ),
        ],
      ),
    );
  }

  void _showUserDialog(BuildContext context, AdminUserModel? existing, List<AdminUserModel> allUsers) {
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final emailCtl = TextEditingController(text: existing?.email ?? '');
    final codeCtl = TextEditingController(text: existing?.code ?? '');
    final designationCtl = TextEditingController(text: existing?.designation ?? '');
    final passwordCtl = TextEditingController();
    int? roleId = existing?.roleId ?? 2;
    int? deptId = existing?.departmentId;
    int companyId = existing?.companyId ?? 0;
    int? reportsTo = existing?.reportsTo;
    bool seeAllCompanies = existing?.seeAllCompanies ?? false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(existing == null ? ConstStrings.addUser : 'Edit User'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: nameCtl, decoration: const InputDecoration(labelText: ConstStrings.nameLabel), validator: (v) => v == null || v.isEmpty ? ConstStrings.required_ : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: emailCtl, decoration: const InputDecoration(labelText: ConstStrings.emailLabel), validator: (v) => v == null || v.isEmpty ? ConstStrings.required_ : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: codeCtl, decoration: const InputDecoration(labelText: ConstStrings.employeeCodeLabel), validator: (v) => v == null || v.isEmpty ? ConstStrings.required_ : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: designationCtl, decoration: const InputDecoration(labelText: ConstStrings.designationLabel)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordCtl,
                    decoration: InputDecoration(
                      labelText: existing == null ? ConstStrings.password : ConstStrings.newPasswordLabel,
                    ),
                    obscureText: true,
                    validator: existing == null
                        ? (v) => v == null || v.isEmpty ? ConstStrings.required_ : null
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: roleId,
                    decoration: const InputDecoration(labelText: ConstStrings.roleLabel),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text(ConstStrings.roleDeveloper)),
                      DropdownMenuItem(value: 0, child: Text(ConstStrings.roleCeo)),
                      DropdownMenuItem(value: 1, child: Text(ConstStrings.roleManager)),
                      DropdownMenuItem(value: 2, child: Text(ConstStrings.roleEmployee)),
                    ],
                    onChanged: (v) => setDlgState(() => roleId = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: ConstStrings.departmentIdLabel),
                    initialValue: deptId?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => deptId = v.isEmpty ? null : int.tryParse(v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: companyId,
                    decoration: const InputDecoration(labelText: ConstStrings.companyLabel),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text(ConstStrings.umEnterprises)),
                      DropdownMenuItem(value: 1, child: Text(ConstStrings.matrixPharma)),
                    ],
                    onChanged: (v) => setDlgState(() => companyId = v!),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      final searchCtl = TextEditingController();
                      showDialog(
                        context: ctx,
                        builder: (sctx) => StatefulBuilder(
                          builder: (sctx, setSearchState) {
                            final filtered = searchCtl.text.isEmpty
                                ? allUsers.where((u) => u.id != (existing?.id ?? -1)).toList()
                                : allUsers.where((u) =>
                                    u.id != (existing?.id ?? -1) &&
                                    ('${u.name} ${u.email}'.toLowerCase().contains(searchCtl.text.toLowerCase())))
                                    .toList();
                            return AlertDialog(
                              title: const Text(ConstStrings.selectReportsTo),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: searchCtl,
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        hintText: ConstStrings.searchByNameOrEmail,
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                      onChanged: (_) => setSearchState(() {}),
                                    ),
                                    const SizedBox(height: 12),
                                    Flexible(
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          ListTile(
                                            dense: true,
                                            title: const Text('None'),
                                            selected: reportsTo == null,
                                            onTap: () {
                                              Navigator.pop(sctx);
                                              setDlgState(() => reportsTo = null);
                                            },
                                          ),
                                          ...filtered.map((u) => ListTile(
                                            dense: true,
                                            title: Text('${u.name} (${u.email})'),
                                            selected: u.id == reportsTo,
                                            onTap: () {
                                              Navigator.pop(sctx);
                                              setDlgState(() => reportsTo = u.id);
                                            },
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: ConstStrings.reportsToLabel,
                        suffixIcon: Icon(Icons.search),
                      ),
                      child: Text(
                        () {
                          if (reportsTo == null) return 'Tap to search...';
                          final u = allUsers.cast<AdminUserModel?>().firstWhere((u) => u?.id == reportsTo, orElse: () => null);
                          return u != null ? '${u.name} (${u.email})' : 'User #$reportsTo';
                        }(),
                        style: TextStyle(
                          fontSize: 14,
                          color: reportsTo != null ? ThemeColors.unifiedTextPrimary : ThemeColors.unifiedTextMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: seeAllCompanies,
                    onChanged: (v) => setDlgState(() => seeAllCompanies = v ?? false),
                    title: const Text('See All Companies', style: AppTextStyles.body),
                    subtitle: const Text('Bypasses company-level ticket isolation', style: AppTextStyles.label),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(ConstStrings.cancel)),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final body = <String, dynamic>{
                  'name': nameCtl.text,
                  'email': emailCtl.text,
                  'code': codeCtl.text,
                  'designation': designationCtl.text,
                  'roleId': roleId,
                  'departmentId': deptId,
                  'companyId': companyId,
                };
                body['reportsTo'] = reportsTo;
                body['seeAllCompanies'] = seeAllCompanies;
                if (passwordCtl.text.isNotEmpty) body['password'] = passwordCtl.text;
                Navigator.pop(ctx);
                if (existing == null) {
                  widget.bloc.add(CreateUser(body, context));
                } else {
                  widget.bloc.add(UpdateUser(existing.id, body, context));
                }
              },
              child: Text(existing == null ? ConstStrings.create : ConstStrings.save),
            ),
          ],
        ),
      ),
    );
  }
}
