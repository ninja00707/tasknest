import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/presentation/projects/widgets/UIhelpers.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

InputDecoration _searchDecoration() => InputDecoration(
  hintText: 'Search...',
  prefixIcon: const Icon(
    Icons.search_rounded,
    size: 20,
    color: ThemeColors.unifiedTextMuted,
  ),
  isDense: true,
  filled: true,
  fillColor: ThemeColors.unifiedInputBg,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: ThemeColors.unifiedPrimary, width: 1.5),
  ),
);

Widget _sheetHandle() => Center(
  child: Container(
    margin: const EdgeInsets.only(top: 10, bottom: 4),
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: ThemeColors.unifiedBorder,
      borderRadius: BorderRadius.circular(4),
    ),
  ),
);

BoxDecoration _sheetDecoration() => const BoxDecoration(
  color: ThemeColors.unifiedSurface,
  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
);

ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
  backgroundColor: ThemeColors.unifiedPrimary,
  foregroundColor: Colors.white,
  disabledBackgroundColor: ThemeColors.unifiedInputBg,
  disabledForegroundColor: ThemeColors.unifiedTextMuted,
  padding: const EdgeInsets.symmetric(vertical: 15),
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
);

class AddPeopleSheet extends StatefulWidget {
  final String title;
  final Set<int> existingIds;
  const AddPeopleSheet({
    super.key,
    required this.title,
    required this.existingIds,
  });

  @override
  State<AddPeopleSheet> createState() => _AddPeopleSheetState();
}

class _AddPeopleSheetState extends State<AddPeopleSheet> {
  final _searchCtrl = TextEditingController();
  final Set<int> _selected = {};
  List<EmployeeModel> _employees = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final employees = await GetIt.instance
          .get<TicketRepositoryImpl>()
          .getEmployees();
      if (!mounted) return;
      setState(() {
        _employees = employees;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<EmployeeModel> get _available => _employees
      .where((e) => e.isActive && !widget.existingIds.contains(e.id))
      .toList();

  List<EmployeeModel> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _available;
    return _available
        .where(
          (e) =>
              e.name.toLowerCase().contains(q) ||
              e.deptName.toLowerCase().contains(q),
        )
        .toList();
  }

  void _submit() {
    Navigator.of(context).pop(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: _sheetDecoration(),
        child: Column(
          children: [
            _sheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.unifiedTextPrimary,
                      ),
                    ),
                  ),
                  if (_selected.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedPrimary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selected.length} selected',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedPrimary,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                decoration: _searchDecoration(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: _primaryButtonStyle(),
                  onPressed: _selected.isEmpty ? null : _submit,
                  child: Text(
                    _selected.isEmpty
                        ? 'Select people to add'
                        : 'Add ${_selected.length}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: ThemeColors.unifiedDanger),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final list = _filtered;
    if (list.isEmpty) {
      return const FriendlyEmptyState(
        icon: Icons.person_off_rounded,
        message: 'No people available',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final e = list[i];
        final selected = _selected.contains(e.id);
        return ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: InitialsAvatar(name: e.name, size: 32),
          title: Text(
            e.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
          subtitle: Text(
            e.deptName,
            style: const TextStyle(
              fontSize: 11.5,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
          trailing: Icon(
            selected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: selected
                ? ThemeColors.unifiedPrimary
                : ThemeColors.unifiedTextMuted,
          ),
          onTap: () {
            setState(() {
              if (selected) {
                _selected.remove(e.id);
              } else {
                _selected.add(e.id);
              }
            });
          },
        );
      },
    );
  }
}

class AddDepartmentsSheet extends StatefulWidget {
  final String title;
  final Set<int> existingIds;
  const AddDepartmentsSheet({
    super.key,
    required this.title,
    required this.existingIds,
  });

  @override
  State<AddDepartmentsSheet> createState() => _AddDepartmentsSheetState();
}

class _AddDepartmentsSheetState extends State<AddDepartmentsSheet> {
  final _searchCtrl = TextEditingController();
  final Set<int> _selected = {};
  List<DepartmentModel> _departments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final depts = await GetIt.instance
          .get<TicketRepositoryImpl>()
          .getDepartments();
      if (!mounted) return;
      setState(() {
        _departments = depts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<DepartmentModel> get _available =>
      _departments.where((d) => !widget.existingIds.contains(d.id)).toList();

  List<DepartmentModel> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _available;
    return _available
        .where(
          (d) =>
              d.name.toLowerCase().contains(q) ||
              d.code.toLowerCase().contains(q),
        )
        .toList();
  }

  void _submit() {
    Navigator.of(context).pop(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: _sheetDecoration(),
        child: Column(
          children: [
            _sheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.unifiedTextPrimary,
                      ),
                    ),
                  ),
                  if (_selected.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedPrimary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selected.length} selected',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedPrimary,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                decoration: _searchDecoration(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: _primaryButtonStyle(),
                  onPressed: _selected.isEmpty ? null : _submit,
                  child: Text(
                    _selected.isEmpty
                        ? 'Select departments to add'
                        : 'Add ${_selected.length}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: ThemeColors.unifiedDanger),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final list = _filtered;
    if (list.isEmpty) {
      return const FriendlyEmptyState(
        icon: Icons.apartment_rounded,
        message: 'No departments available',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final d = list[i];
        final selected = _selected.contains(d.id);
        return ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ThemeColors.unifiedPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              size: 16,
              color: ThemeColors.unifiedPrimary,
            ),
          ),
          title: Text(
            d.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
          subtitle: Text(
            d.code,
            style: const TextStyle(
              fontSize: 11.5,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
          trailing: Icon(
            selected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: selected
                ? ThemeColors.unifiedPrimary
                : ThemeColors.unifiedTextMuted,
          ),
          onTap: () {
            setState(() {
              if (selected) {
                _selected.remove(d.id);
              } else {
                _selected.add(d.id);
              }
            });
          },
        );
      },
    );
  }
}
