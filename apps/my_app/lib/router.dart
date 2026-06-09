import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/navigation.dart';
import 'package:te_widgets/te_widgets.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/input-fields',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      routes: sidebarItems.toGoRoutes(),
      builder: (context, state, child) {
        return TLayout(
          logo: const TLogo(text: 'Te Widgets'),
          profile: TImage.profile(name: 'Teranes', role: 'Super Admin'),
          onLogout: () {
            // Handle logout
          },
          items: sidebarItems,
          pageTitle: state.name,
          child: child,
        );
      },
    ),
  ],
);
