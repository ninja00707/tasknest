import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/core/theme/common_textForm_Field.dart';

class FirstLoginResetCard extends StatefulWidget {
  final int userId;
  final String email;
  final VoidCallback? onNavigateToLogin;

  const FirstLoginResetCard({
    super.key,
    required this.userId,
    required this.email,
    this.onNavigateToLogin,
  });

  @override
  State<FirstLoginResetCard> createState() => _FirstLoginResetCardState();
}

class _FirstLoginResetCardState extends State<FirstLoginResetCard> {
  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

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
                      const Text(
                        'Set your password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome! Please set a new password for ${widget.email}.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: ThemeColors.unifiedTextMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CommonTextFormField(
                        hint: 'New password',
                        controller: newPasswordController,
                        icon: Icons.lock_outline,
                        obscurePassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CommonTextFormField(
                        hint: 'Confirm new password',
                        controller: confirmPasswordController,
                        icon: Icons.lock_outline,
                        obscurePassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm your password';
                          if (v != newPasswordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
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
                                        FirstLoginResetEvent(
                                          userId: widget.userId,
                                          email: widget.email,
                                          newPassword: newPasswordController.text,
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
                                    'Set Password & Login',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: widget.onNavigateToLogin,
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
                            'Back to Log In',
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
          ),
        );
      },
    );
  }
}
