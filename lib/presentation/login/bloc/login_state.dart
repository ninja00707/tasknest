abstract class AuthState {
  final bool isLoading;
  final bool obscurePassword;

  const AuthState({this.isLoading = false, this.obscurePassword = true});
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading({super.obscurePassword}) : super(isLoading: true);
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message, {super.obscurePassword});
}

class PasswordVisibilityState extends AuthState {
  const PasswordVisibilityState({
    required bool obscurePassword,
    required bool isLoading,
  }) : super(obscurePassword: obscurePassword, isLoading: isLoading);
}
