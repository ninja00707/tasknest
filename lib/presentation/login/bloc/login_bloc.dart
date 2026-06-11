import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tasknest/data/repositories/auth/auth_repository.dart';

import 'login_event.dart';
import 'login_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  bool obscurePassword = true;

  AuthBloc(this.authRepository) : super(const AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading(obscurePassword: obscurePassword));

      try {
        final result = await authRepository.login(
          code: event.code!,
          password: event.password!,
        );

        // Check if must reset password on first login
        if (result['mustResetPassword'] == true) {
          final data = result['data'] as Map<String, dynamic>? ?? result;
          emit(AuthMustResetPassword(
            userId: data['userId'] ?? 0,
            email: data['email'] ?? '',
            message: result['message'] ?? 'Please set your password.',
          ));
        } else {
          emit(const AuthAuthenticated());
        }
      } catch (e) {
        print("==============================$e");
        emit(AuthError(e.toString(), obscurePassword: obscurePassword));
      }
    });

    on<FirstLoginResetEvent>((event, emit) async {
      emit(AuthLoading(obscurePassword: obscurePassword));

      try {
        await authRepository.firstLoginReset(
          userId: event.userId,
          email: event.email,
          newPassword: event.newPassword,
        );

        emit(const AuthAuthenticated());
      } catch (e) {
        emit(AuthFirstLoginResetError(e.toString()));
      }
    });

    on<TogglePasswordVisibility>((event, emit) {
      obscurePassword = !obscurePassword;

      emit(
        PasswordVisibilityState(
          obscurePassword: obscurePassword,
          isLoading: false,
        ),
      );
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading(obscurePassword: obscurePassword));

      try {
        final result = await authRepository.register(
          name: event.name,
          email: event.email,
          password: event.password,
          companyId: event.companyId,
          departmentId: event.departmentId,
          role: event.role,
        );

        if (result.pendingApproval) {
          emit(AuthRegistrationPending(result.message));
        } else {
          emit(const AuthAuthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString(), obscurePassword: obscurePassword));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await authRepository.logout();

      emit(const AuthUnauthenticated());
    });

    on<ForgotPasswordEvent>((event, emit) async {
      emit(AuthLoading(obscurePassword: obscurePassword));

      try {
        final result = await authRepository.forgotPassword(event.email);

        emit(AuthForgotPasswordSent(
          message: result.message,
          resetToken: result.resetToken,
          expiresIn: result.expiresIn,
          email: event.email,
        ));
      } catch (e) {
        emit(AuthForgotPasswordError(e.toString()));
      }
    });

    on<ResetPasswordEvent>((event, emit) async {
      emit(AuthLoading(obscurePassword: obscurePassword));

      try {
        await authRepository.resetPassword(
          email: event.email,
          code: event.code,
          newPassword: event.newPassword,
        );

        emit(AuthResetPasswordSuccess(
          'Password reset successful! You can now log in with your new password.',
        ));
      } catch (e) {
        emit(AuthResetPasswordError(e.toString()));
      }
    });
  }
}
