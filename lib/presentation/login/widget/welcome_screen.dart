import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/core/responsive.dart';
import 'package:tasknest/core/theme/alert_box.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/bloc/auth_view_mode.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';
import 'package:tasknest/presentation/login/widget/footer.dart';
import 'package:tasknest/presentation/login/widget/left_panel.dart';
import 'package:tasknest/presentation/login/widget/top_bar.dart';
import 'package:tasknest/presentation/login/widget/login_card.dart';
import 'package:tasknest/presentation/login/widget/forgot_password_card.dart';
import 'package:tasknest/presentation/login/widget/first_login_reset_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.runtimeType != curr.runtimeType,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          AppAlertDialog.show(
            context: context,
            title: ConstStrings.success,
            message: ConstStrings.loginSuccess,
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
                ? ConstStrings.accountPendingApproval
                : ConstStrings.authenticationFailed,
            message: state.message,
            isError: true,
          );
        }

        if (state is AuthFirstLoginResetError) {
          AppAlertDialog.show(
            context: context,
            title: ConstStrings.passwordResetFailed,
            message: state.message,
            isError: true,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (prev, curr) =>
            prev.currentMode != curr.currentMode,
        builder: (context, state) {
          Widget card;
          switch (state.currentMode) {
            case AuthViewMode.forgotPassword:
              card = ForgotPasswordCard();
              break;
            case AuthViewMode.firstLoginReset:
              final resetState = state is AuthMustResetPassword ? state : null;
              card = FirstLoginResetCard(
                userId: resetState?.userId ?? 0,
                email: resetState?.email ?? '',
              );
              break;
            case AuthViewMode.login:
              card = LoginCard();
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
      ),
    );
  }
}
