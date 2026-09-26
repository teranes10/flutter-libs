import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/navigation.dart';
import 'package:my_app/router.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  test('sidebar items resolve without errors or duplicate routes', () {
    final resolved = TSidebarItemsResolver.resolve(sidebarItems);
    expect(resolved, isNotEmpty);

    // Verify all routes are unique
    final routes = <String>{};
    void checkUnique(List<TSidebarItem> items) {
      for (final item in items) {
        if (item.route != null && !item.route!.contains(':')) {
          expect(routes.contains(item.route), isFalse, reason: 'Duplicate route detected: ${item.route}');
          routes.add(item.route!);
        }
        if (item.children != null) {
          checkUnique(item.children!);
        }
      }
    }

    checkUnique(resolved);
  });

  test('toGoRoutes generates all routes correctly', () {
    final routes = sidebarItems.toGoRoutes();
    expect(routes, isNotEmpty);
  });

  test('router initializes properly', () {
    expect(router, isNotNull);
  });
}
