import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/presentation/login/auth_server_example.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService authService;

  LoginBloc(this.authService) : super(const LoginState()) {
    on<Credentials>((event, emit) {
      emit(state.copyWith(email: event.email, password: event.password));
    });

    on<TogglePasswordVisibility>((event, emit) {
      emit(state.copyWith(obscurePassword: !state.obscurePassword));
    });

    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(errorMessage: "Please fill all fields"));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final success = await authService.login(
      email: state.email,
      password: state.password,
    );

    if (success) {
      emit(state.copyWith(isLoading: false));
    } else {
      emit(
        state.copyWith(isLoading: false, errorMessage: "Invalid credentials"),
      );
    }
  }
}
