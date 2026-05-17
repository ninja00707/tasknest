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
    final response = await apiClient.dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await apiClient.dio.post(
      ApiConstants.register,
      data: {'name': name, 'email': email, 'password': password},
    );

    return AuthResponseModel.fromJson(response.data);
  }
}
