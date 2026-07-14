import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/hero_header.dart';
import 'package:tasknest/presentation/dashboard/widgets/role_body.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';

class DashboardView extends StatefulWidget {
  final DashboardLoaded state;
  final UserModel user;
  const DashboardView({super.key, required this.state, required this.user});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final bloc = context.read<DashboardBloc>();
      final state = bloc.state;
      DashboardLoaded? loaded;
      if (state is DashboardLoaded) {
        loaded = state;
      } else if (state is DashboardActionSuccess) {
        loaded = state.previousState;
      } else if (state is DashboardActionError) {
        loaded = state.previousState;
      } else if (state is TicketDetailLoaded) {
        loaded = state.previousState;
      }
      if (loaded != null && loaded.currentPage < loaded.totalPages) {
        bloc.add(LoadMoreTickets());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColors.unifiedBackground,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroHeader(
              user: widget.user,
              isWide: widget.state.isWide,
              departmentName: widget.state.departmentName,
              roleName: widget.state.roleName,
              companyName: widget.state.companyName,
              greeting: widget.state.greeting,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.fromLTRB(
                widget.state.isWide ? 28 : 16,
                widget.state.isWide ? 20 : 14,
                widget.state.isWide ? 28 : 16,
                24,
              ),
              child: RoleBody(state: widget.state, user: widget.user),
            ),
          ],
        ),
      ),
    );
  }
}
