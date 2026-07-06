import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/constant/validators.dart';
import 'package:tasknest/presentation/login/bloc/auth_view_mode.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/core/theme/common_text_form_field.dart';

class FirstLoginResetCard extends StatefulWidget {
  final int userId;
  final String email;

  const FirstLoginResetCard({
    super.key,
    required this.userId,
    required this.email,
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
                        ConstStrings.setYourPassword,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ConstStrings.welcomeSetNewPassword}${widget.email}.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: ThemeColors.unifiedTextMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                          if (v == null || v.isEmpty) return ConstStrings.pleaseConfirmPassword;
                          if (v != newPasswordController.text) return ConstStrings.passwordsDoNotMatch;
                          if (!AuthValidators.passwordRegex.hasMatch(v)) return AuthValidators.validatePassword(v);
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
                                    ConstStrings.setPasswordAndLogin,
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
                          onPressed: () => context.read<AuthBloc>().add(
                            SwitchModeEvent(mode: AuthViewMode.login),
                          ),
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
                            ConstStrings.backToLogIn,
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
