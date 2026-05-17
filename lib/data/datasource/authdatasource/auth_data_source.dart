import 'package:dio/dio.dart';
import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/core/constant/api_constant.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      // The backend returns { success: true, message: ..., data: { token, user } }
      // So we pass response.data['data'] or fallback to response.data if it's the old format
      final responseData = response.data['data'] ?? response.data;
      return AuthResponseModel.fromJson(responseData);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        // Extract the clean backend message (e.g. "User not found") instead of raw Dio 404 string
        throw Exception(e.response?.data['message'] ?? e.message);
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String companyId,
    required String departmentId,
    required String role,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'company_id': int.tryParse(companyId),
          'department_id': int.tryParse(departmentId),
          'role': role, // default role
        },
      );

      final responseData = response.data['data'] ?? response.data;
      return AuthResponseModel.fromJson(responseData);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? e.message);
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/forgot-password', // Replace with ApiConstants.forgotPassword if available
        data: {'email': email},
      );

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to send reset link',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? e.message);
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
