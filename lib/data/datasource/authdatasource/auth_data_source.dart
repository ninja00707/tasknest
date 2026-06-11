import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/core/constant/api_constant.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

// AuthRemoteDataSource uses the singleton ApiClient instance.
class AuthRemoteDataSource {
  final ApiClient apiClient = ApiClient();

  Future<Map<String, dynamic>> login({
    required String code,
    required String password,
  }) async {
    try {
      // If input contains @, treat as email; otherwise treat as employee code
      final isEmail = code.contains('@');
      final body = isEmail
          ? {'email': code, 'password': password}
          : {'code': code, 'password': password};

      final data = await apiClient.post(
        ApiConstants.login,
        body: body,
      );

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid server response format');
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> firstLoginReset({
    required int userId,
    required String email,
    required String newPassword,
  }) async {
    try {
      final data = await apiClient.post(
        '/auth/first-login-reset',
        body: {
          'userId': userId,
          'email': email,
          'newPassword': newPassword,
        },
      );

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid server response format');
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<RegistrationResult> register({
    required String name,
    required String email,
    required String password,
    required int companyId,
    required int departmentId,
    required int role,
  }) async {
    try {
      final data = await apiClient.post(
        ApiConstants.register,
        body: {
          'name': name,
          'email': email,
          'password_hash': password,
          'company_id': companyId,
          'department_id': departmentId,
          'role_id': role,
        },
      );

      if (data is! Map<String, dynamic>) {
        throw Exception('Registration failed: Invalid response');
      }

      return RegistrationResult.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await apiClient.post(
        '/auth/forgot-password',
        body: {'email': email},
      );

      Map<String, dynamic> result = {};
      if (response is Map<String, dynamic>) {
        // Include top-level message
        if (response.containsKey('message')) {
          result['message'] = response['message'];
        }
        // Include data sub-object fields
        if (response.containsKey('data') && response['data'] is Map) {
          final data = response['data'] as Map<String, dynamic>;
          if (data.containsKey('resetToken')) {
            result['resetToken'] = data['resetToken'];
          }
          if (data.containsKey('expiresIn')) {
            result['expiresIn'] = data['expiresIn'];
          }
        }
      } else {
        throw Exception('Invalid server response');
      }

      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await apiClient.post(
        '/auth/reset-password',
        body: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
