import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_state.dart';

class AdminDepartmentsScreen extends StatefulWidget {
  final AdminBloc bloc;
  const AdminDepartmentsScreen({super.key, required this.bloc});

  @override
  State<AdminDepartmentsScreen> createState() => _AdminDepartmentsScreenState();
}

class _AdminDepartmentsScreenState extends State<AdminDepartmentsScreen> {
  final _searchCtl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.bloc.add(LoadDepartments());
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  List<AdminDeptModel>? _allDepts;
  int _page = 1;
  static const int _pageSize = 15;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is DepartmentsLoaded) _allDepts = state.departments;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manage Departments', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ThemeColors.unifiedTextPrimary)),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: () => widget.bloc.add(LoadDepartments())),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All departments in the organisation', style: TextStyle(fontSize: 14, color: ThemeColors.unifiedTextMuted)),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Department'),
                    onPressed: () => _showDeptDialog(context, null, _allDepts ?? []),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtl,
                decoration: InputDecoration(
                  hintText: 'Search by name or code...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtl.clear(); setState(() { _searchQuery = ''; _page = 1; }); })
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ThemeColors.unifiedBorder)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (v) => setState(() { _searchQuery = v.toLowerCase(); _page = 1; }),
              ),
              const SizedBox(height: 12),
              if (state is AdminLoading) const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (state is DepartmentsLoaded) _buildTable(context, state.departments)
              else if (state is AdminError) Expanded(child: Center(child: Text(state.message, style: const TextStyle(color: ThemeColors.unifiedDanger))))
              else const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(BuildContext context, List<AdminDeptModel> allDepts) {
    final filtered = allDepts.where((d) {
      if (_searchQuery.isEmpty) return true;
      return d.name.toLowerCase().contains(_searchQuery) ||
             d.code.toLowerCase().contains(_searchQuery);
    }).toList();
    final totalPages = filtered.isEmpty ? 1 : (filtered.length / _pageSize).ceil();
    final page = _page.clamp(1, totalPages);
    final displayed = filtered.skip((page - 1) * _pageSize).take(_pageSize).toList();

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
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(ThemeColors.unifiedBackground),
                    columns: const [
                      DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Tier', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Parent', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Shared', style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
                    ],
                  rows: displayed.map((d) => DataRow(cells: [
                    DataCell(Text('${d.id}')),
                    DataCell(Text(d.name)),
                    DataCell(Text(d.code)),
                    DataCell(Text(d.companyName ?? '-')),
                    DataCell(Text(d.tier ?? '-')),
                    DataCell(Text(d.parentName ?? '-')),
                    DataCell(d.isShared
                      ? const Icon(Icons.public, size: 18, color: ThemeColors.unifiedSuccess)
                      : const Icon(Icons.business, size: 18, color: ThemeColors.unifiedTextMuted)),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showDeptDialog(context, d, _allDepts ?? [])),
                        IconButton(icon: const Icon(Icons.delete, size: 18, color: ThemeColors.unifiedDanger),
                          onPressed: () => _confirmDelete(context, d)),
                      ],
                    )),
                  ])).toList(),
                ),
              ),
            ),
          ),
          if (filtered.length > _pageSize)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: page > 1 ? () => setState(() => _page--) : null),
                  Text('Page $page of $totalPages (${filtered.length} total)'),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: page < totalPages ? () => setState(() => _page++) : null),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminDeptModel d) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Department?'),
        content: Text('Delete "${d.name}" (${d.code})? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.unifiedDanger),
            onPressed: () {
              Navigator.pop(ctx);
              widget.bloc.add(DeleteDepartment(d.id, context));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeptDialog(BuildContext context, AdminDeptModel? existing, List<AdminDeptModel> allDepts) {
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final codeCtl = TextEditingController(text: existing?.code ?? '');
    int companyId = existing?.companyId ?? 0;
    String? tier = existing?.tier ?? 'upper';
    int? parentId = existing?.parentId;
    bool isShared = existing?.isShared ?? false;
    final formKey = GlobalKey<FormState>();

    // Filter out the department being edited and its children to avoid circular reference
    final filteredDepts = existing == null
        ? allDepts
        : allDepts.where((d) => d.id != existing.id).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(existing == null ? 'Add Department' : 'Edit Department'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: codeCtl, decoration: const InputDecoration(labelText: 'Code'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
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
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tier,
                    decoration: const InputDecoration(labelText: 'Tier'),
                    items: const [
                      DropdownMenuItem(value: 'upper', child: Text('Upper')),
                      DropdownMenuItem(value: 'lower', child: Text('Lower')),
                    ],
                    onChanged: (v) => setDlgState(() => tier = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    value: parentId,
                    decoration: const InputDecoration(labelText: 'Parent Department'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('None (top-level)')),
                      ...filteredDepts.map((d) => DropdownMenuItem<int?>(
                        value: d.id,
                        child: Text('${d.id} — ${d.name} (${d.code})'),
                      )),
                    ],
                    onChanged: (v) => setDlgState(() => parentId = v),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Shared Department'),
                    subtitle: const Text('Visible across all companies'),
                    value: isShared,
                    activeColor: ThemeColors.unifiedSuccess,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setDlgState(() => isShared = v),
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
                  'code': codeCtl.text,
                  'companyId': companyId,
                  'tier': tier,
                  'parentId': parentId,
                  'isShared': isShared,
                };
                Navigator.pop(ctx);
                if (existing == null) {
                  widget.bloc.add(CreateDepartment(body, context));
                } else {
                  widget.bloc.add(UpdateDepartment(existing.id, body, context));
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
