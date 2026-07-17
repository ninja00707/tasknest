import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_state.dart';

class AdminDepartmentsScreen extends StatelessWidget {
  final AdminBloc bloc;
  const AdminDepartmentsScreen({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    bloc.add(LoadDepartments());
    final searchCtl = TextEditingController(
      text: bloc.state is DepartmentsLoaded
          ? (bloc.state as DepartmentsLoaded).searchQuery
          : '',
    );

    return BlocBuilder<AdminBloc, AdminState>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manage Departments',
                      style: AppTextStyles.pageTitle),
                  IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => bloc.add(LoadDepartments())),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('All departments in the organisation',
                      style: AppTextStyles.bodyMuted),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(ConstStrings.addDepartment),
                    onPressed: () => _showDeptDialog(
                        context,
                        null,
                        state is DepartmentsLoaded
                            ? state.departments
                            : []),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchCtl,
                decoration: InputDecoration(
                  hintText: ConstStrings.searchByNameOrCode,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: (state is DepartmentsLoaded &&
                          state.searchQuery.isNotEmpty)
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchCtl.clear();
                            bloc.add(UpdateDeptSearchQuery(''));
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: ThemeColors.unifiedBorder)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
                onChanged: (v) =>
                    bloc.add(UpdateDeptSearchQuery(v.toLowerCase())),
              ),
              const SizedBox(height: 12),
              if (state is AdminLoading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (state is DepartmentsLoaded)
                _buildTable(context, state)
              else if (state is AdminError)
                Expanded(
                    child: Center(
                        child: Text(state.message,
                            style: const TextStyle(
                                color: ThemeColors.unifiedDanger))))
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(BuildContext context, DepartmentsLoaded deptState) {
    final displayed = deptState.displayed;
    final page = deptState.clampedPage;
    final totalPages = deptState.totalPages;
    final filtered = deptState.filtered;
    final allDepts = deptState.departments;

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
                  headingRowColor:
                      WidgetStateProperty.all(ThemeColors.unifiedBackground),
                  columns: const [
                    DataColumn(
                        label: Text('ID',
                            style:
                                TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(
                        label: Text('Name',
                            style:
                                TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(
                        label: Text('Code',
                            style:
                                TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(
                        label: Text('Company',
                            style:
                                TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(
                        label: Text('Tier',
                            style:
                                TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(
                        label: Text('Parent',
                            style:
                                TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(
                        label: Text('Shared',
                            style:
                                TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(
                        label: Text('Actions',
                            style:
                                TextStyle(fontWeight: FontWeight.w700))),
                  ],
                  rows: displayed
                      .map((d) => DataRow(cells: [
                            DataCell(Text('${d.id}')),
                            DataCell(Text(d.name)),
                            DataCell(Text(d.code)),
                            DataCell(Text(d.companyName ?? '-')),
                            DataCell(Text(d.tier ?? '-')),
                            DataCell(Text(d.parentName ?? '-')),
                            DataCell(d.isShared
                                ? const Icon(Icons.public,
                                    size: 18,
                                    color: ThemeColors.unifiedSuccess)
                                : const Icon(Icons.business,
                                    size: 18,
                                    color:
                                        ThemeColors.unifiedTextMuted)),
                            DataCell(Row(
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 18),
                                    onPressed: () =>
                                        _showDeptDialog(
                                            context, d, allDepts)),
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 18,
                                        color: ThemeColors
                                            .unifiedDanger),
                                    onPressed: () =>
                                        _confirmDelete(
                                            context, d)),
                              ],
                            )),
                          ]))
                      .toList(),
                ),
              ),
            ),
          ),
          if (filtered.length > DepartmentsLoaded.pageSize)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: page > 1
                          ? () => bloc
                              .add(UpdateDeptPage(page - 1))
                          : null),
                  Text(
                      'Page $page of $totalPages (${filtered.length} total)'),
                  IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: page < totalPages
                          ? () => bloc
                              .add(UpdateDeptPage(page + 1))
                          : null),
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
        title: const Text(ConstStrings.deleteDepartment),
        content:
            Text('Delete "${d.name}" (${d.code})? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.unifiedDanger),
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(DeleteDepartment(d.id, context));
            },
            child: const Text(ConstStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showDeptDialog(
      BuildContext context, AdminDeptModel? existing, List<AdminDeptModel> allDepts) {
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final codeCtl = TextEditingController(text: existing?.code ?? '');
    int companyId = existing?.companyId ?? 0;
    String? tier = existing?.tier ?? 'upper';
    int? parentId = existing?.parentId;
    bool isShared = existing?.isShared ?? false;
    final formKey = GlobalKey<FormState>();

    final filteredDepts = existing == null
        ? allDepts
        : allDepts.where((d) => d.id != existing.id).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(
              existing == null ? ConstStrings.addDepartment : 'Edit Department'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                      controller: nameCtl,
                      decoration: const InputDecoration(
                          labelText: ConstStrings.nameLabel),
                      validator: (v) => v == null || v.isEmpty
                          ? ConstStrings.required_
                          : null),
                  const SizedBox(height: 12),
                  TextFormField(
                      controller: codeCtl,
                      decoration: const InputDecoration(
                          labelText: ConstStrings.codeLabel),
                      validator: (v) => v == null || v.isEmpty
                          ? ConstStrings.required_
                          : null),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: companyId,
                    decoration: const InputDecoration(
                        labelText: ConstStrings.companyLabel),
                    items: const [
                      DropdownMenuItem(
                          value: 0,
                          child: Text(ConstStrings.umEnterprises)),
                      DropdownMenuItem(
                          value: 1,
                          child: Text(ConstStrings.matrixPharma)),
                    ],
                    onChanged: (v) =>
                        setDlgState(() => companyId = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: tier,
                    decoration: const InputDecoration(
                        labelText: ConstStrings.tierLabel),
                    items: const [
                      DropdownMenuItem(
                          value: 'upper',
                          child: Text(ConstStrings.upper)),
                      DropdownMenuItem(
                          value: 'lower',
                          child: Text(ConstStrings.lower)),
                    ],
                    onChanged: (v) => setDlgState(() => tier = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: parentId,
                    decoration: const InputDecoration(
                        labelText: ConstStrings.parentDepartment),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(ConstStrings.noneTopLevel)),
                      ...filteredDepts.map((d) => DropdownMenuItem<int?>(
                            value: d.id,
                            child: Text(
                                '${d.id} — ${d.name} (${d.code})'),
                          )),
                    ],
                    onChanged: (v) =>
                        setDlgState(() => parentId = v),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title:
                        const Text(ConstStrings.sharedDepartment),
                    subtitle: const Text(
                        ConstStrings.visibleAcrossCompanies),
                    value: isShared,
                    activeThumbColor: ThemeColors.unifiedSuccess,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) =>
                        setDlgState(() => isShared = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(ConstStrings.cancel)),
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
                  bloc.add(CreateDepartment(body, context));
                } else {
                  bloc.add(
                      UpdateDepartment(existing.id, body, context));
                }
              },
              child: Text(existing == null
                  ? ConstStrings.create
                  : ConstStrings.save),
            ),
          ],
        ),
      ),
    );
  }
}
