import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/login/bloc/auth_view_mode.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String? code;
  final String? password;

  LoginEvent({this.code, this.password});

  @override
  List<Object?> get props => [code, password];
}

class FirstLoginResetEvent extends AuthEvent {
  final int userId;
  final String email;
  final String newPassword;
  FirstLoginResetEvent({
    required this.userId,
    required this.email,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [userId, email, newPassword];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final int companyId;
  final int departmentId;
  final int role;

  RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.companyId,
    required this.departmentId,
    required this.role,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    companyId,
    departmentId,
    role,
  ];
}

class LogoutEvent extends AuthEvent {}

class TogglePasswordVisibility extends AuthEvent {}

class ForgotPasswordEvent extends AuthEvent {
  final String email;
  ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;
  ResetPasswordEvent({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}

class SwitchModeEvent extends AuthEvent {
  final AuthViewMode mode;
  SwitchModeEvent({required this.mode});

  @override
  List<Object?> get props => [mode];
}

class SignupNameChanged extends AuthEvent {
  final String name;
  SignupNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class SignupEmailChanged extends AuthEvent {
  final String email;
  SignupEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class SignupPasswordChanged extends AuthEvent {
  final String password;
  SignupPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class SignupRoleChanged extends AuthEvent {
  final int roleId;
  SignupRoleChanged(this.roleId);

  @override
  List<Object?> get props => [roleId];
}

class SignupCompanyChanged extends AuthEvent {
  final int companyId;
  SignupCompanyChanged(this.companyId);

  @override
  List<Object?> get props => [companyId];
}

class SignupDeptChanged extends AuthEvent {
  final int deptId;
  SignupDeptChanged(this.deptId);

  @override
  List<Object?> get props => [deptId];
}
