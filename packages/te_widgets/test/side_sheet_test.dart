import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  testWidgets('TSideSheet renders title, subtitle, content, and close button', (WidgetTester tester) async {
    bool closePressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TSideSheet(
            const Text('Side sheet content'),
            title: 'Side Sheet Title',
            subTitle: 'Side sheet subtitle',
            showCloseButton: true,
            onClose: () {
              closePressed = true;
            },
            width: 450,
          ),
        ),
      ),
    );

    expect(find.text('Side Sheet Title'), findsOneWidget);
    expect(find.text('Side sheet subtitle'), findsOneWidget);
    expect(find.text('Side sheet content'), findsOneWidget);

    final closeIcon = find.byType(TIcon);
    expect(closeIcon, findsOneWidget);
    await tester.tap(closeIcon);
    expect(closePressed, isTrue);
  });

  testWidgets('TSideSheet supports layoutBuilder override', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TSideSheet(
            const Text('Inner content'),
            layoutBuilder: (context, child) => Container(
              key: const ValueKey('custom_side_sheet_layout'),
              child: child,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('custom_side_sheet_layout')), findsOneWidget);
    expect(find.text('Inner content'), findsOneWidget);
  });

  testWidgets('TSheetService.showSideSheet opens and can be dismissed', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                TSheetService.showSideSheet(
                  context,
                  (ctx) => const Text('Dialog Side Sheet Content'),
                  title: 'Sheet Dialog Title',
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Dialog Side Sheet Content'), findsNothing);

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Dialog Side Sheet Content'), findsOneWidget);
    expect(find.text('Sheet Dialog Title'), findsOneWidget);

    // Tap close button in side sheet
    final closeIcon = find.byType(TIcon);
    expect(closeIcon, findsOneWidget);
    await tester.tap(closeIcon);
    await tester.pumpAndSettle();

    expect(find.text('Dialog Side Sheet Content'), findsNothing);
  });
}
