import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/name_by_id.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class ManagerAnalyticsScreen extends StatefulWidget {
  final UserModel? user;
  const ManagerAnalyticsScreen({super.key, this.user});

  @override
  State<ManagerAnalyticsScreen> createState() => _ManagerAnalyticsScreenState();
}

class _ManagerAnalyticsScreenState extends State<ManagerAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      context.read<DashboardBloc>().add(LoadManagerAnalytics(widget.user!.departmentId));
    }
  }

  String? _getDepartmentName() {
    if (widget.user == null) return null;
    return NameById.getNameById<Departments>(
      id: widget.user!.departmentId,
      items: departments,
      idSelector: (e) => e.id,
      nameSelector: (e) => e.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is AnalyticsLoading || state is DashboardLoaded) {
          return _buildScaffold(child: const _LoadingView());
        }
        if (state is AnalyticsError) {
          return _buildScaffold(
            child: _ErrorView(message: state.message, onRetry: () {
              if (widget.user != null) {
                context.read<DashboardBloc>().add(LoadManagerAnalytics(widget.user!.departmentId));
              }
            }),
          );
        }
        if (state is! ManagerAnalyticsLoaded) {
          return _buildScaffold(child: const SizedBox.shrink());
        }
        return _buildScaffold(
          child: _AnalyticsBody(
            stats: state.stats,
            departmentName: _getDepartmentName(),
          ),
        );
      },
    );
  }

  Widget _buildScaffold({required Widget child}) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: _AnalyticsAppBar(
        departmentName: _getDepartmentName(),
        onBack: () => context.pop(),
      ),
      body: child,
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────
class _AnalyticsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? departmentName;
  final VoidCallback onBack;

  const _AnalyticsAppBar({this.departmentName, required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeColors.unifiedSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: ThemeColors.unifiedBorder),
      ),
      leading: GestureDetector(
        onTap: onBack,
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ThemeColors.unifiedBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: ThemeColors.unifiedTextPrimary),
        ),
      ),
      title: const Text(
        'Department Analytics',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: ThemeColors.unifiedTextPrimary,
          letterSpacing: -0.2,
        ),
      ),
      actions: [
        if (departmentName != null)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                ThemeColors.unifiedGradStart,
                ThemeColors.unifiedGradEnd,
              ]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              departmentName!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: ThemeColors.unifiedDanger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 32, color: ThemeColors.unifiedDanger),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: ThemeColors.unifiedTextMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.unifiedPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main Body ─────────────────────────────────────────────────────────────────
class _AnalyticsBody extends StatelessWidget {
  final dynamic stats; // replace with your actual ManagerAnalyticsStats type
  final String? departmentName;

  const _AnalyticsBody({required this.stats, this.departmentName});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 700;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 28 : 16).copyWith(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero
          _HeroCard(departmentName: departmentName),
          const SizedBox(height: 20),

          // Section label + metric grid
          const _SectionLabel('Overview'),
          const SizedBox(height: 10),
          _MetricGrid(stats: stats, isWide: isWide),
          const SizedBox(height: 20),

          // Priority + Status — side by side on wide
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _PriorityCard(stats: stats)),
                    const SizedBox(width: 20),
                    Expanded(child: _StatusCard(stats: stats)),
                  ],
                )
              : Column(
                  children: [
                    _PriorityCard(stats: stats),
                    const SizedBox(height: 20),
                    _StatusCard(stats: stats),
                  ],
                ),
          const SizedBox(height: 20),

          // Key Metrics
          _KeyMetricsCard(stats: stats),
        ],
      ),
    );
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final String? departmentName;
  const _HeroCard({this.departmentName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Gradient top bar
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                ThemeColors.unifiedGradStart,
                ThemeColors.unifiedGradEnd,
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeColors.unifiedGradStart.withOpacity(0.15),
                        ThemeColors.unifiedGradEnd.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dashboard_rounded,
                      color: ThemeColors.unifiedPrimary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analytics for ${departmentName ?? "Your Department"}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedTextPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Real-time overview of your department's ticket metrics",
                        style: TextStyle(
                          fontSize: 13,
                          color: ThemeColors.unifiedTextMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: ThemeColors.unifiedTextMuted,
      ),
    );
  }
}

// ── Metric Grid ───────────────────────────────────────────────────────────────
class _MetricGrid extends StatelessWidget {
  final dynamic stats;
  final bool isWide;
  const _MetricGrid({required this.stats, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MetricItem('Total Tickets', '${stats.total}',   ThemeColors.unifiedPrimary,   Icons.confirmation_number_outlined),
      _MetricItem('Open',          '${stats.open}',    ThemeColors.unifiedSecondary,  Icons.radio_button_unchecked_rounded),
      _MetricItem('In Progress',   '${stats.inProgress}', ThemeColors.unifiedWarning, Icons.autorenew_rounded),
      _MetricItem('Completed',     '${stats.completed}',  ThemeColors.unifiedAccent,  Icons.check_circle_outline_rounded),
      _MetricItem('Closed',        '${stats.closed}',  ThemeColors.unifiedTextMuted,  Icons.cancel_outlined),
      _MetricItem('Overdue',       '${stats.overdue}', ThemeColors.unifiedDanger,     Icons.warning_amber_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: isWide ? 1.8 : 2.1,
      ),
      itemBuilder: (_, i) => _MetricCard(item: items[i]),
    );
  }
}

