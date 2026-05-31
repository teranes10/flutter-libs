import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

extension SidebarItemListX on List<TSidebarItem> {
  List<GoRoute> toGoRoutes() {
    return _buildRoutes(this);
  }

  List<GoRoute> _buildRoutes(List<TSidebarItem> items) {
    List<GoRoute> routes = [];

    for (var item in items) {
      if (item.route != null && (item.page != null || item.builder != null)) {
        routes.add(
          GoRoute(
            path: item.route!,
            name: item.text,
            pageBuilder: (context, state) {
              final child = item.builder?.call(context, state) ?? item.page!;
              return NoTransitionPage(child: child);
            },
          ),
        );
      }
      
      if (item.children != null && item.children!.isNotEmpty) {
        routes.addAll(_buildRoutes(item.children!));
      }
    }

    return routes;
  }
}
