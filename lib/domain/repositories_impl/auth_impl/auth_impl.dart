import 'package:tasknest/data/datasource/authdatasource/auth_data_source.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/repositories/auth/auth_repository.dart';
import 'package:tasknest/presentation/login/models/auth_response_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalStorageService localStorageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorageService,
  });

  @override
  Future<Map<String, dynamic>> login({
    required String code,
    required String password,
  }) async {
    final result = await remoteDataSource.login(
      code: code,
      password: password,
    );

    // If mustResetPassword, don't save token yet
    if (result['mustResetPassword'] == true) {
      return result;
    }

    // Extract data sub-object
    final data = result['data'] as Map<String, dynamic>? ?? result;

    // SAVE TOKEN
    if (data['token'] != null) {
      await localStorageService.setToken(data['token']);
    }

    // SAVE USER
    if (data['user'] != null) {
      final user = AuthResponseModel.fromJson(data).user;
      await localStorageService.setUser(user);
    }

    return result;
  }

  @override
  Future<Map<String, dynamic>> firstLoginReset({
    required int userId,
    required String email,
    required String newPassword,
  }) async {
    final result = await remoteDataSource.firstLoginReset(
      userId: userId,
      email: email,
      newPassword: newPassword,
    );

    // Save token and user from successful reset
    final data = result['data'] as Map<String, dynamic>? ?? result;
    if (data['token'] != null) {
      await localStorageService.setToken(data['token']);
    }
    if (data['user'] != null) {
      final user = AuthResponseModel.fromJson(data).user;
      await localStorageService.setUser(user);
    }

    return result;
  }

  @override
  Future<RegistrationResult> register({
    required String name,
    required String email,
    required String password,
    required int companyId,
    required int departmentId,
    required int role,
  }) async {
    final result = await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      companyId: companyId,
      departmentId: departmentId,
      role: role,
    );

    if (!result.pendingApproval && result.authResponse != null) {
      await localStorageService.setToken(result.authResponse!.token);
      await localStorageService.setUser(result.authResponse!.user);
    }

    return result;
  }

  @override
  Future<void> logout() async {
    await localStorageService.clearToken();
  }

  @override
  Future<ForgotPasswordResult> forgotPassword(String email) async {
    final result = await remoteDataSource.forgotPassword(email);
    return ForgotPasswordResult(
      message: result['message'],
      resetToken: result['resetToken'],
      expiresIn: result['expiresIn'],
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await remoteDataSource.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }
}
