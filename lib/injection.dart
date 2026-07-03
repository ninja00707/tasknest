import 'package:get_it/get_it.dart';
import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/data/datasource/authdatasource/auth_data_source.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/datasource/ticketdatasource/notification_remote_data_source.dart';
import 'package:tasknest/data/datasource/ticketdatasource/ticket_remote_data_source.dart';
import 'package:tasknest/domain/repositories_impl/auth_impl/auth_impl.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/presentation/admin/data/datasource/admin_remote_data_source.dart';
import 'package:tasknest/presentation/admin/domain/repositories_impl/admin_repository_impl.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core ──
  sl.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // ── Data Sources ──
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());
  sl.registerLazySingleton<TicketRemoteDataSource>(
    () => TicketRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSource(sl<ApiClient>()),
  );

  // ── Repositories ──
  sl.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localStorageService: sl<LocalStorageService>(),
    ),
  );
  sl.registerLazySingleton<TicketRepositoryImpl>(
    () => TicketRepositoryImpl(
      sl<TicketRemoteDataSource>(),
      sl<NotificationRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<AdminRepositoryImpl>(
    () => AdminRepositoryImpl(sl<AdminRemoteDataSource>()),
  );

  // ── BLoCs (not singletons — new instance per page) ──
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepositoryImpl>()));
  sl.registerFactory<DashboardBloc>(
    () => DashboardBloc(sl<TicketRepositoryImpl>()),
  );
  sl.registerFactory<AdminBloc>(() => AdminBloc(sl<AdminRepositoryImpl>()));
  sl.registerFactory<TicketBloc>(() => TicketBloc(sl<TicketRepositoryImpl>()));
}
