import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/dashboard_screen.dart.dart';
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

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        // ERROR

        if (state.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          });
        }

        // SUCCESS NAVIGATION

        if (state.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen()),
            );
          });
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

                              const LoginCard(),
                            ],
                          )
                        : Column(
                            children: [
                              const LeftPanel(),

                              const SizedBox(height: 36),

                              const LoginCard(),
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
