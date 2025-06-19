import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/pages/buttons_page.dart';
import 'package:my_app/pages/chips_page.dart';
import 'package:my_app/pages/crud_page.dart';
import 'package:my_app/pages/forms_page.dart';
import 'package:my_app/pages/input_fields_page.dart';
import 'package:my_app/pages/popups_page.dart';
import 'package:my_app/pages/select_fields_page.dart';
import 'package:my_app/pages/selections_page.dart';
import 'package:my_app/pages/tables_page.dart';
import 'package:te_widgets/te_widgets.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/input-fields',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: getLayout,
      routes: sidebarItems.toGoRoutes(),
    ),
  ],
);

final sidebarItems = [
  TSidebarItem(icon: Icons.list_alt, text: 'Input Fields', route: '/input-fields', page: InputFieldsPage()),
  TSidebarItem(icon: Icons.list_alt, text: 'Select Fields', route: '/select-fields', page: SelectFieldsPage()),
  TSidebarItem(icon: Icons.list_alt, text: 'Buttons', route: '/buttons', page: ButtonsPage()),
  TSidebarItem(icon: Icons.list_alt, text: 'Selections', route: '/selections', page: SelectionsPage()),
  TSidebarItem(icon: Icons.list_alt, text: 'Chips', route: '/chips', page: ChipsPage()),
  TSidebarItem(icon: Icons.list_alt, text: 'Popups', route: '/popups', page: PopupsPage()),
  TSidebarItem(icon: Icons.list_alt, text: 'Tables', route: '/tables', page: TablesPage()),
  TSidebarItem(icon: Icons.list_alt, text: 'Crud', route: '/crud', page: CrudPage()),
  TSidebarItem(icon: Icons.list_alt, text: 'Forms', route: '/forms', page: FormsPage()),
  TSidebarItem(icon: Icons.list_alt, text: 'Item', children: [
    TSidebarItem(icon: Icons.list_alt, text: 'Sub Item', children: [
      TSidebarItem(icon: Icons.list_alt, text: 'Sub Sub Item', route: '/test', page: FormsPage()),
    ])
  ]),
];

Widget getLayout(context, GoRouterState state, child) {
  return TLayout(
    logo: TLogo(text: 'Te Widgets'),
    profile: Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 15,
      runSpacing: 5,
      children: [
        TProfile(icon: 'assets/icons/profile.png', text: 'Teranes'),
        TButton(
          type: TButtonType.icon,
          icon: Icons.logout_rounded,
          color: AppColors.grey,
          onPressed: (_) {},
        )
      ],
    ),
    items: sidebarItems,
    pageTitle: state.name,
    child: child,
  );
}
