import 'package:dio/dio.dart';
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

  Future<AuthResponseModel> register({
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
          'is_active': true,
        },
      );

      // Backend registration returns both user info and a token.
      // We wrap it in a Map that corresponds to what your model expects.
      Map<String, dynamic> jsonMap;
      if (data is Map<String, dynamic>) {
        jsonMap = data.containsKey('data') ? data['data'] : data;
      } else {
        throw Exception('Registration failed: Invalid response');
      }

      return AuthResponseModel.fromJson(jsonMap);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.post(
        '/auth/forgot-password', // Replace with ApiConstants.forgotPassword if available
        body: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }
}
