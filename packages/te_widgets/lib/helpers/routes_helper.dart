import 'package:go_router/go_router.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_config.dart';

extension SidebarRoutingExtension on List<TSidebarItem> {
  List<GoRoute> toGoRoutes() {
    List<GoRoute> routes = [];

    void addRoutes(List<TSidebarItem> items) {
      for (var item in items) {
        if (item.children != null && item.children!.isNotEmpty) {
          addRoutes(item.children!);
        } else if (item.route != null && item.page != null) {
          routes.add(
            GoRoute(
              path: item.route!,
              name: item.text,
              pageBuilder: (context, state) => NoTransitionPage(child: item.page!),
            ),
          );
        }
      }
    }

    addRoutes(this);
    return routes;
  }
}
