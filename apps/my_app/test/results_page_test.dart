import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/pages/results_page.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  testWidgets('ResultsPage renders inline and docked mobile previews and handles toggle', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final theme = TAppTheme.defaultTheme().lightTheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: ResultsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and preview sections
    expect(find.text('Result / Status Pages'), findsOneWidget);
    expect(find.text('Standard Inline Layout (Card / Dialog Embed)'), findsOneWidget);
    expect(find.text('Mobile / Handheld Layout (`docked` prop sample)'), findsOneWidget);

    // Verify switch and docked state
    expect(find.byType(TSwitch), findsOneWidget);
    expect(find.text('docked: true'), findsOneWidget);

    // Toggle switch to false
    await tester.tap(find.byType(TSwitch));
    await tester.pumpAndSettle();

    expect(find.text('docked: false'), findsOneWidget);

    // Toggle switch back to true
    await tester.tap(find.byType(TSwitch));
    await tester.pumpAndSettle();

    expect(find.text('docked: true'), findsOneWidget);

    // Tap Launch Fullscreen Page button
    expect(find.text('Launch Fullscreen Page'), findsOneWidget);
    await tester.tap(find.text('Launch Fullscreen Page'));
    await tester.pumpAndSettle();

    // Verify fullscreen modal opened and close button works
    expect(find.byTooltip('Close full-screen preview'), findsOneWidget);
    await tester.tap(find.byTooltip('Close full-screen preview'));
    await tester.pumpAndSettle();
  });
}
