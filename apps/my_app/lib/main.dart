import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/router.dart';
import 'package:te_widgets/configs/theme/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: teWidgetsTheme(context),
      routerConfig: _router,
    );
  }
}
