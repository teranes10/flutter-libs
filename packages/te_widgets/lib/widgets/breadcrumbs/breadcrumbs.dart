import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

/// A breadcrumb widget that displays the current route hierarchy.
///
/// `TBreadcrumbs` uses [GoRouter] location and a list of [TSidebarItem]s
/// to generate a sequence of clickable navigation links.
///
/// ## Basic Usage
///
/// ```dart
/// TBreadcrumbs(
///   items: sidebarItems,
/// )
/// ```
class TBreadcrumbs extends StatelessWidget {
  /// The list of sidebar items used to look up labels for routes.
  final List<TSidebarItem> items;

  /// Custom text style for the breadcrumb links.
  final TextStyle? style;

  /// The color of the last (active) breadcrumb item.
  final Color? activeColor;

  /// The widget used as a separator between items.
  ///
  /// Defaults to a chevron right icon.
  final Widget separator;

  /// Whether to include a "Home" item at the beginning.
  final bool includeHome;

  /// The label for the home item.
  final String homeLabel;

  /// The route for the home item.
  final String homeRoute;

  /// Creates a breadcrumb widget.
  const TBreadcrumbs({
    super.key,
    required this.items,
    this.style,
    this.activeColor,
    this.separator = const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('/', style: TextStyle(color: Colors.grey)),
    ),
    this.includeHome = true,
    this.homeLabel = 'Home',
    this.homeRoute = '/',
  });

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final location = state.matchedLocation;
    final pathSegments = location.split('/').where((s) => s.isNotEmpty).toList();
    final labelsObj = state.extra is Map<String, Object> ? (state.extra as Map<String, Object>)['labels'] : null;
    Map<String, String> labels = labelsObj is Map<String, String> ? labelsObj : <String, String>{};

    List<Widget> breadcrumbWidgets = [];

    if (includeHome) {
      breadcrumbWidgets.add(_buildItem(context, homeLabel, homeRoute, location == homeRoute, state));
    }

    String currentPath = '';
    for (int i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];
      currentPath += '/$segment';
      final isLast = i == pathSegments.length - 1;

      // Skip adding if it's the home route and we already added home
      if (includeHome && currentPath == homeRoute) continue;

      if (breadcrumbWidgets.isNotEmpty) {
        breadcrumbWidgets.add(separator);
      }

      // Try to find a label in extra, or capitalize segment
      String label = labels[segment] ?? _findItemByRoute(items, currentPath)?.text ?? segment.capitalize();

      breadcrumbWidgets.add(_buildItem(context, label, currentPath, isLast, state));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: breadcrumbWidgets,
      ),
    );
  }

  Widget _buildItem(BuildContext context, String label, String route, bool isLast, GoRouterState state) {
    final colors = context.colors;
    final color = isLast ? (activeColor ?? colors.primary) : colors.onSurfaceVariant;

    return InkWell(
      onTap: isLast ? null : () => context.go(route, extra: state.extra),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: style?.copyWith(color: color) ??
              TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: isLast ? FontWeight.w400 : FontWeight.w300,
              ),
        ),
      ),
    );
  }

  TSidebarItem? _findItemByRoute(List<TSidebarItem> items, String route) {
    for (var item in items) {
      if (item.route == null) continue;

      // Exact match
      if (item.route == route) return item;

      // Handle parameterized routes in TSidebarItem
      // e.g., if item.route is '/explorer/:path(.*)' and route is '/explorer/a/b'
      // if (item.route!.contains(':')) {
      //   final itemSegments = item.route!.split('/').where((s) => s.isNotEmpty).toList();
      //   final routeSegments = route.split('/').where((s) => s.isNotEmpty).toList();

      //   if (itemSegments.length <= routeSegments.length) {
      //     bool match = true;
      //     for (int i = 0; i < itemSegments.length; i++) {
      //       if (!itemSegments[i].startsWith(':') && itemSegments[i] != routeSegments[i]) {
      //         match = false;
      //         break;
      //       }
      //     }
      //     if (match) return item;
      //   }
      // }

      if (item.children != null) {
        final found = _findItemByRoute(item.children!, route);
        if (found != null) return found;
      }
    }
    return null;
  }
}
