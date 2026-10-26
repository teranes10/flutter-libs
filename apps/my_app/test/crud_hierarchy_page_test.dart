import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/router.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  testWidgets('hierarchy card tap opens children page without hanging', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    router.go('/data-management/crud-hierarchy');
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(
        theme: TAppTheme.defaultTheme(primary: Colors.blue).lightTheme,
        routerConfig: router,
      ),
    ));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Electronics & Gadgets'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('Laptops & Computers'), findsWidgets);
  });
}
