import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/data/datasource/authdatasource/auth_data_source.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/domain/repositories_impl/auth_impl/auth_impl.dart';

final storage = LocalStorageService();

final apiClient = ApiClient();

final authRemoteDataSource = AuthRemoteDataSource(apiClient);

final authRepository = AuthRepositoryImpl(
  remoteDataSource: authRemoteDataSource,
  localStorageService: storage,
);
