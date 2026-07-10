import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';

class SearchBarWidget extends StatelessWidget {
  final DashboardLoaded state;
  const SearchBarWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(
          bottom: BorderSide(color: ThemeColors.unifiedBorder, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: ConstStrings.searchHint,
          hintStyle: TextStyle(
            color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.6),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: ThemeColors.unifiedTextMuted,
          ),
          filled: true,
          fillColor: ThemeColors.unifiedBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ThemeColors.unifiedBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: ThemeColors.unifiedPrimary,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (v) => context.read<DashboardBloc>().add(
          FilterTickets(
            search: v,
            status: state.filterStatus,
            priority: state.filterPriority,
            teamOnly: state.filterTeam,
          ),
        ),
      ),
    );
  }
}
