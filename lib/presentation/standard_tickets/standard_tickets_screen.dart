import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/data/datasource/ticketdatasource/ticket_remote_data_source.dart';
import 'package:tasknest/injection.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class StandardTicketsScreen extends StatefulWidget {
  final UserModel user;
  const StandardTicketsScreen({super.key, required this.user});

  @override
  State<StandardTicketsScreen> createState() => _StandardTicketsScreenState();
}

class _StandardTicketsScreenState extends State<StandardTicketsScreen> {
  final TicketRemoteDataSource _api = ticketRemoteDataSource;
  List<TicketModel> _tickets = [];
  List<DepartmentModel> _departments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _api.getStandardTickets(),
        _api.getDepartments(),
      ]);
      _tickets = results[0] as List<TicketModel>;
      _departments = results[1] as List<DepartmentModel>;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() { _loading = false; });
  }

  void _showCreateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CreateTicketSheet(
        departments: _departments,
        user: widget.user,
        api: _api,
        onCreated: _load,
      ),
    );
  }

  void _showMarkComplete(TicketModel ticket) {
    final labelCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark Complete'),
        content: TextField(
          controller: labelCtrl,
          decoration: const InputDecoration(
            labelText: 'Completion Label',
            hintText: 'e.g., Task finished successfully',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (labelCtrl.text.trim().isEmpty) return;
              try {
                await _api.markComplete(ticket.id, labelCtrl.text.trim());
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _load();
              } catch (e) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }

  void _showCloseConfirm(TicketModel ticket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close Ticket'),
        content: const Text('Close this ticket? All descendant sub-tickets must be closed first.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _api.closeTicket(ticket.id);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _load();
              } catch (e) {
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.unifiedDanger),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateSubTicket(TicketModel parent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CreateSubTicketSheet(
        parent: parent,
        departments: _departments,
        user: widget.user,
        api: _api,
        onCreated: _load,
      ),
    );
  }

  void _showChildTickets(TicketModel ticket) {
    Navigator.of(context).push(_ChildTicketsRoute(ticket: ticket, api: _api, user: widget.user));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: AppBar(
        title: const Text('Tickets'),
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showCreateDialog,
            tooltip: 'Create Ticket',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 56, color: ThemeColors.unifiedDanger),
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
                  ],
                ),
              ),
            )
          : _tickets.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_rounded, size: 72, color: ThemeColors.unifiedBorder),
                    const SizedBox(height: 16),
                    const Text('No tickets yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('Create a standard or multi ticket to get started', textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showCreateDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Ticket'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: _tickets.length,
                  itemBuilder: (_, i) => _TicketCard(
                    ticket: _tickets[i],
                    user: widget.user,
                    onMarkComplete: () => _showMarkComplete(_tickets[i]),
                    onClose: () => _showCloseConfirm(_tickets[i]),
                    onCreateSubTicket: () => _showCreateSubTicket(_tickets[i]),
                    onViewChildren: () => _showChildTickets(_tickets[i]),
                  ),
                ),
              ),
      floatingActionButton: _tickets.isNotEmpty
        ? FloatingActionButton.extended(
            onPressed: _showCreateDialog,
            backgroundColor: ThemeColors.unifiedPrimary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('New Ticket'),
          )
        : null,
    );
  }
}

