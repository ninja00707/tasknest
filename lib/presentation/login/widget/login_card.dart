import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/constant/validators.dart';
import 'package:tasknest/core/theme/common_auth_widgets.dart';
import 'package:tasknest/core/theme/common_text.dart';
import 'package:tasknest/core/theme/common_text_form_field.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: AuthCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommonText(
                    ConstStrings.loginWelcomeBack,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: ConstStrings.signInTo,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A7B7B),
                          ),
                        ),
                        TextSpan(
                          text: ConstStrings.umEnterprises,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' \u00b7 ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A7B7B),
                          ),
                        ),
                        TextSpan(
                          text: ConstStrings.matrixPharma,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CommonTextFormField(
                    hint: ConstStrings.employeeCode,
                    controller: _codeController,
                    icon: Icons.badge_outlined,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? ConstStrings.employeeCodeRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  CommonTextFormField(
                    icon: Icons.lock_outline,
                    obscurePassword: state.obscurePassword,
                    hint: '\u2022\u2022\u2022\u2022\u2022\u2022',
                    controller: _passwordController,
                    validator: AuthValidators.validatePassword,
                    onToggle: () {
                      context.read<AuthBloc>().add(TogglePasswordVisibility());
                    },
                  ),
                  const SizedBox(height: 20),
                  AuthGradientButton(
                    label: ConstStrings.logIn,
                    isLoading: state.isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              LoginEvent(
                                code: _codeController.text.trim(),
                                password: _passwordController.text.trim(),
                              ),
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
