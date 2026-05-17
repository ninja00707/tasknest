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
        await authRepository.login(
          email: event.email!,
          password: event.password!,
        );

        emit(const AuthAuthenticated());
      } catch (e) {
        print("==============================$e");
        emit(AuthError(e.toString(), obscurePassword: obscurePassword));
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
        await authRepository.register(
          name: event.name,
          email: event.email,
          password: event.password,
        );

        emit(const AuthAuthenticated());
      } catch (e) {
        emit(AuthError(e.toString(), obscurePassword: obscurePassword));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await authRepository.logout();

      emit(const AuthUnauthenticated());
    });
  }
}
