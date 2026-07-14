// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:tasknest/core/constant/api_client.dart' as _i365;
import 'package:tasknest/data/datasource/authdatasource/auth_data_source.dart'
    as _i91;
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart'
    as _i298;
import 'package:tasknest/data/datasource/notification/notification_remote_data_source.dart'
    as _i346;
import 'package:tasknest/data/datasource/ticketdatasource/ticket_remote_data_source.dart'
    as _i407;
import 'package:tasknest/domain/repositories_impl/auth_impl/auth_impl.dart'
    as _i321;
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart'
    as _i865;
import 'package:tasknest/presentation/admin/data/datasource/admin_remote_data_source.dart'
    as _i1039;
import 'package:tasknest/presentation/admin/domain/repositories_impl/admin_repository_impl.dart'
    as _i470;
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart'
    as _i718;
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart'
    as _i720;
import 'package:tasknest/presentation/login/bloc/login_bloc.dart' as _i406;
import 'package:tasknest/presentation/notification/bloc/notification_bloc.dart'
    as _i248;
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart' as _i809;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i365.ApiClient>(() => _i365.ApiClient());
    gh.lazySingleton<_i298.LocalStorageService>(
      () => _i298.LocalStorageService(),
    );
    gh.lazySingleton<_i346.NotificationRemoteDataSource>(
      () => _i346.NotificationRemoteDataSource(gh<_i365.ApiClient>()),
    );
    gh.lazySingleton<_i407.TicketRemoteDataSource>(
      () => _i407.TicketRemoteDataSource(gh<_i365.ApiClient>()),
    );
    gh.lazySingleton<_i1039.AdminRemoteDataSource>(
      () => _i1039.AdminRemoteDataSource(gh<_i365.ApiClient>()),
    );
    gh.lazySingleton<_i91.AuthRemoteDataSource>(
      () => _i91.AuthRemoteDataSource(gh<_i365.ApiClient>()),
    );
    gh.lazySingleton<_i865.TicketRepositoryImpl>(
      () => _i865.TicketRepositoryImpl(
        gh<_i407.TicketRemoteDataSource>(),
        gh<_i346.NotificationRemoteDataSource>(),
      ),
    );
    gh.factory<_i720.DashboardBloc>(
      () => _i720.DashboardBloc(gh<_i865.TicketRepositoryImpl>()),
    );
    gh.factory<_i809.TicketBloc>(
      () => _i809.TicketBloc(gh<_i865.TicketRepositoryImpl>()),
    );
    gh.lazySingleton<_i321.AuthRepositoryImpl>(
      () => _i321.AuthRepositoryImpl(
        remoteDataSource: gh<_i91.AuthRemoteDataSource>(),
        localStorageService: gh<_i298.LocalStorageService>(),
      ),
    );
    gh.lazySingleton<_i470.AdminRepositoryImpl>(
      () => _i470.AdminRepositoryImpl(gh<_i1039.AdminRemoteDataSource>()),
    );
    gh.factory<_i718.AdminBloc>(
      () => _i718.AdminBloc(gh<_i470.AdminRepositoryImpl>()),
    );
    gh.factory<_i248.NotificationBloc>(
      () => _i248.NotificationBloc(gh<_i865.TicketRepositoryImpl>()),
    );
    gh.factory<_i406.AuthBloc>(
      () => _i406.AuthBloc(gh<_i321.AuthRepositoryImpl>()),
    );
    return this;
  }
}
