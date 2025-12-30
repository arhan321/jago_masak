import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'core/routes.dart';

void main() {
  runApp(const JagoMasakApp());
}

class JagoMasakApp extends StatelessWidget {
  const JagoMasakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jago Masak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: Routes.login,
      routes: appRoutes,
    );
  }
}
