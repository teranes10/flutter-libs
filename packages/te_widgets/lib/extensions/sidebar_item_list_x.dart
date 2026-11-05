import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

/// Keys of the metadata [SidebarItemListX.toGoRoutes] attaches to every route (read via `GoRouterState.metadata`).
abstract final class TRouteMeta {
  static const title = 'title';
  static const icon = 'icon';
  static const info = 'info';
  static const hidden = 'hidden';
  static const route = 'route';

  /// Whether the trail entry renders a page (otherwise it is only a route group and not navigable).
  static const hasPage = 'hasPage';

  /// Ancestor trail ending at the route itself: a list of maps keyed by [title], [icon], [route] and [hasPage].
  static const breadcrumbs = 'breadcrumbs';
}

extension SidebarItemListX on List<TSidebarItem> {
  List<GoRoute> toGoRoutes() {
    final resolvedItems = TSidebarItemsResolver.resolve(this);
    return _buildRoutes(resolvedItems);
  }

  List<GoRoute> _buildRoutes(List<TSidebarItem> items, {String? parentPath, List<Map<String, Object?>> trail = const []}) {
    List<GoRoute> routes = [];

    for (var item in items) {
      String? originalPath = item.route;
      String? path = originalPath;

      if (path != null && parentPath != null) {
        if (path.startsWith(parentPath)) {
          path = path.substring(parentPath.length);
        } else if (path.startsWith('/')) {
          // Absolute child but not matching parent - force it to be nested anyway
          path = path.substring(1);
        }

        if (path.startsWith('/')) {
          path = path.substring(1);
        }
      }

      if (parentPath == null && path != null && !path.startsWith('/')) {
        path = '/$path';
      }

      // Routeless items stay in the trail (route null) so breadcrumbs can show them without a link.
      final itemTrail = [
        ...trail,
        {
          TRouteMeta.title: item.text,
          TRouteMeta.icon: item.icon,
          TRouteMeta.route: item.route,
          TRouteMeta.hasPage: item.builder != null || item.page != null,
        },
      ];
      final children =
          item.children != null ? _buildRoutes(item.children!, parentPath: originalPath, trail: itemTrail) : <GoRoute>[];

      if (path != null) {
        routes.add(
          GoRoute(
            path: path,
            name: item.text,
            // Always set every key (null included) so a child never inherits its parent's value.
            metadata: {
              TRouteMeta.title: item.text,
              TRouteMeta.icon: item.icon,
              TRouteMeta.info: item.info,
              TRouteMeta.hidden: item.hidden,
              TRouteMeta.breadcrumbs: itemTrail,
            },
            pageBuilder: (context, state) {
              final child = item.builder?.call(context, state) ?? item.page ?? PlaceholderPage(title: item.text ?? '404');
              return NoTransitionPage(child: child);
            },
            routes: children,
          ),
        );
      } else if (children.isNotEmpty) {
        routes.addAll(children);
      }
    }

    return routes;
  }
}
