import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

/// ============================================================================
/// TaskNest — Projects Design System ("The Ledger")
/// ----------------------------------------------------------------------------
/// A single, editorial visual language shared by every screen in the Projects
/// module: soft lifted cards, gradient icon badges, radial progress rings and
/// a numbered "chapter" timeline for storytelling detail pages.
///
/// Every symbol that existed before keeps its exact name and signature, so
/// screens that aren't being redesigned in this pass (create/edit/add-task,
/// team sheets) keep compiling and simply inherit the refreshed look.
/// ============================================================================

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
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Text(
        initialsForName(name),
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// A rounded gradient-tinted icon tile, reused for chapter markers, hero
/// badges and card watermarks throughout the module.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final double iconScale;
  final Gradient? gradient;
  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconScale = 0.48,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gradient == null ? color.withValues(alpha: 0.14) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: gradient == null
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.32),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Icon(
        icon,
        size: size * iconScale,
        color: gradient == null ? color : Colors.white,
      ),
    );
  }
}

/// Consistent card container: soft shadow, subtle border, rounded corners.
/// Interactive cards (with [onTap]) gently lift + tint on hover — a web-native
/// touch that reads as intentional rather than default Material.
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
        ? ThemeColors.unifiedPrimary.withValues(alpha: 0.38)
        : ThemeColors.unifiedBorder;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: widget.padding,
      transform: _hovered
          ? Matrix4.translationValues(0.0, -2.0, 0.0)
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: _hovered
                ? ThemeColors.unifiedPrimary.withValues(alpha: 0.14)
                : Colors.black.withValues(alpha: 0.035),
            blurRadius: _hovered ? 26 : 14,
            offset: Offset(0, _hovered ? 12 : 6),
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

/// Section header used above lists: icon badge + title + optional trailing.
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
        IconBadge(
          icon: icon,
          size: 32,
          color: ThemeColors.unifiedPrimary,
          iconScale: 0.5,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: ThemeColors.unifiedTextPrimary,
              letterSpacing: -0.1,
            ),
          ),
        ),
        // ignore: use_null_aware_elements
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// An uppercase, letter-spaced micro-label used as a narrative "eyebrow"
/// above titles — the signature typographic touch of the module.
class Eyebrow extends StatelessWidget {
  final String text;
  final Color color;
  const Eyebrow({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: color,
      ),
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

/// Dynamic Priority Pill that maps strings like 'urgent', 'high', 'medium', 'low'
/// to brand semantic colors.
class PriorityBadge extends StatelessWidget {
  final String priority;
  final double fontSize;
  const PriorityBadge({super.key, required this.priority, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (priority.toLowerCase()) {
      'urgent' => (
        ThemeColors.priorityUrgentBg,
        ThemeColors.priorityUrgentFg,
        'URGENT',
      ),
      'high' => (
        ThemeColors.priorityHighBg,
        ThemeColors.priorityHighFg,
        'HIGH',
      ),
      'low' => (ThemeColors.priorityLowBg, ThemeColors.priorityLowFg, 'LOW'),
      _ => (ThemeColors.priorityMedBg, ThemeColors.priorityMedFg, 'MEDIUM'),
    };
    return DotPill(label: label, bg: bg, fg: fg, fontSize: fontSize);
  }
}

/// Dynamic Status Pill that maps project / task statuses to semantic colors.
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  const StatusBadge({super.key, required this.status, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status.toLowerCase()) {
      'completed' || 'done' => (
        ThemeColors.statusDoneBg,
        ThemeColors.statusDoneFg,
        'Done',
      ),
      'in_progress' || 'active' => (
        ThemeColors.statusProgressBg,
        ThemeColors.statusProgressFg,
        'In Progress',
      ),
      'closed' => (
        ThemeColors.statusClosedBg,
        ThemeColors.statusClosedFg,
        'Closed',
      ),
      'cancelled' => (
        ThemeColors.priorityUrgentBg,
        ThemeColors.priorityUrgentFg,
        'Cancelled',
      ),
      'on_hold' => (
        ThemeColors.priorityMedBg,
        ThemeColors.priorityMedFg,
        'On Hold',
      ),
      _ => (ThemeColors.statusOpenBg, ThemeColors.statusOpenFg, 'Planned'),
    };
    return DotPill(label: label, bg: bg, fg: fg, fontSize: fontSize);
  }
}

/// Overlapping avatar stack with a "+N" overflow chip.
class AvatarStack extends StatelessWidget {
  final List<String> names;
  final int max;
  final double size;
  final double overlap;

  const AvatarStack({
    super.key,
    required this.names,
    this.max = 4,
    this.size = 28,
    this.overlap = 18,
  });

  @override
  Widget build(BuildContext context) {
    final visible = names.take(max).toList();
    final overflow = names.length - visible.length;
    final totalWidth = (visible.length * overlap) + (size - overlap) + (overflow > 0 ? 28.0 : 0.0);

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ThemeColors.unifiedSurface, width: 2),
                ),
                child: InitialsAvatar(name: visible[i], size: size - 2),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: visible.length * overlap,
              child: Container(
                width: size - 2,
                height: size - 2,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedInputBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: ThemeColors.unifiedSurface, width: 2),
                ),
                child: Text(
                  '+$overflow',
                  style: TextStyle(
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Modern KPI Stat Card for dashboard grids and project overviews.
class StatMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color accentColor;
  final VoidCallback? onTap;

  const StatMetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.accentColor = ThemeColors.unifiedPrimary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.unifiedTextMuted,
                  letterSpacing: 0.8,
                ),
              ),
              IconBadge(
                icon: icon,
                size: 34,
                color: accentColor,
                iconScale: 0.5,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: ThemeColors.unifiedTextPrimary,
              letterSpacing: -0.8,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
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

/// A radial "story" progress ring — the module's signature replacement for
/// plain linear bars wherever progress is the hero of the moment.
class ProgressRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  final Widget? centerChild;
  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    required this.trackColor,
    this.size = 88,
    this.strokeWidth = 8,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0, 1),
          color: color,
          trackColor: trackColor,
          strokeWidth: strokeWidth,
        ),
        child: centerChild == null ? null : Center(child: centerChild),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  _RingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (value <= 0) return;
    final fgPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [color.withValues(alpha: 0.55), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * math.pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}

