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
  final String companyId;
  final String departmentId;
  final String role;

  RegisterEvent(
    this.name,
    this.email,
    this.password,
    this.companyId,
    this.departmentId,
    this.role,
  );
}

class LogoutEvent extends AuthEvent {}

class TogglePasswordVisibility extends AuthEvent {}
