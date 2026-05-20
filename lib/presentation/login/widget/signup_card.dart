import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/validators.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_dropDown.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';
import 'package:tasknest/core/theme/common_textForm_Field.dart';

// ignore: must_be_immutable
class SignupCard extends StatelessWidget {
  SignupCard({super.key, required this.onNavigate});

  final VoidCallback onNavigate;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Departments selectedDepartment = Departments(id: 0, name: 'HR');
  Roles selectedRole = Roles(name: 'ceo', id: 0);
  Company selectedCompany = Company(id: 0, name: 'UM Enterprises');
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
                        'Create an account',
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
                              text: 'Join ',
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

                      // NAME FIELD
                      CommonTextFormField(
                        hint: 'Full Name',
                        controller: nameController,
                        icon: Icons.person_outline,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // EMAIL FIELD
                      CommonTextFormField(
                        hint: 'Email address',
                        controller: emailController,
                        icon: Icons.email_outlined,
                        validator: AuthValidators.validateEmail,
                      ),
                      const SizedBox(height: 12),

                      // PASSWORD FIELD
                      CommonTextFormField(
                        icon: Icons.lock_outline,
                        obscurePassword: state
                            .obscurePassword, // Reusing state from login for UI parity
                        hint: 'Password',
                        controller: passwordController,
                        validator: AuthValidators.validatePassword,
                        onToggle: () {
                          // Uncomment when Toggle event is fully implemented
                          // context.read<AuthBloc>().add(TogglePasswordVisibility());
                        },
                      ),
                      const SizedBox(height: 12),

                      // COMPANY FIELD (Placeholder for Dropdown later)
                      CommonDropdown<Company>(
                        hint: 'Select Company',
                        items: CompanyNames.map((v) {
                          return DropdownItem<Company>(value: v, label: v.name);
                        }).toList(),

                        onChanged: (Company value) {
                          selectedCompany = value;
                        },
                      ),
                      const SizedBox(height: 12),

                      CommonDropdown<Departments>(
                        hint: 'Select Department',
                        items: departments.map((dept) {
                          return DropdownItem<Departments>(
                            value: dept,
                            label: dept.name,
                          );
                        }).toList(),

                        onChanged: (Departments value) {
                          selectedDepartment = value;
                        },
                      ),

                      const SizedBox(height: 12),

                      // DEPARTMENT FIELD (Placeholder for Dropdown later)
                      CommonDropdown<Roles>(
                        hint: 'Select Role',
                        items: roles.map((role) {
                          return DropdownItem<Roles>(
                            value: role,
                            label: role.name,
                          );
                        }).toList(),

                        onChanged: (Roles value) {
                          selectedRole = value;
                        },
                      ),
                      const SizedBox(height: 20),
                      // SIGN UP BUTTON
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
                                      // Trigger signup event here
                                      context.read<AuthBloc>().add(
                                        RegisterEvent(
                                          name: nameController.text,
                                          email: emailController.text,
                                          password: passwordController.text,
                                          companyId: selectedCompany.id,
                                          departmentId: selectedDepartment.id,
                                          role: selectedRole.id,
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
                                    'Sign Up',
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

                      // BACK TO LOGIN
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: onNavigate,
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
                            'Already have an account? Log in',
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
