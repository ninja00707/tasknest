import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/routes/app_router.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:tasknest/presentation/login/auth_server_example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  final storage = LocalStorageService();

  final token = await storage.getToken();
  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => LoginBloc(AuthService()))],

      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,

        routerConfig: appRouter,
      ),
    );
  }
}