// ── Ticket Card ──────────────────────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  final VoidCallback onMarkComplete;
  final VoidCallback onClose;
  final VoidCallback onCreateSubTicket;
  final VoidCallback onViewChildren;

  const _TicketCard({
    required this.ticket, required this.user,
    required this.onMarkComplete, required this.onClose,
    required this.onCreateSubTicket, required this.onViewChildren,
  });

  @override
  Widget build(BuildContext context) {
    final depts = ticket.standardDepartments ?? ticket.assignedDepartments ?? [];
    final typeLabel = ticket.isMultiTicket ? 'MULTI' : 'STANDARD';
    final typeColor = ticket.isMultiTicket ? const Color(0xFF7C3AED) : ThemeColors.unifiedPrimary;
    final typeBg = ticket.isMultiTicket ? const Color(0xFFEDE9FE) : ThemeColors.unifiedPrimary.withValues(alpha: 0.1);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ThemeColors.unifiedBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(typeLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: typeColor)),
                ),
                const SizedBox(width: 6),
                Text('#${ticket.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ThemeColors.unifiedTextMuted)),
                if (ticket.parentTicketId != null) ...[
                  const SizedBox(width: 6),
                  _Badge(text: 'SUB #${ticket.parentTicketId}', color: const Color(0xFFEA580C), bg: const Color(0xFFFFEDD5)),
                ],
                const Spacer(),
                _StatusBadge(status: ticket.status),
                const SizedBox(width: 6),
                _PriorityBadge(priority: ticket.priority),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(ticket.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            if (ticket.closedLabel != null && ticket.closedLabel!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Text('"${ticket.closedLabel}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF16A34A))),
              ),
            ],
            const SizedBox(height: 4),
            Text(ticket.description, style: const TextStyle(fontSize: 13, color: ThemeColors.unifiedTextMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Container(height: 1, color: ThemeColors.unifiedBorder.withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 13, color: ThemeColors.unifiedPrimary),
                const SizedBox(width: 4),
                Text(ticket.createdByName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ThemeColors.unifiedPrimary)),
                const SizedBox(width: 12),
                const Icon(Icons.business, size: 13, color: ThemeColors.unifiedTextMuted),
                const SizedBox(width: 4),
                Text(ticket.assignedDeptCode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted)),
              ],
            ),
            if (depts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: depts.map((d) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${d.departmentCode}: ${d.status.replaceAll('_', ' ').toUpperCase()}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
                )).toList(),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                if (ticket.status != 'completed' && ticket.status != 'closed') ...[
                  _ActionBtn(
                    icon: Icons.check_circle_outline,
                    label: 'Mark Complete',
                    color: ThemeColors.unifiedSuccess,
                    onTap: onMarkComplete,
                  ),
                  _ActionBtn(
                    icon: Icons.call_split,
                    label: 'Sub Ticket',
                    color: ThemeColors.unifiedSecondary,
                    onTap: onCreateSubTicket,
                  ),
                ],
                if (ticket.status == 'completed')
                  _ActionBtn(
                    icon: Icons.lock_outline,
                    label: 'Close',
                    color: ThemeColors.unifiedDanger,
                    onTap: onClose,
                  ),
                _ActionBtn(
                  icon: Icons.account_tree_outlined,
                  label: 'Children',
                  color: ThemeColors.unifiedTextMuted,
                  onTap: onViewChildren,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text; final Color color, bg;
  const _Badge({required this.text, required this.color, required this.bg});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

// ── Create Ticket Sheet (Standard or Multi) ─────────────────────────────
class _CreateTicketSheet extends StatefulWidget {
  final List<DepartmentModel> departments;
  final UserModel user;
  final TicketRemoteDataSource api;
  final VoidCallback onCreated;
  const _CreateTicketSheet({required this.departments, required this.user, required this.api, required this.onCreated});
  @override
  State<_CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<_CreateTicketSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'medium';
  bool _isMulti = false;
  Set<int> _selectedDeptIds = {};
  bool _saving = false;

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and description required')));
      return;
    }
    if (_selectedDeptIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one department')));
      return;
    }
    setState(() { _saving = true; });
    try {
      if (_isMulti) {
        await widget.api.createMultiTicket(
          title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
          priority: _priority, departmentIds: _selectedDeptIds.toList(),
        );
      } else {
        await widget.api.createStandardTicket(
          title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
          priority: _priority, departmentIds: _selectedDeptIds.toList(),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onCreated();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket created')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() { _saving = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ThemeColors.unifiedBorder, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Create Ticket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(children: [
            ChoiceChip(label: const Text('Standard'), selected: !_isMulti, onSelected: (_) => setState(() { _isMulti = false; _selectedDeptIds = {widget.user.departmentId}; })),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('Multi'), selected: _isMulti, onSelected: (_) => setState(() { _isMulti = true; })),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: ['low', 'medium', 'high', 'urgent'].map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase()))).toList(),
            onChanged: (v) { if (v != null) setState(() { _priority = v; }); },
          ),
          const SizedBox(height: 16),
          Text('Assign to Departments:', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: widget.departments.map((d) {
            final sel = _selectedDeptIds.contains(d.id);
            return FilterChip(
              label: Text('${d.code} - ${d.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              selected: sel,
              onSelected: (v) => setState(() { if (v) { _selectedDeptIds.add(d.id); } else { _selectedDeptIds.remove(d.id); } }),
              selectedColor: ThemeColors.unifiedPrimary.withValues(alpha: 0.15),
              checkmarkColor: ThemeColors.unifiedPrimary,
            );
          }).toList()),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.unifiedPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Ticket', style: TextStyle(fontWeight: FontWeight.w700)),
          )),
        ]),
      ),
    );
  }
}

