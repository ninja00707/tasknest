import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/login/bloc/auth_view_mode.dart';

abstract class AuthState extends Equatable {
  final bool isLoading;
  final bool obscurePassword;
  final AuthViewMode currentMode;

  const AuthState({
    this.isLoading = false,
    this.obscurePassword = true,
    this.currentMode = AuthViewMode.login,
  });

  @override
  List<Object?> get props => [isLoading, obscurePassword, currentMode];
}

class AuthInitial extends AuthState {
  const AuthInitial({super.currentMode});
}

class AuthLoading extends AuthState {
  const AuthLoading({super.obscurePassword, super.currentMode})
    : super(isLoading: true);
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({super.currentMode});
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({super.currentMode});
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message, {super.obscurePassword, super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];
}

class PasswordVisibilityState extends AuthState {
  const PasswordVisibilityState({
    required bool obscurePassword,
    required bool isLoading,
    super.currentMode,
  }) : super(obscurePassword: obscurePassword, isLoading: isLoading);
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
}

class AuthForgotPasswordError extends AuthState {
  final String message;
  const AuthForgotPasswordError(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];
}

class AuthResetPasswordSuccess extends AuthState {
  final String message;
  const AuthResetPasswordSuccess(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];
}

class AuthResetPasswordError extends AuthState {
  final String message;
  const AuthResetPasswordError(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];
}

class AuthRegistrationPending extends AuthState {
  final String message;
  const AuthRegistrationPending(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];
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
}

class AuthFirstLoginResetSuccess extends AuthState {
  final String message;
  const AuthFirstLoginResetSuccess(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];
}

class AuthFirstLoginResetError extends AuthState {
  final String message;
  const AuthFirstLoginResetError(this.message, {super.currentMode});

  @override
  List<Object?> get props => [message, isLoading, obscurePassword, currentMode];
}
