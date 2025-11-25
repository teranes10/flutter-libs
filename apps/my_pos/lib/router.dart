import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_pos/main_layout.dart';
import 'package:my_pos/screens/home_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final sidebarItems = [];

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      routes: [
        GoRoute(
          path: '/home',
          name: "Home",
          pageBuilder: (context, state) => NoTransitionPage(child: HomeScreen()),
        ),
      ],
      builder: (context, state, child) => MainLayout(child: child),
    ),
  ],
);
