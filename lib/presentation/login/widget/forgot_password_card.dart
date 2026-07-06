import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/constant/validators.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_auth_widgets.dart';
import 'package:tasknest/core/theme/common_text.dart';
import 'package:tasknest/core/theme/common_text_form_field.dart';
import 'package:tasknest/presentation/login/bloc/auth_view_mode.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';

class ForgotPasswordCard extends StatefulWidget {
  const ForgotPasswordCard({super.key});

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
          context.read<AuthBloc>().add(
            SwitchModeEvent(mode: AuthViewMode.login),
          );
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
      child: AuthCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonText(
                ConstStrings.resetPassword,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(height: 4),
              const CommonText(
                ConstStrings.enterEmailToReset,
                fontSize: 14,
                color: ThemeColors.unifiedTextMuted,
              ),
              const SizedBox(height: 24),
              CommonTextFormField(
                hint: ConstStrings.emailAddress,
                controller: emailController,
                icon: Icons.email_outlined,
                validator: AuthValidators.validateEmail,
              ),
              const SizedBox(height: 24),
              AuthGradientButton(
                label: ConstStrings.sendResetLink,
                isLoading: state.isLoading,
                onPressed: () {
                  if (emailFormKey.currentState!.validate()) {
                    context.read<AuthBloc>().add(
                          ForgotPasswordEvent(
                            email: emailController.text.trim(),
                          ),
                        );
                  }
                },
              ),
              const SizedBox(height: 16),
              AuthOutlinedButton(
                label: ConstStrings.backToLogIn,
                onPressed: () => context.read<AuthBloc>().add(
                  SwitchModeEvent(mode: AuthViewMode.login),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm(
      BuildContext context, AuthForgotPasswordSent? sentState) {
    return Form(
      key: resetFormKey,
      child: AuthCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonText(
                ConstStrings.enterResetCode,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(height: 4),
              CommonText(
                '${ConstStrings.codeSentTo}$_email'
                '${ConstStrings.codeExpiresIn}${sentState?.expiresIn ?? 15}${ConstStrings.minutes}',
                fontSize: 14,
                color: ThemeColors.unifiedTextMuted,
              ),
              if (sentState?.resetToken != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedPrimary.withValues(alpha: 0.1),
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
                        '${ConstStrings.devCode}${sentState!.resetToken}',
                        style: const TextStyle(
                          fontSize: 14,
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
                hint: ConstStrings.resetCode,
                controller: codeController,
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return ConstStrings.resetCodeRequired;
                  }
                  if (v.trim().length != 6) {
                    return ConstStrings.codeMustBe6Digits;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonTextFormField(
                hint: ConstStrings.newPassword,
                controller: newPasswordController,
                icon: Icons.lock_outline,
                obscurePassword: true,
                validator: AuthValidators.validatePassword,
              ),
              const SizedBox(height: 16),
              CommonTextFormField(
                hint: ConstStrings.confirmNewPassword,
                controller: confirmPasswordController,
                icon: Icons.lock_outline,
                obscurePassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return ConstStrings.pleaseConfirmPassword;
                  }
                  if (v != newPasswordController.text) {
                    return ConstStrings.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AuthGradientButton(
                label: ConstStrings.resetPasswordBtn,
                isLoading: false,
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
              ),
              const SizedBox(height: 16),
              AuthOutlinedButton(
                label: ConstStrings.backToLogIn,
                onPressed: () => context.read<AuthBloc>().add(
                  SwitchModeEvent(mode: AuthViewMode.login),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
