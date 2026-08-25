import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  testWidgets('TPageWrapper renders header, content, and footer correctly', (WidgetTester tester) async {
    bool backPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TPageWrapper(
            title: 'Order Details',
            subTitle: 'Order #12345',
            description: 'Viewing details for this order',
            onBackPressed: () {
              backPressed = true;
            },
            footer: Container(
              padding: const EdgeInsets.all(16),
              child: const Text('Footer Action Button'),
            ),
            child: Column(
              children: List.generate(
                20,
                (index) => ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('Order #12345'), findsOneWidget);
    expect(find.text('Viewing details for this order'), findsOneWidget);
    expect(find.text('Footer Action Button'), findsOneWidget);
    expect(find.text('Item 0'), findsOneWidget);

    // Test back/close button
    final closeOrBackIcon = find.byType(IconButton);
    expect(closeOrBackIcon, findsOneWidget);
    await tester.tap(closeOrBackIcon);
    expect(backPressed, isTrue);
  });

  testWidgets('TPageWrapper handles shrinkWrap mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TPageWrapper(
              title: 'ShrinkWrap Modal',
              shrinkWrap: true,
              child: const Text('Short content'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('ShrinkWrap Modal'), findsOneWidget);
    expect(find.text('Short content'), findsOneWidget);
  });
}
