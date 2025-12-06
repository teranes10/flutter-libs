import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        return Consumer(
          builder: (context, ref, _) {
            final themeNotifier = ref.read(themeNotifierProvider.notifier);
            final sidebarMinified = ref.watch(sidebarNotifierProvider);

            return TLayout(
              isMinimized: sidebarMinified,
              logo: const TLogo(text: 'Te Widgets'), // Added const
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
