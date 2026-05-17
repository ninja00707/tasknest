import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/data/repositories/auth/auth_repository.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        await authRepository.login(
          email: event.email,
          password: event.password,
        );

        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        await authRepository.register(
          name: event.name,
          email: event.email,
          password: event.password,
        );

        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    });
  }
}
