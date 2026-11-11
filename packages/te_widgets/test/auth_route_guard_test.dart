import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

Widget _app(TAuthController controller, String permission) => TAuthScope(
      controller: controller,
      child: MaterialApp(
        theme: TAppTheme.defaultTheme().lightTheme,
        home: Scaffold(body: TAuthRouteGuard(permission: permission, child: const Text('secret page'))),
      ),
    );

void main() {
  testWidgets('TAuthRouteGuard shows the page when the permission is granted', (tester) async {
    await tester.pumpWidget(_app(TAuthController(permissions: ['orders.view']), 'orders.view'));
    expect(find.text('secret page'), findsOneWidget);
  });

  testWidgets('TAuthRouteGuard shows access denied, not the page, when it is not', (tester) async {
    await tester.pumpWidget(_app(TAuthController(permissions: ['orders.create']), 'orders.view'));
    expect(find.text('secret page'), findsNothing);
    expect(find.text('Access denied'), findsOneWidget);
  });

  testWidgets('a page with no permission rule is allowed while no auth scope is configured', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
          theme: TAppTheme.defaultTheme().lightTheme,
          home: const Scaffold(body: TAuthRouteGuard(permission: 'x.view', child: Text('open page')))),
    );
    expect(find.text('open page'), findsOneWidget);
  });
}
