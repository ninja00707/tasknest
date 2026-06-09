import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/core/constant/api_constant.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

// AuthRemoteDataSource uses the singleton ApiClient instance.
class AuthRemoteDataSource {
  final ApiClient apiClient = ApiClient();

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await apiClient.post(
        ApiConstants.login,
        body: {'email': email, 'password': password},
      );

      // Ensure we extract the data correctly
      Map<String, dynamic> jsonMap;
      if (data is Map<String, dynamic>) {
        jsonMap = data.containsKey('data') ? data['data'] : data;
      } else {
        throw Exception('Invalid server response format');
      }

      return AuthResponseModel.fromJson(jsonMap);
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
