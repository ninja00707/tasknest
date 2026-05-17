import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/core/theme/aleertbox.dart';
import 'package:tasknest/core/theme/color.dart';

import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';

import 'package:tasknest/presentation/login/widget/footer.dart';
import 'package:tasknest/presentation/login/widget/left_panel.dart';
import 'package:tasknest/presentation/login/widget/login_card.dart';
import 'package:tasknest/presentation/login/widget/signup_card.dart';
import 'package:tasknest/presentation/login/widget/forgot_password_card.dart';
import 'package:tasknest/presentation/login/widget/top_bar.dart';

enum AuthViewMode { login, signup, forgotPassword }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthViewMode currentMode = AuthViewMode.login;

  void _switchMode(AuthViewMode mode) {
    setState(() {
      currentMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.dashboard);
        }
        if (state is AuthError) {
          AppAlertDialog.show(
            context: context,
            title: 'Authentication Failed',
            message: state.message,
            isError: true,
          );
        }
        if (state is AuthAuthenticated) {
          AppAlertDialog.show(
            context: context,
            title: 'Success',
            message: 'Login Success',
            isError: false,
          );
          if (currentMode == AuthViewMode.forgotPassword) {
            _switchMode(AuthViewMode.login);
          }
        }
      },
      builder: (context, state) {
        Widget card;
        switch (currentMode) {
          case AuthViewMode.signup:
            card = SignupCard(
              onNavigate: () => _switchMode(AuthViewMode.login),
            );
            break;
          case AuthViewMode.forgotPassword:
            card = ForgotPasswordCard(
              // onNavigate: () => _switchMode(AuthViewMode.forgotPassword),
            );
            break;
          case AuthViewMode.login:
          default:
            card = LoginCard(
              onNavigateToSignup: () => _switchMode(AuthViewMode.signup),
              onNavigateToForgotPassword: () =>
                  _switchMode(AuthViewMode.forgotPassword),
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
