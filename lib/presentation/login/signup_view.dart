import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/alert_box.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_auth_widgets.dart';
import 'package:tasknest/core/theme/common_dropDown.dart';
import 'package:tasknest/core/theme/common_text.dart';
import 'package:tasknest/core/theme/common_text_form_field.dart';
import 'package:tasknest/core/constant/validators.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            AppAlertDialog.show(
              context: context,
              title: ConstStrings.success,
              message: ConstStrings.accountCreatedSuccessfully,
              isError: false,
            );
            context.go('/login');
          }

          if (state is AuthRegistrationPending) {
            AppAlertDialog.show(
              context: context,
              title: ConstStrings.registrationPending,
              message: state.message,
              isError: false,
            );
            context.go('/login');
          }

          if (state is AuthError) {
            AppAlertDialog.show(
              context: context,
              title: ConstStrings.signupFailed,
              message: state.message,
              isError: true,
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              child: AuthCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText(
                          ConstStrings.createAccount,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                        const SizedBox(height: 4),
                        const CommonText(
                          ConstStrings.fillDetailsToGetStarted,
                          fontSize: 14,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                        const SizedBox(height: 24),
                        CommonTextFormField(
                          hint: ConstStrings.fullName,
                          icon: Icons.person_outline,
                          initialValue: state.signupName,
                          onChanged: (v) => context.read<AuthBloc>().add(
                            SignupNameChanged(v),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? ConstStrings.required_
                              : null,
                        ),
                        const SizedBox(height: 12),
                        CommonTextFormField(
                          hint: ConstStrings.emailAddress,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          initialValue: state.signupEmail,
                          onChanged: (v) => context.read<AuthBloc>().add(
                            SignupEmailChanged(v),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? ConstStrings.required_
                              : null,
                        ),
                        const SizedBox(height: 12),
                        CommonDropdown<int>(
                          value: state.signupRoleId,
                          hint: ConstStrings.selectRole,
                          items: roles
                              .map(
                                (r) => DropdownItem(value: r.id, label: r.name),
                              )
                              .toList(),
                          onChanged: (v) => context.read<AuthBloc>().add(
                            SignupRoleChanged(v),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CommonDropdown<int>(
                          value: state.signupCompanyId,
                          hint: ConstStrings.selectCompany,
                          items: CompanyNames.map(
                            (c) => DropdownItem(value: c.id, label: c.name),
                          ).toList(),
                          onChanged: (v) => context.read<AuthBloc>().add(
                            SignupCompanyChanged(v),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CommonDropdown<int>(
                          value: state.signupDeptId,
                          hint: ConstStrings.selectDepartment,
                          items: departments
                              .map(
                                (d) => DropdownItem(value: d.id, label: d.name),
                              )
                              .toList(),
                          onChanged: (v) => context.read<AuthBloc>().add(
                            SignupDeptChanged(v),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CommonTextFormField(
                          hint: ConstStrings.password,
                          icon: Icons.lock_outline,
                          obscurePassword: true,
                          initialValue: state.signupPassword,
                          onChanged: (v) => context.read<AuthBloc>().add(
                            SignupPasswordChanged(v),
                          ),
                          validator: AuthValidators.validatePassword,
                        ),
                        const SizedBox(height: 24),
                        AuthGradientButton(
                          label: ConstStrings.signUp,
                          isLoading: state.isLoading,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                RegisterEvent(
                                  name: state.signupName,
                                  email: state.signupEmail,
                                  password: state.signupPassword,
                                  companyId: state.signupCompanyId,
                                  departmentId: state.signupDeptId,
                                  role: state.signupRoleId,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: CommonText(
                              ConstStrings.alreadyHaveAccountLoginAlt,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.unifiedPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
