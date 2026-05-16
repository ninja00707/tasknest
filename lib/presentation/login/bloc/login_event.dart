abstract class LoginEvent {}

class Credentials extends LoginEvent {
  final String? email;
  final String? password;
  Credentials({this.email, this.password});
}

class TogglePasswordVisibility extends LoginEvent {}

class LoginSubmitted extends LoginEvent {}
