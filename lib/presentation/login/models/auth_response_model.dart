import 'package:tasknest/presentation/login/models/user_model.dart';

class AuthResponseModel {
  final String token;
  final UserModel user;

  AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class RegistrationResult {
  final bool pendingApproval;
  final String message;
  final AuthResponseModel? authResponse;

  RegistrationResult({
    required this.pendingApproval,
    required this.message,
    this.authResponse,
  });

  factory RegistrationResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final pending = data['pendingApproval'] == true;
    if (pending) {
      return RegistrationResult(
        pendingApproval: true,
        message:
            data['message'] ?? 'Registration submitted for admin approval.',
        authResponse: null,
      );
    }
    return RegistrationResult(
      pendingApproval: false,
      message: json['message'] ?? 'User registered successfully',
      authResponse: AuthResponseModel.fromJson(data),
    );
  }
}
