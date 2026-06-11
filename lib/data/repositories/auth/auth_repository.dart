import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String code,
    required String password,
  });

  Future<Map<String, dynamic>> firstLoginReset({
    required int userId,
    required String email,
    required String newPassword,
  });

  Future<RegistrationResult> register({
    required String name,
    required String email,
    required String password,
    required int companyId,
    required int departmentId,
    required int role,
  });

  Future<void> logout();

  Future<ForgotPasswordResult> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}

class ForgotPasswordResult {
  final String message;
  final String? resetToken;
  final int expiresIn;

  ForgotPasswordResult({
    required this.message,
    this.resetToken,
    required this.expiresIn,
  });
}
