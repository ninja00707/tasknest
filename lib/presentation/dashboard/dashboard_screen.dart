import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/dashboard_layout.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/crud/update/update_dialog.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel user;
  final Widget? child;
  const DashboardScreen({super.key, required this.user, this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      listener: (context, authState) {
        if (authState is AuthUnauthenticated) {
          context.read<DashboardBloc>().add(ResetDashboardEvent());
        }
      },
      child: BlocListener<DashboardBloc, DashboardState>(
        listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
        listener: _onStateChanged,
        child: BlocBuilder<DashboardBloc, DashboardState>(
          buildWhen: (prev, curr) {
            if (prev is DashboardInitial && curr is DashboardLoading) return true;
            if (prev is DashboardLoading && curr is DashboardLoaded) return true;
            if (curr is DashboardError) return true;
            if (curr is DashboardLoaded && prev is! DashboardLoaded) return true;
            return false;
          },
          builder: (context, state) {
            if (state is DashboardInitial || state is DashboardLoading) {
              return const Scaffold(
                backgroundColor: ThemeColors.unifiedBackground,
                body: Center(
                  child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
                ),
              );
            }
            if (state is DashboardError) {
              return Scaffold(
                backgroundColor: ThemeColors.unifiedBackground,
                body: Center(child: Text(state.message)),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 768;
                context.read<DashboardBloc>().add(UpdateScreenSize(isWide));
                return DashboardLayout(
                  user: user,
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, DashboardState state) {
    if (state is DashboardActionSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ThemeColors.unifiedPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(state.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }
    if (state is DashboardActionError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ThemeColors.unifiedDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(child: Text(state.message, style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      );
    }
    if (state is DashboardLoaded && state.shouldShowUpdateDialog) {
      context.read<DashboardBloc>().add(MarkVersionSeen());
      showUpdateDialog(context);
    }
  }
}
