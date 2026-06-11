import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';
import 'package:tasknest/core/theme/common_textForm_Field.dart';

class LoginCard extends StatelessWidget {
  LoginCard({
    super.key,
    required this.onNavigateToForgotPassword,
  });

  final VoidCallback onNavigateToForgotPassword;

  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Form(
          key: formKey,
          child: Container(
            width: 396,

            decoration: BoxDecoration(
              color: ThemeColors.unifiedSurface,

              borderRadius: BorderRadius.circular(16),

              border: Border.all(color: ThemeColors.unifiedBorder),

              boxShadow: [
                BoxShadow(
                  color: ThemeColors.unifiedPrimary.withOpacity(0.06),

                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),

                BoxShadow(
                  color: ThemeColors.unifiedSecondary.withOpacity(0.06),

                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // TOP GRADIENT
                Container(
                  height: 5,

                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeColors.unifiedGradStart,
                        ThemeColors.unifiedGradEnd,
                      ],
                    ),

                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // HEADER
                      const Text(
                        'Welcome back',

                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Sign in to ',

                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColors.unifiedTextMuted,
                              ),
                            ),

                            TextSpan(
                              text: 'UM Enterprises',

                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColors.unifiedPrimary,

                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            TextSpan(
                              text: ' · ',

                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColors.unifiedTextMuted,
                              ),
                            ),

                            TextSpan(
                              text: 'Matrix Pharma',

                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColors.unifiedSecondary,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // CODE FIELD
                      CommonTextFormField(
                        hint: 'Employee Code',
                        controller: codeController,
                        icon: Icons.badge_outlined,

                        validator: (val) =>
                            val == null || val.trim().isEmpty
                                ? 'Employee code is required'
                                : null,
                      ),

                      const SizedBox(height: 12),

                      // PASSWORD FIELD
                      CommonTextFormField(
                        icon: Icons.lock_outline,
                        obscurePassword: state.obscurePassword,
                        hint: '******',
                        controller: passwordController,
                        validator: (val) =>
                            val == null || val.isEmpty
                                ? 'Password is required'
                                : null,
                        onToggle: () {
                          context.read<AuthBloc>().add(
                            TogglePasswordVisibility(),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: state.isLoading
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      ThemeColors.unifiedGradStart,

                                      ThemeColors.unifiedGradEnd,
                                    ],
                                  ),

                            borderRadius: BorderRadius.circular(8),
                          ),

                          child: ElevatedButton(
                            onPressed: state.isLoading
                                ? null
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        LoginEvent(
                                          code: codeController.text.trim(),

                                          password: passwordController.text
                                              .trim(),
                                        ),
                                      );
                                    }
                                  },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,

                              shadowColor: Colors.transparent,

                              foregroundColor: Colors.white,

                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),

                            child: state.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,

                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Log In',

                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,

                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // FORGOT PASSWORD
                      Center(
                        child: TextButton(
                          onPressed: onNavigateToForgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: ThemeColors.unifiedPrimary,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Forgot password?'),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