// ── Create Sub Ticket Sheet ─────────────────────────────────────────────
class _CreateSubTicketSheet extends StatefulWidget {
  final TicketModel parent;
  final List<DepartmentModel> departments;
  final UserModel user;
  final TicketRemoteDataSource api;
  final VoidCallback onCreated;
  const _CreateSubTicketSheet({required this.parent, required this.departments, required this.user, required this.api, required this.onCreated});
  @override
  State<_CreateSubTicketSheet> createState() => _CreateSubTicketSheetState();
}

class _CreateSubTicketSheetState extends State<_CreateSubTicketSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'medium';
  int? _targetDeptId;
  bool _saving = false;

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and description required')));
      return;
    }
    setState(() { _saving = true; });
    try {
      await widget.api.createSubTicket(
        parentId: widget.parent.id,
        title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
        priority: _priority,
        targetDeptId: _targetDeptId,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onCreated();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sub-ticket created')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() { _saving = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ThemeColors.unifiedBorder, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Create Sub Ticket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('From Ticket #${widget.parent.id}', style: TextStyle(fontSize: 13, color: ThemeColors.unifiedTextMuted)),
          const SizedBox(height: 16),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: ['low', 'medium', 'high', 'urgent'].map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase()))).toList(),
            onChanged: (v) { if (v != null) setState(() { _priority = v; }); },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _targetDeptId,
            decoration: const InputDecoration(labelText: 'Route to Department (optional)'),
            items: [const DropdownMenuItem(value: null, child: Text('Same as my department')),
              ...widget.departments.map((d) => DropdownMenuItem(value: d.id, child: Text('${d.code} - ${d.name}'))),
            ],
            onChanged: (v) => setState(() { _targetDeptId = v; }),
          ),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.unifiedPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Sub Ticket', style: TextStyle(fontWeight: FontWeight.w700)),
          )),
        ]),
      ),
    );
  }
}

// ── Child Tickets View ──────────────────────────────────────────────────
class _ChildTicketsRoute extends MaterialPageRoute {
  _ChildTicketsRoute({required TicketModel ticket, required TicketRemoteDataSource api, required UserModel user})
    : super(builder: (_) => _ChildTicketsScreen(ticket: ticket, api: api, user: user));
}

class _ChildTicketsScreen extends StatefulWidget {
  final TicketModel ticket;
  final TicketRemoteDataSource api;
  final UserModel user;
  const _ChildTicketsScreen({required this.ticket, required this.api, required this.user});
  @override
  State<_ChildTicketsScreen> createState() => _ChildTicketsScreenState();
}

class _ChildTicketsScreenState extends State<_ChildTicketsScreen> {
  List<TicketModel> _children = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try { _children = await widget.api.getChildTickets(widget.ticket.id); }
    catch (e) { _error = e.toString(); }
    if (mounted) setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: AppBar(title: Text('#${widget.ticket.id} — Children'), backgroundColor: ThemeColors.unifiedSurface, elevation: 0, scrolledUnderElevation: 1),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : _error != null ? Center(child: Text(_error!))
        : _children.isEmpty ? const Center(child: Text('No child tickets'))
        : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _children.length, itemBuilder: (_, i) {
            final c = _children[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8), elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: ThemeColors.unifiedBorder)),
              child: ListTile(
                title: Text('#${c.id} ${c.title}', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${c.assignedDeptCode} | ${c.status.replaceAll('_', ' ').toUpperCase()}'),
                  if (c.closedLabel != null && c.closedLabel!.isNotEmpty)
                    Text('"${c.closedLabel}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF16A34A))),
                ]),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/ticket/${c.id}'),
              ),
            );
          }),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      'open' => (const Color(0xFFDBEAFE), const Color(0xFF1E40AF), 'OPEN'),
      'in_progress' => (const Color(0xFFFEF3C7), const Color(0xFF92400E), 'IN PROGRESS'),
      'completed' => (const Color(0xFFDCFCE7), const Color(0xFF16A34A), 'COMPLETED'),
      'closed' => (const Color(0xFFF3F4F6), const Color(0xFF6B7280), 'CLOSED'),
      _ => (const Color(0xFFF3F4F6), const Color(0xFF6B7280), status.toUpperCase()),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});
  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (priority) {
      'urgent' => (const Color(0xFFFEE2E2), const Color(0xFFDC2626), 'URGENT'),
      'high' => (const Color(0xFFFFEDD5), const Color(0xFFEA580C), 'HIGH'),
      'medium' => (const Color(0xFFFEF3C7), const Color(0xFFD97706), 'MEDIUM'),
      _ => (const Color(0xFFDCFCE7), const Color(0xFF16A34A), 'LOW'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
