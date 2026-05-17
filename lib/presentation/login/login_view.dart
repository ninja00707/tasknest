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
import 'package:tasknest/presentation/login/widget/top_bar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // LOGIN SUCCESS
        if (state is AuthAuthenticated) {
          context.go(RouteNames.dashboard);
        }

        // LOGIN ERROR
        if (state is AuthError) {
          AppAlertDialog.show(
            context: context,

            title: 'Login Failed',

            message: state.message,

            isError: true,
          );
        }
      },

      builder: (context, state) {
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

                              LoginCard(),
                            ],
                          )
                        : Column(
                            children: [
                              const LeftPanel(),

                              const SizedBox(height: 36),

                              LoginCard(),
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
