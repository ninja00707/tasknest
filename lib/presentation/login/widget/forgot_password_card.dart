import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/validators.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';
import 'package:tasknest/core/theme/common_textForm_Field.dart';

class ForgotPasswordCard extends StatefulWidget {
  final VoidCallback? onNavigateToLogin;
  const ForgotPasswordCard({super.key, this.onNavigateToLogin});

  @override
  State<ForgotPasswordCard> createState() => _ForgotPasswordCardState();
}

class _ForgotPasswordCardState extends State<ForgotPasswordCard> {
  final emailFormKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _showResetForm = false;
  String _email = '';

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthForgotPasswordSent) {
          _email = state.email;
          codeController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
          setState(() => _showResetForm = true);
        }
        if (state is AuthResetPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          widget.onNavigateToLogin?.call();
        }
        if (state is AuthForgotPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is AuthResetPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (_showResetForm) {
          final sentState = state is AuthForgotPasswordSent ? state : null;
          return _buildResetForm(context, sentState);
        }
        return _buildEmailForm(context, state);
      },
    );
  }

  Widget _buildEmailForm(BuildContext context, AuthState state) {
    return Form(
      key: emailFormKey,
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
                    'Reset password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enter your email address to receive a secure password reset link.',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.unifiedTextMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CommonTextFormField(
                    hint: 'Email address',
                    controller: emailController,
                    icon: Icons.email_outlined,
                    validator: AuthValidators.validateEmail,
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
                                if (emailFormKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    ForgotPasswordEvent(
                                      email: emailController.text.trim(),
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
                                'Send Reset Link',
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
                      onPressed: () {
                        widget.onNavigateToLogin?.call();
                      },
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
  }

  Widget _buildResetForm(BuildContext context, AuthForgotPasswordSent? sentState) {
    return Form(
      key: resetFormKey,
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
                    'Enter reset code',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A 6-digit code was sent to $_email. '
                    'It expires in ${sentState?.expiresIn ?? 15} minutes.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeColors.unifiedTextMuted,
                      height: 1.5,
                    ),
                  ),
                  if (sentState?.resetToken != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: ThemeColors.unifiedPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dev code: ${sentState!.resetToken}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: ThemeColors.unifiedPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  CommonTextFormField(
                    hint: 'Reset code',
                    controller: codeController,
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Reset code is required';
                      }
                      if (v.trim().length != 6) {
                        return 'Code must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CommonTextFormField(
                    hint: 'New password',
                    controller: newPasswordController,
                    icon: Icons.lock_outline,
                    obscurePassword: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
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
                      if (v == null || v.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (v != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            ThemeColors.unifiedGradStart,
                            ThemeColors.unifiedGradEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (resetFormKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              ResetPasswordEvent(
                                email: _email,
                                code: codeController.text.trim(),
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
                        child: const Text(
                          'Reset Password',
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
                      onPressed: () {
                        widget.onNavigateToLogin?.call();
                      },
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
  }
}
