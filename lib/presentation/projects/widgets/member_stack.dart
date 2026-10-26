import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

/// Trello-style overlapping avatar stack for the members of a task.
///
/// Falls back to a single avatar built from [fallbackName] when the task has
/// no members yet (the legacy single assignee), so a card never renders empty.
class MemberStack extends StatelessWidget {
  final List<TicketMemberModel> members;
  final double size;
  final int max;
  final String fallbackName;
  final bool showFallbackWhenEmpty;

  const MemberStack({
    super.key,
    required this.members,
    this.size = 26,
    this.max = 4,
    this.fallbackName = '',
    this.showFallbackWhenEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      if (!showFallbackWhenEmpty || fallbackName.isEmpty) {
        return const SizedBox.shrink();
      }
      return InitialsAvatar(name: fallbackName, size: size);
    }

    final shown = members.length > max ? members.sublist(0, max) : members;
    final extra = members.length - shown.length;
    final names = members.map((m) => m.name).join(', ');

    // Overlap is done with a Stack (Transform/Positioned) — negative margins
    // and negative padding both trip framework asserts.
    final step = size * 0.66;
    final count = shown.length + (extra > 0 ? 1 : 0);
    final totalWidth = size + (count - 1) * step;

    return Tooltip(
      message: names,
      child: SizedBox(
        width: totalWidth,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < shown.length; i++)
              Positioned(
                left: i * step,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: InitialsAvatar(name: shown[i].name, size: size),
                ),
              ),
            if (extra > 0)
              Positioned(
                left: shown.length * step,
                top: 0,
                child: Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      fontSize: size * 0.34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
