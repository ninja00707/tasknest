import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  COMMON TOP BAR
//  Usage:
//    appBar: AppTopBar.build(
//      context,
//      user: user,
//      title: 'Dashboard',
//      subtitle: 'Overview',         // optional
//      showBack: false,              // optional — defaults to false
//      showRefresh: true,            // optional — defaults to false
//      actions: [],                  // optional — extra action widgets
//    ),
// ══════════════════════════════════════════════════════════════════════════════
class AppTopBar {
  AppTopBar._();

  static PreferredSizeWidget build(
    BuildContext context, {
    required UserModel user,
    required String title,
    String? subtitle,
    bool showBack = false,
    bool showRefresh = false,
    List<Widget>? actions,
  }) {
    return _AppTopBar(
      user: user,
      title: title,
      subtitle: subtitle,
      showBack: showBack,
      showRefresh: showRefresh,
      extraActions: actions ?? [],
    );
  }
}

class _AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel user;
  final String title;
  final String? subtitle;
  final bool showBack;
  final bool showRefresh;
  final List<Widget> extraActions;

  const _AppTopBar({
    required this.user,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.showRefresh = false,
    this.extraActions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 768;

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(
          bottom: BorderSide(color: ThemeColors.unifiedBorder, width: 1.2),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 16),
      child: Row(
        children: [
          // ── Back button ──────────────────────────────────────────────
          if (showBack) ...[
            _TopBarIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              color: ThemeColors.unifiedTextPrimary,
              onTap: () => context.pop(),
            ),
            const SizedBox(width: 8),
          ],

          // ── Logo / brand mark ────────────────────────────────────────
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  ThemeColors.unifiedGradStart,
                  ThemeColors.unifiedGradEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Text(
              'TN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Title + subtitle ─────────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Actions ──────────────────────────────────────────────────
          ...extraActions,

          if (extraActions.isNotEmpty) const SizedBox(width: 8),

          // ── Refresh (optional) ───────────────────────────────────────
          if (showRefresh) ...[
            _TopBarIconButton(
              icon: Icons.refresh_rounded,
              color: ThemeColors.unifiedPrimary,
              onTap: () => context.read<DashboardBloc>().add(LoadDashboard()),
              tooltip: 'Refresh',
            ),
            const SizedBox(width: 8),
          ],

          // ── User avatar pill ─────────────────────────────────────────
          if (isWide) ...[
            _UserPill(user: user),
            const SizedBox(width: 8),
          ] else ...[
            // Compact avatar on mobile
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ThemeColors.unifiedPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: ThemeColors.unifiedPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // ── Logout ───────────────────────────────────────────────────
          _TopBarIconButton(
            icon: Icons.power_settings_new_rounded,
            color: ThemeColors.unifiedDanger,
            onTap: () {
              context.read<AuthBloc>().add(LogoutEvent());
              context.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}

// ── User pill (wide screens) ──────────────────────────────────────────────────
class _UserPill extends StatelessWidget {
  final UserModel user;
  const _UserPill({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedPrimary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeColors.unifiedPrimary.withOpacity(0.15),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: ThemeColors.unifiedPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: ThemeColors.unifiedPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            user.name.split(' ').first, // first name only
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ThemeColors.unifiedPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable icon button for top bar ──────────────────────────────────────────
class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  const _TopBarIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.18), width: 1.2),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
