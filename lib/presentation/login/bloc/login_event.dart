abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String? email;
  final String? password;

  LoginEvent({this.email, this.password});
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
}

class LogoutEvent extends AuthEvent {}

class TogglePasswordVisibility extends AuthEvent {}
