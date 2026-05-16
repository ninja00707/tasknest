import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/widget/input_field.dart';
import 'package:tasknest/presentation/login/widget/password_field.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Container(
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

                    // EMAIL FIELD
                    InputField(
                      hint: 'Email address or phone number',

                      icon: Icons.email_outlined,

                      onChanged: (value) {
                        context.read<LoginBloc>().add(
                          Credentials(email: value),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // PASSWORD FIELD
                    PasswordField(
                      obscurePassword: state.obscurePassword,

                      onChanged: (value) {
                        context.read<LoginBloc>().add(
                          Credentials(password: value),
                        );
                      },

                      onToggle: () {
                        context.read<LoginBloc>().add(
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
                                  context.read<LoginBloc>().add(
                                    LoginSubmitted(),
                                  );
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
                        onPressed: () {},

                        child: const Text(
                          'Forgot password?',

                          style: TextStyle(
                            color: ThemeColors.unifiedSecondary,

                            fontWeight: FontWeight.w600,

                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    // DIVIDER
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: ThemeColors.unifiedBorder),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),

                          child: Text(
                            'or',

                            style: TextStyle(
                              color: ThemeColors.unifiedTextMuted.withOpacity(
                                0.7,
                              ),

                              fontSize: 13,
                            ),
                          ),
                        ),

                        const Expanded(
                          child: Divider(color: ThemeColors.unifiedBorder),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // CREATE ACCOUNT
                    SizedBox(
                      width: double.infinity,
                      height: 48,

                      child: OutlinedButton(
                        onPressed: () {},

                        style: OutlinedButton.styleFrom(
                          foregroundColor: ThemeColors.unifiedPrimary,

                          side: const BorderSide(
                            color: ThemeColors.unifiedPrimary,

                            width: 1.5,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),

                        child: const Text(
                          'Create new account',

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
