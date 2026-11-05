import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

/// A breadcrumb widget that displays the current route hierarchy.
///
/// `TBreadcrumbs` reads the [TRouteMeta.breadcrumbs] trail that
/// `toGoRoutes()` attaches to every route, so it needs no item list.
/// Segments of a parameterized route (e.g. `/explorer/:path(.*)`) beyond the
/// static part are appended, labeled from the `labels` passed via `tGo()`.
///
/// ```dart
/// const TBreadcrumbs()
/// ```
class TBreadcrumbs extends StatelessWidget {
  /// Custom text style for the breadcrumb links.
  final TextStyle? style;

  /// The color of the last (active) breadcrumb item.
  final Color? activeColor;

  /// The widget used as a separator between items.
  final Widget separator;

  /// The label of a leading home item. When null no home item is added and the
  /// first item of the route trail is the first crumb.
  final String? homeLabel;

  /// The route for the home item.
  final String homeRoute;

  /// Whether to show each item's icon before its label.
  final bool showIcons;

  /// Creates a breadcrumb widget.
  const TBreadcrumbs({
    super.key,
    this.style,
    this.activeColor,
    this.separator = const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('/', style: TextStyle(color: Colors.grey)),
    ),
    this.homeLabel,
    this.homeRoute = '/',
    this.showIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.leafRouteState;
    final location = state.matchedLocation;
    final labelsObj = state.extra is Map<String, Object> ? (state.extra as Map<String, Object>)['labels'] : null;
    final labels = labelsObj is Map<String, String> ? labelsObj : <String, String>{};

    final crumbs = <({String label, String? route, Object? icon})>[];
    if (homeLabel != null) crumbs.add((label: homeLabel!, route: homeRoute, icon: null));

    final trail = (state.metadata[TRouteMeta.breadcrumbs] as List?)?.cast<Map<String, Object?>>() ?? const [];
    var consumed = '';
    for (final entry in trail) {
      final raw = entry[TRouteMeta.route] as String?;
      // Route groups (no page) are shown but not navigable.
      final hasPage = entry[TRouteMeta.hasPage] as bool? ?? true;
      // A parameterized route is only navigable up to its static prefix.
      final route = hasPage ? raw?.split('/').takeWhile((s) => !s.startsWith(':')).join('/') : null;
      if (route != null) consumed = route;
      crumbs.add((label: entry[TRouteMeta.title] as String? ?? raw?.split('/').last.capitalize() ?? '', route: route, icon: entry[TRouteMeta.icon]));
    }

    // Segments the route pattern captured (e.g. `:path(.*)`) become extra crumbs.
    if (location.startsWith(consumed) && location.length > consumed.length) {
      var path = consumed;
      for (final segment in location.substring(consumed.length).split('/').where((s) => s.isNotEmpty)) {
        path += '/$segment';
        crumbs.add((label: labels[segment] ?? segment.capitalize(), route: path, icon: null));
      }
    }

    final widgets = <Widget>[];
    for (var i = 0; i < crumbs.length; i++) {
      if (i > 0) widgets.add(separator);
      final c = crumbs[i];
      widgets.add(_buildItem(context, c.label, c.route, i == crumbs.length - 1, state, showIcons ? c.icon : null));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisSize: MainAxisSize.min, children: widgets),
    );
  }

  Widget _buildItem(BuildContext context, String label, String? route, bool isLast, GoRouterState state, Object? icon) {
    final colors = context.colors;
    final color = isLast ? (activeColor ?? colors.primary) : colors.onSurfaceVariant;

    return InkWell(
      // Parts without a route are not navigable.
      onTap: isLast || route == null ? null : () => context.go(route, extra: state.extra),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[TIcon.raw(icon, color: color, size: 16), const SizedBox(width: 6)],
            Text(
              label,
              style: style?.copyWith(color: color) ??
                  TextStyle(color: color, fontSize: 16, fontWeight: isLast ? FontWeight.w400 : FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}
