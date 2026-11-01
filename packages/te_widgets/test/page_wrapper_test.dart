import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  testWidgets('TPageWrapper renders header, content, and footer correctly', (WidgetTester tester) async {
    bool backPressed = false;

    // TPageWrapper shows the back/close control as an IconButton only at desktop widths
    // (context.isDesktop, >= kDesktopBreakpoint); below that it renders a TButton instead.
    // The default test surface (800x600) is below that breakpoint, so without this the
    // IconButton this test looks for never renders.
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
