import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String companyId,
    required String departmentId,
    required String role,
  });

  Future<void> logout();
}
