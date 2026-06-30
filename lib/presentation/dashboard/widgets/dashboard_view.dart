import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/name_by_id.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_section_headers.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_Listview.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';

class DashboardView extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;
  const DashboardView({super.key, required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    final isManager = user.roleId == 0 || user.roleId == 1 || user.roleId == 3;
    return _DashboardBody(state: state, user: user, isManager: isManager);
  }
}

// ── Main scrollable body ──────────────────────────────────────────────────────
class _DashboardBody extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;
  final bool isManager;

  const _DashboardBody({
    required this.state,
    required this.user,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 768;
    final s = state.stats;

    final deptLookup = state.departments
        .map((d) => Departments(name: d.name, id: d.id))
        .toList();
    final departmentName = NameById.getNameById<Departments>(
      id: user.departmentId,
      items: deptLookup,
      idSelector: (e) => e.id,
      nameSelector: (e) => e.name,
    );
    final roleName = NameById.getNameById<Roles>(
      id: user.roleId,
      items: roles,
      idSelector: (e) => e.id,
      nameSelector: (e) => e.name,
    );
    final companyName = NameById.getNameById<Company>(
      id: user.companyId,
      items: CompanyNames,
      idSelector: (e) => e.id,
      nameSelector: (e) => e.name,
    );

    return Container(
      color: ThemeColors.unifiedBackground,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero header (gradient, identity + actions baked in) ─
            _HeroHeader(
              user: user,
              isWide: isWide,
              departmentName: departmentName,
              roleName: roleName,
              companyName: companyName,
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 28 : 16,
                isWide ? 24 : 18,
                isWide ? 28 : 16,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats grid (manager/ceo only) ───────────────
                  if (isManager) ...[
                    CommaonSectionHeader(
                      icon: Icons.bar_chart_rounded,
                      title: 'Overview',
                    ),
                    const SizedBox(height: 12),
                    _StatsGrid(s: s, isWide: isWide),
                    const SizedBox(height: 28),

                    // ── Avg resolution time card ────────────────
                    CommaonSectionHeader(
                      icon: Icons.av_timer_rounded,
                      title: 'Resolution Metrics',
                    ),
                    const SizedBox(height: 12),
                    _ResolutionMetricsRow(s: s, isWide: isWide),
                    const SizedBox(height: 28),

                    // ── Priority distribution ───────────────────
                    CommaonSectionHeader(
                      icon: Icons.flag_outlined,
                      title: 'Priority Breakdown',
                    ),
                    const SizedBox(height: 12),
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _PriorityCard(s: s)),
                              const SizedBox(width: 16),
                              Expanded(child: _StatusSummaryCard(s: s)),
                            ],
                          )
                        : Column(
                            children: [
                              _PriorityCard(s: s),
                              const SizedBox(height: 16),
                              _StatusSummaryCard(s: s),
                            ],
                          ),
                    const SizedBox(height: 28),
                  ],

                  // ── Ticket search + list (employees only) ──────────
                  if (!isManager) TicketListView(state: state, user: user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero header ────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final UserModel user;
  final bool isWide;
  final String? departmentName, roleName, companyName;

  const _HeroHeader({
    required this.user,
    required this.isWide,
    this.departmentName,
    this.roleName,
    this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative background blobs for depth
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: 80,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isWide ? 28 : 16,
              isWide ? 28 : 20,
              isWide ? 28 : 16,
              isWide ? 26 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting,',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.6,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Here\'s what\'s happening with your tickets today',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.75),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _HeroActionButton(
                      icon: Icons.refresh_rounded,
                      label: isWide ? 'Refresh' : null,
                      onTap: () => context.read<DashboardBloc>().add(
                        LoadDashboard(page: 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HeroActionButton(
                      icon: Icons.power_settings_new_rounded,
                      label: isWide ? 'Logout' : null,
                      onTap: () {
                        context.read<AuthBloc>().add(LogoutEvent());
                        context.go('/login');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _IdentityPill(
                  userName: user.name,
                  designation: user.designation,
                  departmentName: departmentName,
                  roleName: roleName,
                  companyName: companyName,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  const _HeroActionButton({
    required this.icon,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: label != null ? 14 : 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Identity pill (glassy, sits inside the hero) ────────────────────────────────
class _IdentityPill extends StatelessWidget {
  final String userName;
  final String designation;
  final String? departmentName, roleName, companyName;

  const _IdentityPill({
    required this.userName,
    this.designation = '',
    this.departmentName,
    this.roleName,
    this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                if (companyName != null) _MetaChip(companyName!),
                if (departmentName != null) _MetaChip(departmentName!),
                _MetaChip(
                  roleName?.toLowerCase() == 'ceo'
                      ? 'CEO'
                      : (designation.isNotEmpty
                            ? designation
                            : (roleName ?? '')),
                  emphasis: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;
  final bool emphasis;
  const _MetaChip(this.text, {this.emphasis = false});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(emphasis ? 0.24 : 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final DashboardStats s;
  final bool isWide;
  const _StatsGrid({super.key, required this.s, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        'Total',
        s.total,
        ThemeColors.unifiedPrimary,
        Icons.inbox_outlined,
      ),
      _StatItem(
        'Open',
        s.open,
        ThemeColors.unifiedSecondary,
        Icons.radio_button_unchecked_rounded,
      ),
      _StatItem(
        'In Progress',
        s.inProgress,
        ThemeColors.unifiedWarning,
        Icons.autorenew_rounded,
      ),
      _StatItem(
        'Completed',
        s.completed,
        ThemeColors.unifiedAccent,
        Icons.check_circle_outline_rounded,
      ),
      _StatItem(
        'Closed',
        s.closed,
        ThemeColors.unifiedTextMuted,
        Icons.lock_outline_rounded,
      ),
      _StatItem(
        'Urgent',
        s.urgent,
        ThemeColors.unifiedDanger,
        Icons.warning_amber_rounded,
      ),
      _StatItem(
        'High Pri.',
        s.highPriority,
        const Color(0xFFEA580C),
        Icons.priority_high_rounded,
      ),
      _StatItem(
        'Overdue',
        s.overdue,
        ThemeColors.unifiedDanger,
        Icons.access_time_rounded,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide
            ? 4
            : (MediaQuery.sizeOf(context).width > 480 ? 2 : 1),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isWide ? 3.0 : 2.1,
      ),
      itemBuilder: (_, i) => _StatCard(item: items[i]),
    );
  }
}

class _StatItem {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  const _StatItem(this.label, this.value, this.color, this.icon);
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ThemeColors.unifiedBorder.withOpacity(0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    item.color.withOpacity(0.16),
                    item.color.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 19, color: item.color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: _StatTextContent(value: item.value, label: item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTextContent extends StatelessWidget {
  final int value;
  final String label;
  const _StatTextContent({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: ThemeColors.unifiedTextPrimary,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: ThemeColors.unifiedTextMuted,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Resolution metrics row ────────────────────────────────────────────────────
class _ResolutionMetricsRow extends StatelessWidget {
  final DashboardStats s;
  final bool isWide;
  const _ResolutionMetricsRow({required this.s, required this.isWide});

  /// Computes avg hours to close from stats.
  /// Assumes stats exposes avgResolutionHours; falls back to estimate.
  String _avgTime() {
    // If your stats model has avgResolutionHours use it directly:
    // return '${s.avgResolutionHours.toStringAsFixed(1)}h';
    //
    // Fallback heuristic until backend provides it:
    final resolved = s.completed + s.closed;
    if (resolved == 0) return '—';
    // placeholder — replace with real field when available
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final completionRate = s.total > 0
        ? ((s.completed / s.total) * 100).toStringAsFixed(1)
        : '0.0';
    final overdueRate = s.total > 0
        ? ((s.overdue / s.total) * 100).toStringAsFixed(1)
        : '0.0';

    final tiles = [
      _ResolItem(
        icon: Icons.av_timer_rounded,
        label: 'Avg. Resolution Time',
        value: _avgTime(),
        sub: 'per ticket closed',
        color: ThemeColors.unifiedSecondary,
      ),
      _ResolItem(
        icon: Icons.check_circle_outline_rounded,
        label: 'Completion Rate',
        value: '$completionRate%',
        sub: '${s.completed} of ${s.total} tickets',
        color: ThemeColors.unifiedAccent,
      ),
      _ResolItem(
        icon: Icons.access_time_rounded,
        label: 'Overdue Rate',
        value: '$overdueRate%',
        sub: '${s.overdue} overdue tickets',
        color: ThemeColors.unifiedDanger,
      ),
      _ResolItem(
        icon: Icons.warning_amber_rounded,
        label: 'Critical Load',
        value: '${s.urgent}',
        sub: 'urgent tickets open',
        color: const Color(0xFFEA580C),
      ),
    ];

    return isWide
        ? Row(
            children: tiles
                .map(
                  (t) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: tiles.indexOf(t) < tiles.length - 1 ? 12 : 0,
                      ),
                      child: _ResolutionTile(item: t),
                    ),
                  ),
                )
                .toList(),
          )
        : GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: tiles.map((t) => _ResolutionTile(item: t)).toList(),
          );
  }
}

class _ResolItem {
  final IconData icon;
  final String label, value, sub;
  final Color color;
  const _ResolItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });
}

class _ResolutionTile extends StatelessWidget {
  final _ResolItem item;
  const _ResolutionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.color.withOpacity(0.18),
                      item.color.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(item.icon, size: 17, color: item.color),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: item.color,
              letterSpacing: -0.8,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.sub,
            style: const TextStyle(
              fontSize: 11,
              color: ThemeColors.unifiedTextMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Priority card ─────────────────────────────────────────────────────────────
class _PriorityCard extends StatelessWidget {
  final DashboardStats s;
  const _PriorityCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final total = s.total;
    final items = [
      _PriorityItem('Urgent', s.urgent, ThemeColors.unifiedDanger),
      _PriorityItem('High', s.highPriority, const Color(0xFFEA580C)),
      _PriorityItem(
        'Medium & Low',
        total - s.urgent - s.highPriority,
        ThemeColors.unifiedPrimary,
      ),
    ];

    return _BaseCard(
      icon: Icons.flag_outlined,
      title: 'Priority Distribution',
      child: Column(
        children: items
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _PriorityBar(item: e, total: total),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PriorityItem {
  final String label;
  final int value;
  final Color color;
  const _PriorityItem(this.label, this.value, this.color);
}

class _PriorityBar extends StatelessWidget {
  final _PriorityItem item;
  final int total;
  const _PriorityBar({required this.item, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? item.value / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '${item.value} (${(pct * 100).toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 7,
            backgroundColor: item.color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(item.color),
          ),
        ),
      ],
    );
  }
}

// ── Status summary card ───────────────────────────────────────────────────────
class _StatusSummaryCard extends StatelessWidget {
  final DashboardStats s;
  const _StatusSummaryCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final total = s.total;
    final rows = [
      _StatusItem(
        'Open',
        s.open,
        total,
        ThemeColors.unifiedSecondary,
        ThemeColors.statusOpenBg,
        ThemeColors.statusOpenFg,
      ),
      _StatusItem(
        'In Progress',
        s.inProgress,
        total,
        ThemeColors.unifiedWarning,
        ThemeColors.statusProgressBg,
        ThemeColors.statusProgressFg,
      ),
      _StatusItem(
        'Completed',
        s.completed,
        total,
        ThemeColors.unifiedAccent,
        ThemeColors.statusDoneBg,
        ThemeColors.statusDoneFg,
      ),
      _StatusItem(
        'Closed',
        s.closed,
        total,
        ThemeColors.unifiedTextMuted,
        ThemeColors.statusClosedBg,
        ThemeColors.statusClosedFg,
      ),
    ];

    return _BaseCard(
      icon: Icons.donut_small_outlined,
      title: 'Status Summary',
      child: Column(children: rows.map((e) => _StatusRow(item: e)).toList()),
    );
  }
}

class _StatusItem {
  final String label;
  final int count, total;
  final Color dotColor, badgeBg, badgeFg;
  const _StatusItem(
    this.label,
    this.count,
    this.total,
    this.dotColor,
    this.badgeBg,
    this.badgeFg,
  );
}

class _StatusRow extends StatelessWidget {
  final _StatusItem item;
  const _StatusRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final pct = item.total > 0
        ? ((item.count / item.total) * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeColors.unifiedBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: item.badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${item.count}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: item.badgeFg,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 42,
            child: Text(
              '$pct%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared base card ──────────────────────────────────────────────────────────
class _BaseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _BaseCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ThemeColors.unifiedBorder),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeColors.unifiedPrimary.withOpacity(0.16),
                        ThemeColors.unifiedPrimary.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 15,
                    color: ThemeColors.unifiedPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:tasknest/core/constant/const_dep.dart';
// import 'package:tasknest/core/constant/name_by_id.dart';
// import 'package:tasknest/core/theme/color.dart';
// import 'package:tasknest/core/theme/common_section_headers.dart';
// import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
// import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
// import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
// import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
// import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_Listview.dart';
// import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';
// import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
// import 'package:tasknest/presentation/login/bloc/login_event.dart';

// class DashboardView extends StatelessWidget {
//   final DashboardLoaded state;
//   final UserModel user;
//   const DashboardView({super.key, required this.state, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final isManager = user.roleId == 0 || user.roleId == 1 || user.roleId == 3;
//     return _DashboardBody(state: state, user: user, isManager: isManager);
//   }
// }

// // ── Main scrollable body ──────────────────────────────────────────────────────
// class _DashboardBody extends StatelessWidget {
//   final DashboardLoaded state;
//   final UserModel user;
//   final bool isManager;

//   const _DashboardBody({
//     required this.state,
//     required this.user,
//     required this.isManager,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isWide = MediaQuery.sizeOf(context).width > 768;
//     final s = state.stats;

//     final deptLookup = state.departments.map((d) => Departments(name: d.name, id: d.id)).toList();
//     final departmentName = NameById.getNameById<Departments>(
//       id: user.departmentId,
//       items: deptLookup,
//       idSelector: (e) => e.id,
//       nameSelector: (e) => e.name,
//     );
//     final roleName = NameById.getNameById<Roles>(
//       id: user.roleId,
//       items: roles,
//       idSelector: (e) => e.id,
//       nameSelector: (e) => e.name,
//     );
//     final companyName = NameById.getNameById<Company>(
//       id: user.companyId,
//       items: CompanyNames,
//       idSelector: (e) => e.id,
//       nameSelector: (e) => e.name,
//     );

//     return Padding(
//       padding: EdgeInsets.all(isWide ? 28 : 16).copyWith(bottom: 24),

//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Top bar: welcome + actions ──────────────────────────────
//             _TopBar(user: user, isWide: isWide),
//             const SizedBox(height: 16),

//             // ── Identity pill ───────────────────────────────────────────
//             _IdentityPill(
//               userName: user.name,
//               designation: user.designation,
//               departmentName: departmentName,
//               roleName: roleName,
//               companyName: companyName,
//             ),
//             const SizedBox(height: 24),

//             // ── Stats grid (manager/ceo only) ───────────────────────────
//             if (isManager) ...[
//               CommaonSectionHeader(
//                 icon: Icons.bar_chart_rounded,
//                 title: 'Overview',
//                 // trailing: isManager ? _AnalyticsLink(user: user) : null,
//               ),
//               const SizedBox(height: 12),
//               _StatsGrid(s: s, isWide: isWide),
//               const SizedBox(height: 24),

//               // ── Avg resolution time card ────────────────────────────
//               CommaonSectionHeader(
//                 icon: Icons.av_timer_rounded,
//                 title: 'Resolution Metrics',
//               ),
//               const SizedBox(height: 12),
//               _ResolutionMetricsRow(s: s, isWide: isWide),
//               const SizedBox(height: 24),

//               // ── Priority distribution ───────────────────────────────
//               CommaonSectionHeader(
//                 icon: Icons.flag_outlined,
//                 title: 'Priority Breakdown',
//               ),
//               const SizedBox(height: 12),
//               isWide
//                   ? Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(child: _PriorityCard(s: s)),
//                         const SizedBox(width: 16),
//                         Expanded(child: _StatusSummaryCard(s: s)),
//                       ],
//                     )
//                   : Column(
//                       children: [
//                         _PriorityCard(s: s),
//                         const SizedBox(height: 16),
//                         _StatusSummaryCard(s: s),
//                       ],
//                     ),
//               const SizedBox(height: 24),
//             ],

//             // ── Ticket search + list (all roles) ──────────────────
//             const SizedBox(height: 8),
//             TicketListView(state: state, user: user),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Top bar ───────────────────────────────────────────────────────────────────
// class _TopBar extends StatelessWidget {
//   final UserModel user;
//   final bool isWide;
//   const _TopBar({required this.user, required this.isWide});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Welcome back,',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: ThemeColors.unifiedTextMuted,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 user.name,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w800,
//                   color: ThemeColors.unifiedTextPrimary,
//                   letterSpacing: -0.5,
//                   height: 1.1,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               const Text(
//                 'Your department ticket overview',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: ThemeColors.unifiedTextMuted,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 12),
//         // Action buttons
//         _ActionButton(
//           icon: Icons.refresh_rounded,
//           label: isWide ? 'Refresh' : null,
//           color: ThemeColors.unifiedPrimary,
//           onTap: () =>
//               context.read<DashboardBloc>().add(LoadDashboard(page: 1)),
//         ),
//         const SizedBox(width: 8),
//         _ActionButton(
//           icon: Icons.power_settings_new_rounded,
//           label: isWide ? 'Logout' : null,
//           color: ThemeColors.unifiedDanger,
//           onTap: () {
//             context.read<AuthBloc>().add(LogoutEvent());
//             context.go('/login');
//           },
//         ),
//       ],
//     );
//   }
// }

// class _ActionButton extends StatelessWidget {
//   final IconData icon;
//   final String? label;
//   final Color color;
//   final VoidCallback onTap;

//   const _ActionButton({
//     required this.icon,
//     required this.color,
//     required this.onTap,
//     this.label,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: label != null ? 14 : 10,
//           vertical: 10,
//         ),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: color.withOpacity(0.2), width: 1.5),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 16, color: color),
//             if (label != null) ...[
//               const SizedBox(width: 6),
//               Text(
//                 label!,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: color,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Identity pill ─────────────────────────────────────────────────────────────
// class _IdentityPill extends StatelessWidget {
//   final String userName;
//   final String designation;
//   final String? departmentName, roleName, companyName;

//   const _IdentityPill({
//     required this.userName,
//     this.designation = '',
//     this.departmentName,
//     this.roleName,
//     this.companyName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: ThemeColors.unifiedSurface,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
//       ),
//       child: Row(
//         children: [
//           // Avatar
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [
//                   ThemeColors.unifiedGradStart,
//                   ThemeColors.unifiedGradEnd,
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w800,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//               child: Text(
//                 [
//                   userName.toUpperCase(),
//                   if (companyName != null) companyName!,
//                   if (departmentName != null) departmentName!,
//                   roleName?.toLowerCase() == 'ceo' ? 'CEO' : designation.isNotEmpty ? designation : roleName ?? '',
//                 ].join(' · '),
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: ThemeColors.unifiedTextPrimary,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(
//               color: ThemeColors.unifiedPrimary.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'Full visibility',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: ThemeColors.unifiedPrimary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Stats grid ────────────────────────────────────────────────────────────────
// class _StatsGrid extends StatelessWidget {
//   final DashboardStats s;
//   final bool isWide;
//   const _StatsGrid({super.key, required this.s, required this.isWide});

//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       _StatItem(
//         'Total',
//         s.total,
//         ThemeColors.unifiedPrimary,
//         Icons.inbox_outlined,
//       ),
//       _StatItem(
//         'Open',
//         s.open,
//         ThemeColors.unifiedSecondary,
//         Icons.radio_button_unchecked_rounded,
//       ),
//       _StatItem(
//         'In Progress',
//         s.inProgress,
//         ThemeColors.unifiedWarning,
//         Icons.autorenew_rounded,
//       ),
//       _StatItem(
//         'Completed',
//         s.completed,
//         ThemeColors.unifiedAccent,
//         Icons.check_circle_outline_rounded,
//       ),
//       _StatItem(
//         'Closed',
//         s.closed,
//         ThemeColors.unifiedTextMuted,
//         Icons.lock_outline_rounded,
//       ),
//       _StatItem(
//         'Urgent',
//         s.urgent,
//         ThemeColors.unifiedDanger,
//         Icons.warning_amber_rounded,
//       ),
//       _StatItem(
//         'High Pri.',
//         s.highPriority,
//         const Color(0xFFEA580C),
//         Icons.priority_high_rounded,
//       ),
//       _StatItem(
//         'Overdue',
//         s.overdue,
//         ThemeColors.unifiedDanger,
//         Icons.access_time_rounded,
//       ),
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: items.length,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: isWide
//             ? 4
//             : (MediaQuery.sizeOf(context).width > 480 ? 2 : 1),
//         mainAxisSpacing: 10,
//         crossAxisSpacing: 10,
//         childAspectRatio: isWide ? 3.2 : 2.2,
//       ),
//       itemBuilder: (_, i) => _StatCard(item: items[i]),
//     );
//   }
// }

// class _StatItem {
//   final String label;
//   final int value;
//   final Color color;
//   final IconData icon;
//   const _StatItem(this.label, this.value, this.color, this.icon);
// }

// class _StatCard extends StatelessWidget {
//   final _StatItem item;
//   const _StatCard({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: ThemeColors.unifiedSurface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: ThemeColors.unifiedBorder.withOpacity(0.8),
//           width: 1.2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: item.color.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.hardEdge,
//       child: Column(
//         children: [
//           Container(height: 4, color: item.color.withOpacity(0.7)),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: item.color.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(item.icon, size: 18, color: item.color),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _StatTextContent(
//                       value: item.value,
//                       label: item.label,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatTextContent extends StatelessWidget {
//   final int value;
//   final String label;
//   const _StatTextContent({required this.value, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '$value',
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w800,
//             color: ThemeColors.unifiedTextPrimary,
//             letterSpacing: -0.5,
//             height: 1,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//             color: ThemeColors.unifiedTextMuted,
//           ),
//           overflow: TextOverflow.ellipsis,
//         ),
//       ],
//     );
//   }
// }

// // ── Resolution metrics row ────────────────────────────────────────────────────
// class _ResolutionMetricsRow extends StatelessWidget {
//   final DashboardStats s;
//   final bool isWide;
//   const _ResolutionMetricsRow({required this.s, required this.isWide});

//   /// Computes avg hours to close from stats.
//   /// Assumes stats exposes avgResolutionHours; falls back to estimate.
//   String _avgTime() {
//     // If your stats model has avgResolutionHours use it directly:
//     // return '${s.avgResolutionHours.toStringAsFixed(1)}h';
//     //
//     // Fallback heuristic until backend provides it:
//     final resolved = s.completed + s.closed;
//     if (resolved == 0) return '—';
//     // placeholder — replace with real field when available
//     return 'N/A';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final completionRate = s.total > 0
//         ? ((s.completed / s.total) * 100).toStringAsFixed(1)
//         : '0.0';
//     final overdueRate = s.total > 0
//         ? ((s.overdue / s.total) * 100).toStringAsFixed(1)
//         : '0.0';

//     final tiles = [
//       _ResolItem(
//         icon: Icons.av_timer_rounded,
//         label: 'Avg. Resolution Time',
//         value: _avgTime(),
//         sub: 'per ticket closed',
//         color: ThemeColors.unifiedSecondary,
//       ),
//       _ResolItem(
//         icon: Icons.check_circle_outline_rounded,
//         label: 'Completion Rate',
//         value: '$completionRate%',
//         sub: '${s.completed} of ${s.total} tickets',
//         color: ThemeColors.unifiedAccent,
//       ),
//       _ResolItem(
//         icon: Icons.access_time_rounded,
//         label: 'Overdue Rate',
//         value: '$overdueRate%',
//         sub: '${s.overdue} overdue tickets',
//         color: ThemeColors.unifiedDanger,
//       ),
//       _ResolItem(
//         icon: Icons.warning_amber_rounded,
//         label: 'Critical Load',
//         value: '${s.urgent}',
//         sub: 'urgent tickets open',
//         color: const Color(0xFFEA580C),
//       ),
//     ];

//     return isWide
//         ? Row(
//             children: tiles
//                 .map(
//                   (t) => Expanded(
//                     child: Padding(
//                       padding: EdgeInsets.only(
//                         right: tiles.indexOf(t) < tiles.length - 1 ? 10 : 0,
//                       ),
//                       child: _ResolutionTile(item: t),
//                     ),
//                   ),
//                 )
//                 .toList(),
//           )
//         : GridView.count(
//             crossAxisCount: 2,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             mainAxisSpacing: 10,
//             crossAxisSpacing: 10,
//             childAspectRatio: 1.4,
//             children: tiles.map((t) => _ResolutionTile(item: t)).toList(),
//           );
//   }
// }

// class _ResolItem {
//   final IconData icon;
//   final String label, value, sub;
//   final Color color;
//   const _ResolItem({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.sub,
//     required this.color,
//   });
// }

// class _ResolutionTile extends StatelessWidget {
//   final _ResolItem item;
//   const _ResolutionTile({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: ThemeColors.unifiedSurface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: item.color.withOpacity(0.06),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   color: item.color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(item.icon, size: 16, color: item.color),
//               ),
//               const Spacer(),
//               Container(
//                 width: 6,
//                 height: 6,
//                 decoration: BoxDecoration(
//                   color: item.color,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             item.value,
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w800,
//               color: item.color,
//               letterSpacing: -0.8,
//               height: 1,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             item.label,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//               color: ThemeColors.unifiedTextPrimary,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             item.sub,
//             style: const TextStyle(
//               fontSize: 11,
//               color: ThemeColors.unifiedTextMuted,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Priority card ─────────────────────────────────────────────────────────────
// class _PriorityCard extends StatelessWidget {
//   final DashboardStats s;
//   const _PriorityCard({required this.s});

//   @override
//   Widget build(BuildContext context) {
//     final total = s.total;
//     final items = [
//       _PriorityItem('Urgent', s.urgent, ThemeColors.unifiedDanger),
//       _PriorityItem('High', s.highPriority, const Color(0xFFEA580C)),
//       _PriorityItem(
//         'Medium & Low',
//         total - s.urgent - s.highPriority,
//         ThemeColors.unifiedPrimary,
//       ),
//     ];

//     return _BaseCard(
//       icon: Icons.flag_outlined,
//       title: 'Priority Distribution',
//       child: Column(
//         children: items
//             .map(
//               (e) => Padding(
//                 padding: const EdgeInsets.only(bottom: 14),
//                 child: _PriorityBar(item: e, total: total),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }
// }

// class _PriorityItem {
//   final String label;
//   final int value;
//   final Color color;
//   const _PriorityItem(this.label, this.value, this.color);
// }

// class _PriorityBar extends StatelessWidget {
//   final _PriorityItem item;
//   final int total;
//   const _PriorityBar({required this.item, required this.total});

//   @override
//   Widget build(BuildContext context) {
//     final pct = total > 0 ? item.value / total : 0.0;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: item.color,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   item.label,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: ThemeColors.unifiedTextPrimary,
//                   ),
//                 ),
//               ],
//             ),
//             Text(
//               '${item.value} (${(pct * 100).toStringAsFixed(1)}%)',
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: ThemeColors.unifiedTextMuted,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 7),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(99),
//           child: LinearProgressIndicator(
//             value: pct,
//             minHeight: 7,
//             backgroundColor: item.color.withOpacity(0.1),
//             valueColor: AlwaysStoppedAnimation<Color>(item.color),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ── Status summary card ───────────────────────────────────────────────────────
// class _StatusSummaryCard extends StatelessWidget {
//   final DashboardStats s;
//   const _StatusSummaryCard({required this.s});

//   @override
//   Widget build(BuildContext context) {
//     final total = s.total;
//     final rows = [
//       _StatusItem(
//         'Open',
//         s.open,
//         total,
//         ThemeColors.unifiedSecondary,
//         ThemeColors.statusOpenBg,
//         ThemeColors.statusOpenFg,
//       ),
//       _StatusItem(
//         'In Progress',
//         s.inProgress,
//         total,
//         ThemeColors.unifiedWarning,
//         ThemeColors.statusProgressBg,
//         ThemeColors.statusProgressFg,
//       ),
//       _StatusItem(
//         'Completed',
//         s.completed,
//         total,
//         ThemeColors.unifiedAccent,
//         ThemeColors.statusDoneBg,
//         ThemeColors.statusDoneFg,
//       ),
//       _StatusItem(
//         'Closed',
//         s.closed,
//         total,
//         ThemeColors.unifiedTextMuted,
//         ThemeColors.statusClosedBg,
//         ThemeColors.statusClosedFg,
//       ),
//     ];

//     return _BaseCard(
//       icon: Icons.donut_small_outlined,
//       title: 'Status Summary',
//       child: Column(children: rows.map((e) => _StatusRow(item: e)).toList()),
//     );
//   }
// }

// class _StatusItem {
//   final String label;
//   final int count, total;
//   final Color dotColor, badgeBg, badgeFg;
//   const _StatusItem(
//     this.label,
//     this.count,
//     this.total,
//     this.dotColor,
//     this.badgeBg,
//     this.badgeFg,
//   );
// }

// class _StatusRow extends StatelessWidget {
//   final _StatusItem item;
//   const _StatusRow({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     final pct = item.total > 0
//         ? ((item.count / item.total) * 100).toStringAsFixed(1)
//         : '0.0';

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       decoration: const BoxDecoration(
//         border: Border(bottom: BorderSide(color: ThemeColors.unifiedBorder)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: item.dotColor,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               item.label,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: ThemeColors.unifiedTextPrimary,
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
//             decoration: BoxDecoration(
//               color: item.badgeBg,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '${item.count}',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: item.badgeFg,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           SizedBox(
//             width: 42,
//             child: Text(
//               '$pct%',
//               textAlign: TextAlign.right,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: ThemeColors.unifiedTextMuted,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Shared base card ──────────────────────────────────────────────────────────
// class _BaseCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final Widget child;
//   const _BaseCard({
//     required this.icon,
//     required this.title,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: ThemeColors.unifiedSurface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Card header strip
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
//             decoration: const BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(color: ThemeColors.unifiedBorder),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 26,
//                   height: 26,
//                   decoration: BoxDecoration(
//                     color: ThemeColors.unifiedPrimary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Icon(
//                     icon,
//                     size: 14,
//                     color: ThemeColors.unifiedPrimary,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                     color: ThemeColors.unifiedTextPrimary,
//                     letterSpacing: -0.1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(padding: const EdgeInsets.all(16), child: child),
//         ],
//       ),
//     );
//   }
// }
