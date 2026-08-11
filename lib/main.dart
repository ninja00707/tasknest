import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/injection.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/domain/repositories_impl/project_impl/project_impl.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/create_ticket_module/bloc/create_ticket_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/recent_activities/bloc/recent_activities_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';
import 'package:tasknest/presentation/ticket_card_module/bloc/ticket_card_bloc.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:tasknest/core/routes/app_router.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart' show AuthBloc;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<DashboardBloc>(create: (_) => sl<DashboardBloc>()),
        BlocProvider<AdminBloc>(create: (_) => sl<AdminBloc>()),
        BlocProvider<TicketBloc>(create: (_) => sl<TicketBloc>()),
        BlocProvider<RecentActivitiesBloc>(
          create: (_) => sl<RecentActivitiesBloc>(),
        ),
        BlocProvider<TicketCardBloc>(create: (_) => TicketCardBloc()),
        BlocProvider<CreateTicketBloc>(
          create: (_) => CreateTicketBloc(sl<TicketRepositoryImpl>()),
        ),
        BlocProvider<ProjectBloc>(
          create: (_) => ProjectBloc(sl<ProjectRepositoryImpl>()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        builder: (context, child) {
          return child ?? const SizedBox();
        },
      ),
    );
  }
}
