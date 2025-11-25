import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/pages/buttons_page.dart';
import 'package:my_app/pages/chips_page.dart';
import 'package:my_app/pages/crud_page.dart';
import 'package:my_app/pages/editor_page.dart';
import 'package:my_app/pages/forms_page.dart';
import 'package:my_app/pages/grid_page.dart';
import 'package:my_app/pages/input_fields_page.dart';
import 'package:my_app/pages/popups_page.dart';
import 'package:my_app/pages/select_fields_page.dart';
import 'package:my_app/pages/tables_page.dart';
import 'package:my_app/pages/test.dart';
import 'package:te_widgets/te_widgets.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final sidebarItems = [
  TSidebarItem(icon: Icons.line_style_rounded, text: 'Input Fields', route: '/input-fields', page: InputFieldsPage()),
  TSidebarItem(icon: Icons.line_style_rounded, text: 'Select Fields', route: '/select-fields', page: SelectFieldsPage()),
  TSidebarItem(icon: Icons.line_style_rounded, text: 'Buttons', route: '/buttons', page: ButtonsPage()),
  TSidebarItem(icon: Icons.line_style_rounded, text: 'Chips', route: '/chips', page: ChipsPage()),
  TSidebarItem(icon: Icons.line_style_rounded, text: 'Popups', route: '/popups', page: PopupsPage()),
  TSidebarItem(icon: Icons.line_style_rounded, text: 'Tables', route: '/tables', page: TablesPage()),
  TSidebarItem(icon: Icons.line_style_rounded, text: 'Grid', route: '/grid', page: GridPage()),
  TSidebarItem(icon: Icons.line_style_rounded, text: 'Crud', route: '/crud', page: CrudPage()),
  TSidebarItem(icon: Icons.line_style_rounded, text: 'Editor', route: '/editor', page: EditorPage()),
  TSidebarItem(icon: Icons.line_style_rounded, text: 'Forms', route: '/forms', page: FormsPage()),
  TSidebarItem(icon: Icons.line_style_rounded, text: 'Item', children: [
    TSidebarItem(icon: Icons.line_style_rounded, text: 'Sub Item', children: [
      TSidebarItem(icon: Icons.line_style_rounded, text: 'Sub Sub Item', route: '/test', page: FormsPage()),
    ]),
    TSidebarItem(icon: Icons.line_style_rounded, text: 'Sub Item', children: [
      TSidebarItem(icon: Icons.line_style_rounded, text: 'Sub Sub Item 2', route: '/test2', page: FormsPage()),
    ]),
    TSidebarItem(icon: Icons.line_style_rounded, text: 'Doc', route: '/doc', page: TButtonDocumentationPage()),
  ]),
];

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/input-fields',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      routes: sidebarItems.toGoRoutes(),
      builder: (context, state, child) {
        return Consumer(
          builder: (context, ref, _) {
            final themeNotifier = ref.read(themeNotifierProvider.notifier);
            final sidebarMinified = ref.watch(sidebarNotifierProvider);

            return TLayout(
              isMinimized: sidebarMinified,
              logo: TLogo(text: 'Te Widgets'),
              profile: TImage.profile(name: 'Teranes', role: 'Super Admin'),
              actions: [
                TButton(
                    size: TButtonSize.xs.copyWith(icon: 16),
                    type: TButtonType.icon,
                    icon: Icons.wb_sunny,
                    color: Colors.yellow.shade700,
                    activeIcon: Icons.nights_stay,
                    activeColor: Colors.cyan.shade600,
                    active: context.isDarkMode,
                    onChanged: (_) => themeNotifier.toggleTheme()),
                TButton(
                    type: TButtonType.icon,
                    icon: Icons.logout_rounded,
                    size: TButtonSize.xs.copyWith(icon: 16),
                    color: AppColors.grey,
                    onPressed: (_) {}),
              ],
              items: sidebarItems,
              pageTitle: state.name,
              child: child,
            );
          },
        );
      },
    ),
  ],
);
