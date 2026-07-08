import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/login/bloc/auth_view_mode.dart';

abstract class AuthState extends Equatable {
  final bool isLoading;
  final bool obscurePassword;
  final AuthViewMode currentMode;

  // Signup form fields
  final String signupName;
  final String signupEmail;
  final String signupPassword;
  final int signupRoleId;
  final int signupCompanyId;
  final int signupDeptId;

  const AuthState({
    this.isLoading = false,
    this.obscurePassword = true,
    this.currentMode = AuthViewMode.login,
    this.signupName = '',
    this.signupEmail = '',
    this.signupPassword = '',
    this.signupRoleId = 0,
    this.signupCompanyId = 0,
    this.signupDeptId = 0,
  });

  @override
  List<Object?> get props => [
        isLoading,
        obscurePassword,
        currentMode,
        signupName,
        signupEmail,
        signupPassword,
        signupRoleId,
        signupCompanyId,
        signupDeptId,
      ];

  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  });
}

class AuthInitial extends AuthState {
  const AuthInitial({
    super.currentMode,
    super.signupName,
    super.signupEmail,
    super.signupPassword,
    super.signupRoleId,
    super.signupCompanyId,
    super.signupDeptId,
  });

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) {
    return AuthInitial(
      currentMode: currentMode,
      signupName: name ?? signupName,
      signupEmail: email ?? signupEmail,
      signupPassword: password ?? signupPassword,
      signupRoleId: roleId ?? signupRoleId,
      signupCompanyId: companyId ?? signupCompanyId,
      signupDeptId: deptId ?? signupDeptId,
    );
  }
}

class AuthLoading extends AuthState {
  const AuthLoading({
    super.obscurePassword,
    super.currentMode,
    super.signupName,
    super.signupEmail,
    super.signupPassword,
    super.signupRoleId,
    super.signupCompanyId,
    super.signupDeptId,
  }) : super(isLoading: true);

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) {
    return AuthLoading(
      obscurePassword: obscurePassword,
      currentMode: currentMode,
      signupName: name ?? signupName,
      signupEmail: email ?? signupEmail,
      signupPassword: password ?? signupPassword,
      signupRoleId: roleId ?? signupRoleId,
      signupCompanyId: companyId ?? signupCompanyId,
      signupDeptId: deptId ?? signupDeptId,
    );
  }
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({super.currentMode});

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) =>
      this;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({super.currentMode});

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) =>
      this;
}

class AuthError extends AuthState {
  final String message;

  const AuthError(
    this.message, {
    super.obscurePassword,
    super.currentMode,
    super.signupName,
    super.signupEmail,
    super.signupPassword,
    super.signupRoleId,
    super.signupCompanyId,
    super.signupDeptId,
  });

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) {
    return AuthError(
      message,
      obscurePassword: obscurePassword,
      currentMode: currentMode,
      signupName: name ?? signupName,
      signupEmail: email ?? signupEmail,
      signupPassword: password ?? signupPassword,
      signupRoleId: roleId ?? signupRoleId,
      signupCompanyId: companyId ?? signupCompanyId,
      signupDeptId: deptId ?? signupDeptId,
    );
  }
}

class PasswordVisibilityState extends AuthState {
  const PasswordVisibilityState({
    required super.obscurePassword,
    required super.isLoading,
    super.currentMode,
    super.signupName,
    super.signupEmail,
    super.signupPassword,
    super.signupRoleId,
    super.signupCompanyId,
    super.signupDeptId,
  });

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) {
    return PasswordVisibilityState(
      obscurePassword: obscurePassword,
      isLoading: isLoading,
      currentMode: currentMode,
    );
  }
}

class AuthForgotPasswordSent extends AuthState {
  final String message;
  final String? resetToken;
  final int expiresIn;
  final String email;
  const AuthForgotPasswordSent({
    required this.message,
    this.resetToken,
    required this.expiresIn,
    required this.email,
    super.currentMode,
  });

  @override
  List<Object?> get props => [
        message,
        resetToken,
        expiresIn,
        email,
        isLoading,
        obscurePassword,
        currentMode,
      ];

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) =>
      this;
}

class AuthForgotPasswordError extends AuthState {
  final String message;
  const AuthForgotPasswordError(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) =>
      this;
}

class AuthResetPasswordSuccess extends AuthState {
  final String message;
  const AuthResetPasswordSuccess(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) =>
      this;
}

class AuthResetPasswordError extends AuthState {
  final String message;
  const AuthResetPasswordError(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) =>
      this;
}

class AuthRegistrationPending extends AuthState {
  final String message;
  const AuthRegistrationPending(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) =>
      this;
}

class AuthMustResetPassword extends AuthState {
  final int userId;
  final String email;
  final String message;
  const AuthMustResetPassword({
    required this.userId,
    required this.email,
    required this.message,
    super.currentMode,
  });

  @override
  List<Object?> get props => [
        userId,
        email,
        message,
        isLoading,
        obscurePassword,
        currentMode,
      ];

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) =>
      this;
}

class AuthFirstLoginResetSuccess extends AuthState {
  final String message;
  const AuthFirstLoginResetSuccess(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) =>
      this;
}

class AuthFirstLoginResetError extends AuthState {
  final String message;
  const AuthFirstLoginResetError(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];

  @override
  AuthState copyWithSignup({
    String? name,
    String? email,
    String? password,
    int? roleId,
    int? companyId,
    int? deptId,
  }) =>
      this;
}
