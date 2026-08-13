import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

/// Shared visual building blocks used across the redesigned Projects UI.
/// Keeping these in one place gives every screen a consistent look
/// (soft cards, avatar chips, icon-badged section headers, pill badges)
/// without touching any Bloc/event/model logic.

const List<Color> kAvatarPalette = [
  Color(0xFF6C5CE7),
  Color(0xFF00B894),
  Color(0xFFE17055),
  Color(0xFF0984E3),
  Color(0xFFE84393),
  Color(0xFFFDA7DF),
  Color(0xFF10AC84),
  Color(0xFFF9A826),
];

Color colorForName(String name) {
  if (name.isEmpty) return kAvatarPalette.first;
  final code = name.codeUnits.fold<int>(0, (a, b) => a + b);
  return kAvatarPalette[code % kAvatarPalette.length];
}

String initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length >= 2 ? 2 : 1)
        .toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

/// A small circular avatar with initials, colored deterministically by name.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;
  const InitialsAvatar({super.key, required this.name, this.size = 30});

  @override
  Widget build(BuildContext context) {
    final color = colorForName(name);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        initialsForName(name),
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Consistent card container: soft shadow, subtle border, rounded corners.
/// Interactive cards (with [onTap]) gently lift + tint on hover — a web-native touch.
class SoftCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 18,
  });

  @override
  State<SoftCard> createState() => _SoftCardState();
}

class _SoftCardState extends State<SoftCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final borderColor = _hovered
        ? ThemeColors.unifiedPrimary.withValues(alpha: 0.35)
        : ThemeColors.unifiedBorder;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: _hovered
                ? ThemeColors.unifiedPrimary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.035),
            blurRadius: _hovered ? 22 : 14,
            offset: Offset(0, _hovered ? 10 : 6),
          ),
        ],
      ),
      child: widget.child,
    );

    if (!interactive) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(widget.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.radius),
          onTap: widget.onTap,
          child: content,
        ),
      ),
    );
  }
}

/// Section header used above lists: icon badge + title + optional trailing widget.
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ThemeColors.unifiedPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: ThemeColors.unifiedPrimary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
        ),
        // ignore: use_null_aware_elements
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Small rounded pill with a leading dot — used for status/priority badges.
class DotPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final double fontSize;
  const DotPill({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded, slightly thicker progress bar with a soft track color.
class SoftProgressBar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double height;
  const SoftProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 7,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: ThemeColors.unifiedInputBg,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// A friendly empty-state block: icon in a soft circle + message + optional hint.
class FriendlyEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? hint;
  const FriendlyEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: ThemeColors.unifiedPrimary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: ThemeColors.unifiedPrimary),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Max content width for project pages (list / detail) on wide screens.
const double kProjectsPageMaxWidth = 1240;

/// Max content width for project forms (create / edit / add-task).
const double kProjectsFormMaxWidth = 760;

/// Centers content and caps its width so desktop screens don't stretch
/// cards/forms edge-to-edge. Passes the remaining width through to [child].
class ResponsivePageContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ResponsivePageContainer({
    super.key,
    required this.child,
    this.maxWidth = kProjectsPageMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// A responsive wrap-style grid for cards.
/// 1 column on narrow screens, 2 on tablets, up to [maxColumns] on desktop.
/// Children keep their natural height; each run aligns to its tallest card.
class ResponsiveCardGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int maxColumns;
  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.spacing = 14,
    this.runSpacing = 14,
    this.maxColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int columns;
        if (width >= 1040) {
          columns = maxColumns;
        } else if (width >= 640) {
          columns = maxColumns > 2 ? 2 : 1;
        } else {
          columns = 1;
        }
        final itemWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

/// Shared rounded input decoration for the project module forms.
InputDecoration projectFieldDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: ThemeColors.unifiedSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: ThemeColors.unifiedPrimary,
        width: 1.5,
      ),
    ),
  );
}

/// Shared primary submit button style for the project module forms.
ButtonStyle projectPrimaryButtonStyle() => ElevatedButton.styleFrom(
  backgroundColor: ThemeColors.unifiedPrimary,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(vertical: 15),
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
);

/// Responsive horizontal gutter for a scroll page — roomier on desktop.
EdgeInsets projectPagePadding(double width) {
  if (width >= 1024) return const EdgeInsets.fromLTRB(28, 24, 28, 110);
  if (width >= 640) return const EdgeInsets.fromLTRB(22, 18, 22, 96);
  return const EdgeInsets.fromLTRB(16, 12, 16, 96);
}

/// Responsive horizontal gutter for a form page.
EdgeInsets projectFormPadding(double width) {
  if (width >= 640) return const EdgeInsets.fromLTRB(24, 22, 24, 40);
  return const EdgeInsets.fromLTRB(16, 18, 16, 32);
}
