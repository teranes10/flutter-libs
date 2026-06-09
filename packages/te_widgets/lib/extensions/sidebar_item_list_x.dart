import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

extension SidebarItemListX on List<TSidebarItem> {
  List<GoRoute> toGoRoutes() {
    final resolvedItems = TSidebarItemsResolver.resolve(this);
    return _buildRoutes(resolvedItems);
  }

  List<GoRoute> _buildRoutes(List<TSidebarItem> items, {String? parentPath}) {
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

      final children = item.children != null ? _buildRoutes(item.children!, parentPath: originalPath) : <GoRoute>[];

      if (path != null) {
        routes.add(
          GoRoute(
            path: path,
            name: item.text,
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
