import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/constant/validators.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/core/theme/common_auth_widgets.dart';
import 'package:tasknest/core/theme/common_dropDown.dart';
import 'package:tasknest/core/theme/common_text.dart';
import 'package:tasknest/core/theme/common_text_form_field.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';

// ignore: must_be_immutable
class SignupCard extends StatelessWidget {
  SignupCard({super.key, required this.onNavigate});

  final VoidCallback onNavigate;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                    ConstStrings.createAnAccount,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: ConstStrings.join,
                          style: AppTextStyles.bodyMuted,
                        ),
                        TextSpan(
                          text: ConstStrings.umEnterprises,
                          style: AppTextStyles.buttonText,
                        ),
                        TextSpan(
                          text: ' \u00b7 ',
                          style: AppTextStyles.bodyMuted,
                        ),
                        TextSpan(
                          text: ConstStrings.matrixPharma,
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
                  CommonTextFormField(
                    hint: ConstStrings.fullName,
                    controller: _nameController,
                    icon: Icons.person_outline,
                    onChanged: (v) => context
                        .read<AuthBloc>()
                        .add(SignupNameChanged(v)),
                    validator: (val) =>
                        val == null || val.isEmpty ? ConstStrings.nameRequired : null,
                  ),
                  const SizedBox(height: 12),
                  CommonTextFormField(
                    hint: ConstStrings.emailAddress,
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    onChanged: (v) => context
                        .read<AuthBloc>()
                        .add(SignupEmailChanged(v)),
                    validator: AuthValidators.validateEmail,
                  ),
                  const SizedBox(height: 12),
                  CommonTextFormField(
                    icon: Icons.lock_outline,
                    obscurePassword: state.obscurePassword,
                    hint: ConstStrings.password,
                    controller: _passwordController,
                    onChanged: (v) => context
                        .read<AuthBloc>()
                        .add(SignupPasswordChanged(v)),
                    validator: AuthValidators.validatePassword,
                    onToggle: () {},
                  ),
                  const SizedBox(height: 12),
                  CommonDropdown<int>(
                    value: state.signupCompanyId,
                    hint: ConstStrings.selectCompany,
                    items: CompanyNames.map((v) {
                      return DropdownItem<int>(value: v.id, label: v.name);
                    }).toList(),
                    onChanged: (v) =>
                        context.read<AuthBloc>().add(SignupCompanyChanged(v)),
                  ),
                  const SizedBox(height: 12),
                  CommonDropdown<int>(
                    value: state.signupDeptId,
                    hint: ConstStrings.selectDepartment,
                    items: departments.map((dept) {
                      return DropdownItem<int>(
                        value: dept.id,
                        label: dept.name,
                      );
                    }).toList(),
                    onChanged: (v) =>
                        context.read<AuthBloc>().add(SignupDeptChanged(v)),
                  ),
                  const SizedBox(height: 12),
                  CommonDropdown<int>(
                    value: state.signupRoleId,
                    hint: ConstStrings.selectRole,
                    items: roles.map((role) {
                      return DropdownItem<int>(
                        value: role.id,
                        label: role.name,
                      );
                    }).toList(),
                    onChanged: (v) =>
                        context.read<AuthBloc>().add(SignupRoleChanged(v)),
                  ),
                  const SizedBox(height: 20),
                  AuthGradientButton(
                    label: ConstStrings.signUp,
                    isLoading: state.isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
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
                  AuthOutlinedButton(
                    label: ConstStrings.alreadyHaveAccountLogin,
                    onPressed: onNavigate,
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
