import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/common_listview_builder.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/core/routes/ticket_type_grid_args.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';

class TicketTypeSectionScreen extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;

  const TicketTypeSectionScreen({
    super.key,
    required this.state,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;

    final types = [
      _TypeData(
        icon: Icons.article_rounded,
        label: ConstStrings.standardLabel,
        subtitle: ConstStrings.singleDeptTickets,
        accentColor: ThemeColors.unifiedPrimary,
        gradientColors: [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
        count: state.tickets.where((t) => t.isStandardTicket).length,
        tickets: state.tickets.where((t) => t.isStandardTicket).toList(),
        title: ConstStrings.standardTickets,
        patternIcon: Icons.layers_rounded,
      ),
      _TypeData(
        icon: Icons.account_tree_rounded,
        label: 'Sub',
        subtitle: ConstStrings.childSubTickets,
        accentColor: const Color(0xFFD97706),
        gradientColors: [const Color(0xFFD97706), const Color(0xFF92400E)],
        count: state.tickets.where((t) => t.isSubTicket).length,
        tickets: state.tickets.where((t) => t.isSubTicket).toList(),
        title: ConstStrings.subTicketsTitle,
        patternIcon: Icons.share_rounded,
      ),
      _TypeData(
        icon: Icons.hub_rounded,
        label: 'Multi',
        subtitle: ConstStrings.multiDeptTasks,
        accentColor: const Color(0xFF7C3AED),
        gradientColors: [const Color(0xFF7C3AED), const Color(0xFF4C1D95)],
        count: state.tickets.where((t) => t.isMultiTaskTicket).length,
        tickets: state.tickets.where((t) => t.isMultiTaskTicket).toList(),
        title: ConstStrings.multiTaskTickets,
        patternIcon: Icons.device_hub_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // ── Section header ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  size: 15,
                  color: ThemeColors.unifiedPrimary,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                ConstStrings.ticketTypes,
                style: AppTextStyles.sectionHeader,
              ),
              const Spacer(),
              Text(
                '${state.tickets.length} total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Cards ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: types
                      .map(
                        (t) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: types.indexOf(t) < types.length - 1
                                  ? 12
                                  : 0,
                            ),
                            child: _TypeCard(data: t, user: user),
                          ),
                        ),
                      )
                      .toList(),
                )
              : CommonListViewBuilder(
                  physics: const NeverScrollableScrollPhysics(),
                  items: types,
                  itemBuilder: (context, t, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TypeCard(
                      data: t,
                      user: user,
                      horizontal: true,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _TypeData {
  final IconData icon, patternIcon;
  final String label, subtitle, title;
  final Color accentColor;
  final List<Color> gradientColors;
  final int count;
  final List<TicketModel> tickets;

  const _TypeData({
    required this.icon,
    required this.patternIcon,
    required this.label,
    required this.subtitle,
    required this.title,
    required this.accentColor,
    required this.gradientColors,
    required this.count,
    required this.tickets,
  });
}

// ── Type card ─────────────────────────────────────────────────────────────────
class _TypeCard extends StatefulWidget {
  final _TypeData data;
  final UserModel user;
  final bool horizontal;

  const _TypeCard({
    required this.data,
    required this.user,
    this.horizontal = false,
  });

  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.reverse();
  void _onTapUp(_) => _ctrl.forward();
  void _onTapCancel() => _ctrl.forward();

  void _navigate() {
    context.push(
      RouteNames.ticketTypeGrid,
      extra: TicketTypeGridArgs(
        tickets: widget.data.tickets,
        title: widget.data.title,
        user: widget.user,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _navigate,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: widget.horizontal
            ? _HorizontalCard(data: d)
            : _VerticalCard(data: d),
      ),
    );
  }
}

// ── Vertical card (wide screens) ──────────────────────────────────────────────
class _VerticalCard extends StatelessWidget {
  final _TypeData data;
  const _VerticalCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: data.accentColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // ── Gradient hero section ─────────────────────────────
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Decorative background icon
                Positioned(
                  right: -16,
                  top: -16,
                  child: Icon(
                    data.patternIcon,
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                Positioned(
                  left: -10,
                  bottom: -20,
                  child: Icon(
                    data.icon,
                    size: 90,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                // Count badge top-right
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${data.count}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                // Main icon
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(data.icon, size: 30, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ── Info section ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: data.accentColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: data.accentColor.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeColors.unifiedTextMuted,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar showing count vs total
                _CountBar(count: data.count, color: data.accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Horizontal card (narrow screens) ─────────────────────────────────────────
class _HorizontalCard extends StatelessWidget {
  final _TypeData data;
  const _HorizontalCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: data.accentColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            // ── Left gradient strip ─────────────────────────────
            Container(
              width: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: data.gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    data.patternIcon,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(data.icon, size: 22, color: Colors.white),
                  ),
                ],
              ),
            ),

            // ── Right content ───────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data.label,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: data.accentColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            data.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ThemeColors.unifiedTextMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _CountBar(count: data.count, color: data.accentColor),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Count pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: data.accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: data.accentColor.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${data.count}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: data.accentColor,
                              letterSpacing: -0.5,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ConstStrings.ticketsLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: data.accentColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: data.accentColor.withValues(alpha: 0.5),
                      size: 20,
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

// ── Count bar ─────────────────────────────────────────────────────────────────
class _CountBar extends StatelessWidget {
  final int count;
  final Color color;

  const _CountBar({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: count > 0 ? (count / (count + 5)).clamp(0.1, 1.0) : 0.05,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count tickets',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
