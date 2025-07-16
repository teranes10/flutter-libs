import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/router.dart';
import 'package:te_widgets/configs/theme/theme.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: getTLightTheme(),
      darkTheme: getTDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
