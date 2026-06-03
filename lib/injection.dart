import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/data/datasource/authdatasource/auth_data_source.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/datasource/ticketdatasource/ticket_remote_data_source.dart';
import 'package:tasknest/domain/repositories_impl/auth_impl/auth_impl.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';

// ── Storage & API ─────────────────────────────────────────────────────────────
final storage = LocalStorageService();
final apiClient = ApiClient();

// ── Auth ──────────────────────────────────────────────────────────────────────
final authRemoteDataSource = AuthRemoteDataSource();
final authRepository = AuthRepositoryImpl(
  remoteDataSource: authRemoteDataSource,
  localStorageService: storage,
);

// ── Tickets ───────────────────────────────────────────────────────────────────
final ticketRemoteDataSource = TicketRemoteDataSource(apiClient);

// Factory: create a new DashboardBloc whenever needed
DashboardBloc createDashboardBloc() => DashboardBloc(ticketRemoteDataSource);
