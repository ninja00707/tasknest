import 'package:tasknest/data/datasource/authdatasource/auth_data_source.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/repositories/auth/auth_repository.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalStorageService localStorageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorageService,
  });

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final result = await remoteDataSource.login(
      email: email,
      password: password,
    );

    await localStorageService.saveToken(result.token);

    return result;
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String companyId,
    required String departmentId,
    required String role,
  }) async {
    final result = await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      companyId: companyId,
      departmentId: departmentId,
      role: role,
    );

    await localStorageService.saveToken(result.token);

    return result;
  }

  @override
  Future<void> logout() async {
    await localStorageService.clearToken();
  }
}
