import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_state.dart';

class AdminUserActivityScreen extends StatefulWidget {
  final AdminBloc bloc;
  const AdminUserActivityScreen({super.key, required this.bloc});

  @override
  State<AdminUserActivityScreen> createState() => _AdminUserActivityScreenState();
}

class _AdminUserActivityScreenState extends State<AdminUserActivityScreen> {
  String _filter = 'all';
  final TextEditingController _searchCtl = TextEditingController();
  String _searchQuery = '';
  int _page = 0;
  static const int _pageSize = 30;

  @override
  void initState() {
    super.initState();
    widget.bloc.add(LoadUserActivity());
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
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
                  const Text('User Activity', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ThemeColors.unifiedTextPrimary)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () { _page = 0; widget.bloc.add(LoadUserActivity()); },
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _filterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _filterChip('Online Now', 'online'),
                  const SizedBox(width: 8),
                  _filterChip('Logged In Before', 'loggedin'),
                  const SizedBox(width: 8),
                  _filterChip('Never Logged In', 'never'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: TextField(
                  controller: _searchCtl,
                  onChanged: (v) => setState(() { _searchQuery = v; _page = 0; }),
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, code, designation, department...',
                    hintStyle: TextStyle(fontSize: 13, color: ThemeColors.unifiedTextMuted),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () { _searchCtl.clear(); setState(() { _searchQuery = ''; _page = 0; }); },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: ThemeColors.unifiedBorder)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (state is AdminLoading) const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (state is UserActivityLoaded) Expanded(child: _buildList(context, state.users))
              else if (state is AdminError) Expanded(child: Center(child: Text(state.message, style: const TextStyle(color: ThemeColors.unifiedDanger))))
              else const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, String value) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () => setState(() { _filter = value; _page = 0; }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? ThemeColors.unifiedSecondary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? ThemeColors.unifiedSecondary : ThemeColors.unifiedBorder),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: active ? Colors.white : ThemeColors.unifiedTextPrimary)),
      ),
    );
  }

  List<AdminUserModel> _filtered(List<AdminUserModel> users) {
    var result = users;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((u) =>
        u.name.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q) ||
        (u.code?.toLowerCase().contains(q) ?? false) ||
        (u.designation?.toLowerCase().contains(q) ?? false) ||
        (u.departmentName?.toLowerCase().contains(q) ?? false) ||
        (u.companyName?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    switch (_filter) {
      case 'online':
        return result.where((u) => u.isOnline).toList();
      case 'loggedin':
        return result.where((u) => u.lastActive != null && !u.isOnline).toList();
      case 'never':
        return result.where((u) => u.lastActive == null).toList();
      default:
        return result;
    }
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
            style: const TextStyle(fontSize: 13, color: ThemeColors.unifiedTextMuted)),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _page >= pages - 1 ? null : () => setState(() => _page++),
          ),
        ],
      ),
    );
  }

  Widget _activeDot(bool online) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: online ? const Color(0xFF22C55E) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildList(BuildContext context, List<AdminUserModel> allUsers) {
    final filtered = _filtered(allUsers);
    final users = _pageOf(filtered);
    if (users.isEmpty) {
      return Center(child: Text('No users found', style: TextStyle(color: ThemeColors.unifiedTextMuted)));
    }
    final online = allUsers.where((u) => u.isOnline).length;
    final never = allUsers.where((u) => u.lastActive == null).length;
    return Column(
      children: [
        Row(
          children: [
            _statBox('Total Users', '${allUsers.length}'),
            const SizedBox(width: 12),
            _statBox('Online Now', '$online', color: const Color(0xFF22C55E)),
            const SizedBox(width: 12),
            _statBox('Never Logged In', '$never', color: ThemeColors.unifiedWarning),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: users.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final u = users[i];
                      final lastActiveStr = u.lastActive != null
                          ? _formatTimestamp(u.lastActive!)
                          : 'Never';
                      return ListTile(
                        dense: true,
                        leading: _activeDot(u.isOnline),
                        title: Text('${u.name} (${u.code ?? 'N/A'})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text('${u.departmentName ?? '-'} · ${u.companyName ?? '-'}',
                          style: const TextStyle(fontSize: 12, color: ThemeColors.unifiedTextMuted)),
                        trailing: Text(lastActiveStr, style: TextStyle(fontSize: 12, color: u.isOnline ? const Color(0xFF22C55E) : ThemeColors.unifiedTextMuted)),
                      );
                    },
                  ),
                ),
                _pageNav(filtered.length),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBox(String label, String value, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ThemeColors.unifiedBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color ?? ThemeColors.unifiedTextPrimary)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: ThemeColors.unifiedTextMuted)),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return ts;
    }
  }
}