/// A friendly empty-state block: icon in a soft circle + message + hint.
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
          IconBadge(
            icon: icon,
            size: 64,
            color: ThemeColors.unifiedPrimary,
            iconScale: 0.42,
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

/// ----------------------------------------------------------------------------
/// Story timeline: the numbered "chapter" spine used to turn the project
/// detail page into a narrative rather than a stack of anonymous cards.
/// ----------------------------------------------------------------------------

class StoryChapter {
  final IconData icon;
  final String label;
  final String title;
  final String? subtitle;
  final Widget child;
  const StoryChapter({
    required this.icon,
    required this.label,
    required this.title,
    this.subtitle,
    required this.child,
  });
}

class StoryTimeline extends StatelessWidget {
  final List<StoryChapter> chapters;
  const StoryTimeline({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < chapters.length; i++)
          _ChapterBlock(
            index: i + 1,
            chapter: chapters[i],
            isLast: i == chapters.length - 1,
          ),
      ],
    );
  }
}

class _ChapterBlock extends StatelessWidget {
  final int index;
  final StoryChapter chapter;
  final bool isLast;
  const _ChapterBlock({
    required this.index,
    required this.chapter,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(
              icon: chapter.icon,
              size: 42,
              color: ThemeColors.unifiedPrimary,
              iconScale: 0.44,
              gradient: LinearGradient(
                colors: [
                  ThemeColors.unifiedPrimary,
                  ThemeColors.unifiedAccent,
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ThemeColors.unifiedPrimary.withValues(alpha: 0.35),
                      ThemeColors.unifiedBorder,
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 4 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(
                  text:
                      'Chapter ${index.toString().padLeft(2, '0')} · ${chapter.label}',
                  color: ThemeColors.unifiedPrimary,
                ),
                const SizedBox(height: 5),
                Text(
                  chapter.title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                if (chapter.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    chapter.subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                chapter.child,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Max content width for project pages (list / detail) on wide screens.
const double kProjectsPageMaxWidth = 1240;

/// Max content width for project forms (create / edit / add-task).
const double kProjectsFormMaxWidth = 760;

/// Centers content and caps its width so desktop screens don't stretch
/// cards/forms edge-to-edge.
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
    fillColor: ThemeColors.unifiedInputBg.withValues(alpha: 0.5),
    labelStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      color: ThemeColors.unifiedTextMuted,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: ThemeColors.unifiedPrimary,
        width: 1.6,
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
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
);

/// Responsive horizontal gutter for a scroll page — roomier on desktop.
EdgeInsets projectPagePadding(double width) {
  if (width >= 1024) return const EdgeInsets.fromLTRB(32, 26, 32, 110);
  if (width >= 640) return const EdgeInsets.fromLTRB(22, 18, 22, 96);
  return const EdgeInsets.fromLTRB(16, 12, 16, 96);
}

/// Responsive horizontal gutter for a form page.
EdgeInsets projectFormPadding(double width) {
  if (width >= 640) return const EdgeInsets.fromLTRB(24, 22, 24, 40);
  return const EdgeInsets.fromLTRB(16, 18, 16, 32);
}
