import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_state.dart';

class AdminUserActivityScreen extends StatelessWidget {
  final AdminBloc bloc;
  const AdminUserActivityScreen({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    bloc.add(LoadUserActivity());
    final searchCtl = TextEditingController(
      text: bloc.state is UserActivityLoaded
          ? (bloc.state as UserActivityLoaded).searchQuery
          : '',
    );

    return BlocBuilder<AdminBloc, AdminState>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        final activityState = state is UserActivityLoaded
            ? state
            : null;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('User Activity',
                      style: AppTextStyles.pageTitle),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        bloc.add(LoadUserActivity()),
                    tooltip: ConstStrings.refresh,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _filterChip('All', 'all',
                      activityState?.filter ?? 'all'),
                  const SizedBox(width: 8),
                  _filterChip('Online Now', 'online',
                      activityState?.filter ?? 'all'),
                  const SizedBox(width: 8),
                  _filterChip('Logged In Before', 'loggedin',
                      activityState?.filter ?? 'all'),
                  const SizedBox(width: 8),
                  _filterChip('Never Logged In', 'never',
                      activityState?.filter ?? 'all'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: TextField(
                  controller: searchCtl,
                  onChanged: (v) =>
                      bloc.add(UpdateActivitySearchQuery(v)),
                  decoration: InputDecoration(
                    hintText:
                        'Search by name, email, code, designation, department...',
                    hintStyle: TextStyle(
                        fontSize: 13,
                        color: ThemeColors.unifiedTextMuted),
                    prefixIcon:
                        const Icon(Icons.search, size: 18),
                    suffixIcon: (activityState
                                    ?.searchQuery ??
                                '')
                            .isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                size: 18),
                            onPressed: () {
                              searchCtl.clear();
                              bloc.add(
                                  UpdateActivitySearchQuery(''));
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: ThemeColors.unifiedBorder)),
                    contentPadding:
                        const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (state is AdminLoading)
                const Expanded(
                    child:
                        Center(child: CircularProgressIndicator()))
              else if (activityState != null)
                Expanded(
                    child: _buildList(
                        context, activityState))
              else if (state is AdminError)
                Expanded(
                    child: Center(
                        child: Text(state.message,
                            style: const TextStyle(
                                color:
                                    ThemeColors.unifiedDanger))))
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(
      String label, String value, String currentFilter) {
    final active = currentFilter == value;
    return GestureDetector(
      onTap: () => bloc.add(UpdateActivityFilter(value)),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? ThemeColors.unifiedSecondary
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: active
                  ? ThemeColors.unifiedSecondary
                  : ThemeColors.unifiedBorder),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: active
                    ? Colors.white
                    : ThemeColors.unifiedTextPrimary)),
      ),
    );
  }

  Widget _buildList(
      BuildContext context, UserActivityLoaded activityState) {
    final filtered = activityState.filteredUsers;
    final users = activityState.pageItems;
    final allUsers = activityState.users;
    final page = activityState.clampedPage;
    final totalPages = activityState.totalPages;

    if (users.isEmpty && filtered.isEmpty) {
      return Center(
          child: Text('No users found',
              style: TextStyle(
                  color: ThemeColors.unifiedTextMuted)));
    }
    final online =
        allUsers.where((u) => u.isOnline).length;
    final never =
        allUsers.where((u) => u.lastActive == null).length;
    return Column(
      children: [
        Row(
          children: [
            _statBox('Total Users', '${allUsers.length}'),
            const SizedBox(width: 12),
            _statBox('Online Now', '$online',
                color: const Color(0xFF22C55E)),
            const SizedBox(width: 12),
            _statBox('Never Logged In', '$never',
                color: ThemeColors.unifiedWarning),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: users.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final u = users[i];
                      final lastActiveStr = u.lastActive != null
                          ? _formatTimestamp(u.lastActive!)
                          : 'Never';
                      return ListTile(
                        dense: true,
                        leading: _activeDot(u.isOnline),
                        title: Text(
                            '${u.name} (${u.code ?? 'N/A'})',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        subtitle: Text(
                            '${u.departmentName ?? '-'} · ${u.companyName ?? '-'}',
                            style: AppTextStyles.caption),
                        trailing: Text(lastActiveStr,
                            style: TextStyle(
                                fontSize: 12,
                                color: u.isOnline
                                    ? const Color(0xFF22C55E)
                                    : ThemeColors
                                        .unifiedTextMuted)),
                      );
                    },
                  ),
                ),
                _pageNav(filtered.length, page, totalPages),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pageNav(int total, int page, int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: page <= 0
                ? null
                : () => bloc
                    .add(UpdateActivityPage(page - 1)),
          ),
          Text(
              'Page ${page + 1} of $totalPages ($total users)',
              style: AppTextStyles.bodySmallMuted),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: page >= totalPages - 1
                ? null
                : () => bloc
                    .add(UpdateActivityPage(page + 1)),
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
        color: online
            ? const Color(0xFF22C55E)
            : Colors.grey.shade300,
      ),
    );
  }

  Widget _statBox(String label, String value, {Color? color}) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ThemeColors.unifiedBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: color ??
                        ThemeColors.unifiedTextPrimary)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
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
