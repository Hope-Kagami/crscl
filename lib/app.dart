import 'package:flutter/material.dart';
import 'features/splash_screen.dart';
import 'features/auth/login/login_screen.dart';
import 'features/home/home_screen.dart';
import 'core/theme.dart';

class CRSCLApp extends StatelessWidget {
  const CRSCLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRSCL',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
