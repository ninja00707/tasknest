import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/core/theme/alert_box.dart';
import 'package:tasknest/core/theme/color.dart';

import 'package:tasknest/presentation/login/bloc/auth_view_mode.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';

import 'package:tasknest/presentation/login/widget/footer.dart';
import 'package:tasknest/presentation/login/widget/left_panel.dart';
import 'package:tasknest/presentation/login/widget/login_card.dart';
import 'package:tasknest/presentation/login/widget/forgot_password_card.dart';
import 'package:tasknest/presentation/login/widget/first_login_reset_card.dart';
import 'package:tasknest/presentation/login/widget/top_bar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          AppAlertDialog.show(
            context: context,
            title: 'Success',
            message: 'Login Success',
            isError: false,
          );
          context.go(RouteNames.dashboard);
        }

        if (state is AuthMustResetPassword) {
          context.read<AuthBloc>().add(
            SwitchModeEvent(mode: AuthViewMode.firstLoginReset),
          );
        }

        if (state is AuthError) {
          final isPending = state.message.toLowerCase().contains('pending');
          AppAlertDialog.show(
            context: context,
            title: isPending
                ? 'Account Pending Approval'
                : 'Authentication Failed',
            message: state.message,
            isError: true,
          );
        }

        if (state is AuthFirstLoginResetError) {
          AppAlertDialog.show(
            context: context,
            title: 'Password Reset Failed',
            message: state.message,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        Widget card;
        switch (state.currentMode) {
          case AuthViewMode.forgotPassword:
            card = ForgotPasswordCard(
              onNavigateToLogin: () => context.read<AuthBloc>().add(
                SwitchModeEvent(mode: AuthViewMode.login),
              ),
            );
            break;
          case AuthViewMode.firstLoginReset:
            final resetState = state is AuthMustResetPassword ? state : null;
            card = FirstLoginResetCard(
              userId: resetState?.userId ?? 0,
              email: resetState?.email ?? '',
              onNavigateToLogin: () => context.read<AuthBloc>().add(
                SwitchModeEvent(mode: AuthViewMode.login),
              ),
            );
            break;
          case AuthViewMode.login:
            card = LoginCard(
              onNavigateToForgotPassword: () => context.read<AuthBloc>().add(
                SwitchModeEvent(mode: AuthViewMode.forgotPassword),
              ),
            );
            break;
        }

        return Scaffold(
          backgroundColor: ThemeColors.unifiedBackground,
          body: SafeArea(
            child: Column(
              children: [
                const TopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 48,
                    ),
                    child: isWide
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const LeftPanel(),
                              const SizedBox(width: 56),
                              card,
                            ],
                          )
                        : Column(
                            children: [
                              const LeftPanel(),
                              const SizedBox(height: 36),
                              card,
                            ],
                          ),
                  ),
                ),
                const Footer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