class _MetricItem {
  final String label, value;
  final Color color;
  final IconData icon;
  const _MetricItem(this.label, this.value, this.color, this.icon);
}

class _MetricCard extends StatelessWidget {
  final _MetricItem item;
  const _MetricCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Colored top edge
          Container(
            height: 3,
            color: item.color.withOpacity(0.6),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(item.icon, size: 18, color: item.color),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedTextPrimary,
                          letterSpacing: -1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.unifiedTextMuted,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Priority Card ─────────────────────────────────────────────────────────────
class _PriorityCard extends StatelessWidget {
  final dynamic stats;
  const _PriorityCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.total as int;
    final items = [
      _PriorityItem('Urgent',       stats.urgent as int,                                    ThemeColors.unifiedDanger,      const Color(0xFFEF4444)),
      _PriorityItem('High',         stats.highPriority as int,                              const Color(0xFFEA580C),         const Color(0xFFEA580C)),
      _PriorityItem('Medium & Low', total - (stats.urgent as int) - (stats.highPriority as int), ThemeColors.unifiedPrimary, ThemeColors.unifiedPrimary),
    ];

    return _BaseCard(
      title: 'Priority Distribution',
      child: Column(
        children: items
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PriorityBar(item: e, total: total),
                ))
            .toList(),
      ),
    );
  }
}

class _PriorityItem {
  final String label;
  final int value;
  final Color color, trackColor;
  const _PriorityItem(this.label, this.value, this.color, this.trackColor);
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
            Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: item.color, shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(item.label,
                  style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextPrimary,
                  )),
            ]),
            Text(
              '${item.value} (${(pct * 100).toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: item.color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(item.color),
          ),
        ),
      ],
    );
  }
}

// ── Status Card ───────────────────────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final dynamic stats;
  const _StatusCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.total as int;
    final rows = [
      _StatusItem('Open',        stats.open as int,        total, ThemeColors.unifiedSecondary, ThemeColors.statusOpenBg,   ThemeColors.statusOpenFg),
      _StatusItem('In Progress', stats.inProgress as int,  total, ThemeColors.unifiedWarning,   ThemeColors.statusProgressBg, ThemeColors.statusProgressFg),
      _StatusItem('Completed',   stats.completed as int,   total, ThemeColors.unifiedAccent,    ThemeColors.statusDoneBg,   ThemeColors.statusDoneFg),
      _StatusItem('Closed',      stats.closed as int,      total, ThemeColors.unifiedTextMuted, ThemeColors.statusClosedBg, ThemeColors.statusClosedFg),
    ];

    return _BaseCard(
      title: 'Status Summary',
      child: Column(
        children: rows.map((e) => _StatusRow(item: e)).toList(),
      ),
    );
  }
}

class _StatusItem {
  final String label;
  final int count, total;
  final Color dotColor, badgeBg, badgeFg;
  const _StatusItem(this.label, this.count, this.total,
      this.dotColor, this.badgeBg, this.badgeFg);
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
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeColors.unifiedBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: item.dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.label,
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: ThemeColors.unifiedTextPrimary,
                )),
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
                fontSize: 11, fontWeight: FontWeight.w700, color: item.badgeFg,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            child: Text(
              '$pct%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Key Metrics Card ──────────────────────────────────────────────────────────
class _KeyMetricsCard extends StatelessWidget {
  final dynamic stats;
  const _KeyMetricsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.total as int;
    final completionRate =
        '${((stats.completed as int) / (total > 0 ? total : 1) * 100).toStringAsFixed(1)}%';

    final rows = [
      _KeyItem('Completion Rate',  completionRate,          ThemeColors.unifiedAccent,   Icons.check_circle_outline_rounded),
      _KeyItem('Critical Issues',  '${stats.urgent}',       ThemeColors.unifiedDanger,   Icons.warning_amber_rounded),
      _KeyItem('Overdue Tickets',  '${stats.overdue}',      ThemeColors.unifiedWarning,  Icons.access_time_rounded),
    ];

    return _BaseCard(
      title: 'Key Metrics',
      child: Column(
        children: rows.map((e) => _KeyMetricRow(item: e)).toList(),
      ),
    );
  }
}

class _KeyItem {
  final String label, value;
  final Color color;
  final IconData icon;
  const _KeyItem(this.label, this.value, this.color, this.icon);
}

class _KeyMetricRow extends StatelessWidget {
  final _KeyItem item;
  const _KeyMetricRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeColors.unifiedBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.label,
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: ThemeColors.unifiedTextPrimary,
                )),
          ),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: item.color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared base card ──────────────────────────────────────────────────────────
class _BaseCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _BaseCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextPrimary,
                letterSpacing: -0.1,
              )),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}