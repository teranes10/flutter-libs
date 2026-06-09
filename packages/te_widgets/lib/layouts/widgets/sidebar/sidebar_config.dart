import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

class TSidebarItem {
  final IconData? icon;
  final String? text;
  final String? route;
  final Widget? page;
  final Widget Function(BuildContext context, GoRouterState state)? builder;
  final List<TSidebarItem>? children;
  final VoidCallback? onTap;
  final bool initiallyExpanded;
  final Object? extra;
  final bool hidden;
  final bool home;
  final int? bottomBarPosition;

  const TSidebarItem({
    this.page,
    this.builder,
    this.icon,
    this.text,
    this.route,
    this.children,
    this.onTap,
    this.initiallyExpanded = false,
    this.extra,
    this.hidden = false,
    this.home = false,
    this.bottomBarPosition,
  });

  TSidebarItem copyWith({
    Widget? page,
    Widget Function(BuildContext context, GoRouterState state)? builder,
    IconData? icon,
    String? text,
    String? route,
    List<TSidebarItem>? children,
    VoidCallback? onTap,
    bool? initiallyExpanded,
    Object? extra,
    bool? hidden,
    bool? home,
    int? bottomBarPosition,
  }) {
    return TSidebarItem(
      page: page ?? this.page,
      builder: builder ?? this.builder,
      icon: icon ?? this.icon,
      text: text ?? this.text,
      route: route ?? this.route,
      children: children ?? this.children,
      onTap: onTap ?? this.onTap,
      initiallyExpanded: initiallyExpanded ?? this.initiallyExpanded,
      extra: extra ?? this.extra,
      hidden: hidden ?? this.hidden,
      home: home ?? this.home,
      bottomBarPosition: bottomBarPosition ?? this.bottomBarPosition,
    );
  }

  @override
  String toString() => "$text -> $route";

  bool containsRoute(String currentRoute) {
    if (route == currentRoute) return true;
    return children?.any((child) => child.containsRoute(currentRoute)) ?? false;
  }

  bool get hasChildren => children?.isNotEmpty ?? false;
  bool get isClickable => route != null || onTap != null;

  void tap(BuildContext context) {
    _navigate(context);
    onTap?.call();
  }

  void _navigate(BuildContext context) {
    if (route == null) return;
    if (route!.containsInMiddle('/')) {
      context.push(route!, extra: extra);
    } else {
      context.go(route!, extra: extra);
    }
  }
}

class TSidebarConstants {
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration overlayAnimationDuration = Duration(milliseconds: 150);
  static const Duration hoverDelay = Duration(milliseconds: 200);
  static const Duration overlayHideDelay = Duration(milliseconds: 400);
  static const Duration smoothHideDelay = Duration(milliseconds: 400);

  static const double iconSize = 20.0;
  static const double overlayIconSize = 18.0;
  static const double expandIconSize = 16.0;
  static const double arrowIconSize = 12.0;

  static const EdgeInsets itemPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 14);
  static const EdgeInsets minimizedItemPadding = EdgeInsets.all(12);
  static const EdgeInsets overlayItemPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);
}

class TSidebarTheme {
  final Color defaultColor;
  final Color hoverColor;
  final Color activeColor;
  final Color activeBackgroundColor;
  final Color borderColor;

  const TSidebarTheme({
    required this.defaultColor,
    required this.hoverColor,
    required this.activeColor,
    required this.activeBackgroundColor,
    required this.borderColor,
  });

  factory TSidebarTheme.defaultTheme(BuildContext context) {
    final colors = context.colors;

    return TSidebarTheme(
      defaultColor: colors.onSurfaceVariant,
      hoverColor: colors.onSurface,
      activeColor: colors.onPrimaryContainer,
      activeBackgroundColor: colors.primaryContainer,
      borderColor: colors.outline,
    );
  }

  Color getItemColor({
    required bool isActive,
    required bool containsActive,
    required bool isHovered,
  }) {
    if (isActive || containsActive) return activeColor;
    if (isHovered) return hoverColor;
    return defaultColor;
  }
}

class TSidebarItemsResolver {
  /// Resolves relative paths and validates the sidebar item hierarchy.
  static List<TSidebarItem> resolve(List<TSidebarItem> items) {
    bool homeFound = false;
    final Set<String> routes = {};

    List<TSidebarItem> resolveInternal(List<TSidebarItem> items, {String? parentPath}) {
      return items.map((item) {
        // 1. Resolve Path
        String? resolvedRoute = item.route;

        if (resolvedRoute != null) {
          if (parentPath != null) {
            if (resolvedRoute.contains('/')) {
              throw ArgumentError(
                "TLayout: The child item's route '${item.route}' must be a single child path name only (no '/', no parent path, and no nested segments)",
              );
            }

            resolvedRoute = parentPath.endsWith('/') ? '$parentPath$resolvedRoute' : '$parentPath/$resolvedRoute';
          }
        }

        // 2. Validation: Multiple Homes
        if (item.home) {
          if (homeFound) {
            throw ArgumentError('TLayout: Multiple items marked as home. Only one item can be home.');
          }
          homeFound = true;
        }

        // 3. Validation: Bottom Bar Position
        if (item.bottomBarPosition != null) {
          if (item.bottomBarPosition! > 3) {
            throw ArgumentError('TLayout: Bottom bar position cannot be greater than 3.');
          }
          if (item.children?.isNotEmpty ?? false) {
            throw ArgumentError('TLayout: Bottom bar items cannot have children.');
          }
        }

        // 4. Validation: Duplicate Routes
        if (resolvedRoute != null && resolvedRoute.isNotEmpty && !resolvedRoute.contains(':')) {
          if (routes.contains(resolvedRoute)) {
            throw ArgumentError('TLayout: Duplicate route detected: $resolvedRoute');
          }
          routes.add(resolvedRoute);
        }

        // 5. Recursive children resolution
        final resolvedChildren = item.children != null ? resolveInternal(item.children!, parentPath: resolvedRoute) : null;

        return item.copyWith(
          route: resolvedRoute,
          children: resolvedChildren,
        );
      }).toList();
    }

    final resolvedItems = resolveInternal(items);

    // Default home if none found
    if (!homeFound && resolvedItems.isNotEmpty) {
      resolvedItems[0] = resolvedItems[0].copyWith(home: true);
    }

    return resolvedItems;
  }
}
