import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tasknest/domain/repositories_impl/auth_impl/auth_impl.dart';
import 'package:tasknest/presentation/login/bloc/auth_view_mode.dart';

import 'login_event.dart';
import 'login_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl _authRepository;
  bool obscurePassword = true;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<FirstLoginResetEvent>(_onFirstLoginReset);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<SwitchModeEvent>(_onSwitchMode);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<SignupNameChanged>(_onSignupNameChanged);
    on<SignupEmailChanged>(_onSignupEmailChanged);
    on<SignupPasswordChanged>(_onSignupPasswordChanged);
    on<SignupRoleChanged>(_onSignupRoleChanged);
    on<SignupCompanyChanged>(_onSignupCompanyChanged);
    on<SignupDeptChanged>(_onSignupDeptChanged);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading(obscurePassword: obscurePassword));
    try {
      final result = await _authRepository.login(
        code: event.code!,
        password: event.password!,
      );

      // Check if must reset password on first login
      if (result['mustResetPassword'] == true) {
        final data = result['data'] as Map<String, dynamic>? ?? result;
        emit(
          AuthMustResetPassword(
            userId: data['userId'] ?? 0,
            email: data['email'] ?? '',
            message: result['message'] ?? 'Please set your password.',
            currentMode: AuthViewMode.firstLoginReset,
          ),
        );
      } else {
        emit(const AuthAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString(), obscurePassword: obscurePassword));
    }
  }

  Future<void> _onFirstLoginReset(
    FirstLoginResetEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(obscurePassword: obscurePassword));

    try {
      await _authRepository.firstLoginReset(
        userId: event.userId,
        email: event.email,
        newPassword: event.newPassword,
      );

      emit(const AuthAuthenticated());
    } catch (e) {
      emit(AuthFirstLoginResetError(e.toString()));
    }
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<AuthState> emit,
  ) {
    obscurePassword = !obscurePassword;

    emit(
      PasswordVisibilityState(
        obscurePassword: obscurePassword,
        isLoading: false,
      ),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading(obscurePassword: obscurePassword));

    try {
      final result = await _authRepository.register(
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
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _authRepository.logout();

    emit(const AuthUnauthenticated());
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(obscurePassword: obscurePassword));

    try {
      final result = await _authRepository.forgotPassword(event.email);

      emit(
        AuthForgotPasswordSent(
          message: result.message,
          resetToken: result.resetToken,
          expiresIn: result.expiresIn,
          email: event.email,
        ),
      );
    } catch (e) {
      emit(AuthForgotPasswordError(e.toString()));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(obscurePassword: obscurePassword));

    try {
      await _authRepository.resetPassword(
        email: event.email,
        code: event.code,
        newPassword: event.newPassword,
      );

      emit(
        AuthResetPasswordSuccess(
          'Password reset successful! You can now log in with your new password.',
        ),
      );
    } catch (e) {
      emit(AuthResetPasswordError(e.toString()));
    }
  }

  void _onSwitchMode(SwitchModeEvent event, Emitter<AuthState> emit) {
    final current = state;
    if (current is AuthError) {
      emit(
        AuthError(
          current.message,
          obscurePassword: current.obscurePassword,
          currentMode: event.mode,
        ),
      );
    } else if (current is AuthMustResetPassword) {
      emit(
        AuthMustResetPassword(
          userId: current.userId,
          email: current.email,
          message: current.message,
          currentMode: event.mode,
        ),
      );
    } else if (current is AuthLoading) {
      emit(
        AuthLoading(
          obscurePassword: current.obscurePassword,
          currentMode: event.mode,
        ),
      );
    } else {
      emit(AuthInitial(currentMode: event.mode));
    }
  }

  void _onSignupNameChanged(
      SignupNameChanged event, Emitter<AuthState> emit) {
    emit(state.copyWithSignup(name: event.name));
  }

  void _onSignupEmailChanged(
      SignupEmailChanged event, Emitter<AuthState> emit) {
    emit(state.copyWithSignup(email: event.email));
  }

  void _onSignupPasswordChanged(
      SignupPasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWithSignup(password: event.password));
  }

  void _onSignupRoleChanged(
      SignupRoleChanged event, Emitter<AuthState> emit) {
    emit(state.copyWithSignup(roleId: event.roleId));
  }

  void _onSignupCompanyChanged(
      SignupCompanyChanged event, Emitter<AuthState> emit) {
    emit(state.copyWithSignup(companyId: event.companyId));
  }

  void _onSignupDeptChanged(
      SignupDeptChanged event, Emitter<AuthState> emit) {
    emit(state.copyWithSignup(deptId: event.deptId));
  }
}
