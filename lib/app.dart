import 'package:flutter/material.dart';
import 'features/splash_screen.dart';
import 'core/theme.dart';

class CRSCLApp extends StatelessWidget {
  const CRSCLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRSCL',
      theme: appTheme,
      home: const SplashScreen(),
    );
  }
}
