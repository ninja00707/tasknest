import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasknest/injection.dart' hide storage;
import 'package:tasknest/core/constant/api_client.dart'; // Import ApiClient
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:tasknest/core/routes/app_router.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository)),
        BlocProvider<DashboardBloc>(create: (_) => createDashboardBloc()),
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
