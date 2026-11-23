import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/navigation.dart';
import 'package:my_app/widgets/top_bar_extras.dart';
import 'package:te_widgets/te_widgets.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

const _options = [
  TSwitcherOption(id: 'acme', name: 'Acme Corp', subtitle: 'Production'),
  TSwitcherOption(id: 'globex', name: 'Globex', subtitle: 'Staging'),
  TSwitcherOption(id: 'initech', name: 'Initech', subtitle: 'Sandbox'),
];

/// Active workspace (sample context); a notifier so it survives route changes (the shell builder reruns on every navigation).
final _selected = ValueNotifier<String>('acme');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/forms/input-fields',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      routes: [
        GoRoute(path: '/', redirect: (_, _) => '/forms/input-fields'),
        ...sidebarItems.toGoRoutes(),
      ],
      builder: (context, state, child) {
        return ValueListenableBuilder<String>(
          valueListenable: _selected,
          builder: (context, selectedId, _) => TLayout(
            logo: const TLogo(text: 'Te Widgets'),
            minifiedLogo: const TLogo(text: 'Te'),
            switcher: (variant) =>
                TSwitcher(variant: variant, options: _options, selectedId: selectedId, onChanged: (w) => _selected.value = w.id),
            profile: TImage.profile(name: 'Teranes', role: 'Super Admin'),
            onLogout: () {
              // Handle logout
            },
            topBarCenter: const TopBarClock(),
            topBarTrailing: const TopBarStatus(),
            items: sidebarItems,
            pageTitle: state.name,
            child: child,
          ),
        );
      },
    ),
  ],
);
