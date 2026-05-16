class LoginState {
  final String email;
  final String password;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorMessage;

  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.isLoading = false,

    this.errorMessage,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,

      errorMessage: errorMessage,
    );
  }
}
