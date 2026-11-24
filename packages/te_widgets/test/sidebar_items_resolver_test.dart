import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  test('root and route-less-group routes resolve to absolute paths matching their GoRoutes', () {
    final items = [
      TSidebarItem(text: 'Dashboard', route: 'dashboard', page: const SizedBox()),
      TSidebarItem(
        group: true,
        text: 'Dispatch',
        children: [TSidebarItem(text: 'Jobs', route: 'jobs', page: const SizedBox())],
      ),
      TSidebarItem(
        text: 'Forms',
        route: '/forms',
        children: [TSidebarItem(text: 'Inputs', route: 'inputs', page: const SizedBox())],
      ),
    ];

    final resolved = TSidebarItemsResolver.resolve(items);
    expect(resolved[0].route, '/dashboard');
    expect(resolved[1].children!.single.route, '/jobs');
    expect(resolved[2].route, '/forms');
    expect(resolved[2].children!.single.route, '/forms/inputs');

    final paths = items.toGoRoutes().map((r) => r.path).toList();
    expect(paths, containsAll(['/dashboard', '/jobs', '/forms']));
  });
}
