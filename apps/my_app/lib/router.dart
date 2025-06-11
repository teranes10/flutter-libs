import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/pages/buttons_page.dart';
import 'package:my_app/pages/chips_page.dart';
import 'package:my_app/pages/input_fields_page.dart';
import 'package:my_app/pages/popups_page.dart';
import 'package:my_app/pages/select_fields_page.dart';
import 'package:my_app/pages/selections_page.dart';
import 'package:my_app/pages/tables_page.dart';
import 'package:te_widgets/layouts/layout.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_item.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_logo.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_profile.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/input-fields',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: getLayout,
      routes: [
        GoRoute(
          path: '/input-fields',
          name: 'Input Fields',
          pageBuilder: (context, state) => NoTransitionPage(child: InputFieldsPage()),
        ),
        GoRoute(
          path: '/select-fields',
          name: 'Select Fields',
          pageBuilder: (context, state) => NoTransitionPage(child: SelectFieldsPage()),
        ),
        GoRoute(
          path: '/buttons',
          name: 'Buttons',
          pageBuilder: (context, state) => NoTransitionPage(child: ButtonsPage()),
        ),
        GoRoute(
          path: '/chips',
          name: 'Chips',
          pageBuilder: (context, state) => NoTransitionPage(child: ChipsPage()),
        ),
        GoRoute(
          path: '/popups',
          name: 'Popups',
          pageBuilder: (context, state) => NoTransitionPage(child: PopupsPage()),
        ),
        GoRoute(
          path: '/selections',
          name: 'Selections',
          pageBuilder: (context, state) => NoTransitionPage(child: SelectionsPage()),
        ),
        GoRoute(
          path: '/tables',
          name: 'Tables',
          pageBuilder: (context, state) => NoTransitionPage(child: TablesPage()),
        ),
      ],
    ),
  ],
);

Widget getLayout(context, GoRouterState state, child) {
  return Layout(
    logo: SidebarLogo(text: 'Te Widgets'),
    profile: SidebarProfile(
      icon: 'assets/icons/profile.png',
      text: 'Teranes',
    ),
    items: [
      SidebarItem(
        icon: Icons.list_alt,
        text: 'Input Fields',
        routeName: '/input-fields',
      ),
      SidebarItem(
        icon: Icons.list_alt,
        text: 'Select Fields',
        routeName: '/select-fields',
      ),
      SidebarItem(
        icon: Icons.list_alt,
        text: 'Buttons',
        routeName: '/buttons',
      ),
      SidebarItem(
        icon: Icons.list_alt,
        text: 'Selections',
        routeName: '/selections',
      ),
      SidebarItem(
        icon: Icons.list_alt,
        text: 'Chips',
        routeName: '/chips',
      ),
      SidebarItem(
        icon: Icons.list_alt,
        text: 'Popups',
        routeName: '/popups',
      ),
      SidebarItem(
        icon: Icons.list_alt,
        text: 'Tables',
        routeName: '/tables',
      ),
    ],
    pageTitle: state.name,
    child: child,
  );
}
