import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _TestProduct {
  final String id;
  final String name;
  const _TestProduct(this.id, this.name);
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  testWidgets('TTable with TTableExpansionMode.sideOverlay opens side overlay when expanded', (WidgetTester tester) async {
    final controller = TListController<_TestProduct, String>(
      items: [
        const _TestProduct('1', 'Product Alpha'),
        const _TestProduct('2', 'Product Beta'),
      ],
      itemKey: (p) => p.id,
      expansionMode: TExpansionMode.single,
    );

    final headers = [
      TTableHeader<_TestProduct, String>.map('Name', (p) => p.name),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TTable<_TestProduct, String>(
            headers: headers,
            controller: controller,
            details: TTableDetails(
              mode: TTableExpansionMode.sideOverlay,
              itemTitle: (p) => p.name,
              builder: (ctx, item, index) => Text('Details for ${item.data.name}'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Product Alpha'), findsOneWidget);
    expect(find.text('Details for Product Alpha'), findsNothing);

    // Expand Product Alpha
    controller.expandDetail('1');
    await tester.pumpAndSettle();

    expect(find.text('Details for Product Alpha'), findsOneWidget);
    expect(find.text('Product Alpha'), findsNWidgets(2)); // in row and in page header

    // Collapse
    controller.collapseDetail();
    await tester.pumpAndSettle();

    expect(find.text('Details for Product Alpha'), findsNothing);
  });

  testWidgets('TTable with TTableExpansionMode.side closes details panel when close icon is tapped', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final controller = TListController<_TestProduct, String>(
      items: [
        const _TestProduct('1', 'Product Alpha'),
        const _TestProduct('2', 'Product Beta'),
      ],
      itemKey: (p) => p.id,
      expansionMode: TExpansionMode.single,
    );

    final headers = [
      TTableHeader<_TestProduct, String>.map('Name', (p) => p.name),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TTable<_TestProduct, String>(
            headers: headers,
            controller: controller,
            details: TTableDetails(
              mode: TTableExpansionMode.side,
              itemTitle: (p) => p.name,
              builder: (ctx, item, index) => Text('Details for ${item.data.name}'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Details for Product Alpha'), findsNothing);

    // Expand Product Alpha
    controller.expandDetail('1');
    await tester.pumpAndSettle();

    expect(find.text('Details for Product Alpha'), findsOneWidget);

    // Find and tap the close icon
    final closeButton = find.byIcon(Icons.close);
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    // Verify detail panel closed
    expect(find.text('Details for Product Alpha'), findsNothing);
    expect(controller.value.expandedDetailKey, isNull);
    expect(controller.value.activeKey, isNull);
  });

  testWidgets('TTable with TTableExpansionMode.sideOverlay closes details overlay when close icon is tapped', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final controller = TListController<_TestProduct, String>(
      items: [
        const _TestProduct('1', 'Product Alpha'),
        const _TestProduct('2', 'Product Beta'),
      ],
      itemKey: (p) => p.id,
      expansionMode: TExpansionMode.single,
    );

    final headers = [
      TTableHeader<_TestProduct, String>.map('Name', (p) => p.name),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TTable<_TestProduct, String>(
            headers: headers,
            controller: controller,
            details: TTableDetails(
              mode: TTableExpansionMode.sideOverlay,
              itemTitle: (p) => p.name,
              builder: (ctx, item, index) => Text('Details for ${item.data.name}'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Details for Product Alpha'), findsNothing);

    // Expand Product Alpha
    controller.expandDetail('1');
    await tester.pumpAndSettle();

    expect(find.text('Details for Product Alpha'), findsOneWidget);

    // Find and tap the close icon in the overlay
    final closeButton = find.byIcon(Icons.close);
    expect(closeButton, findsWidgets);
    await tester.tap(closeButton.first);
    await tester.pumpAndSettle();

    // Verify side overlay closed
    expect(find.text('Details for Product Alpha'), findsNothing);
    expect(controller.value.expandedDetailKey, isNull);
    expect(controller.value.activeKey, isNull);
  });

  testWidgets('TTableDetails with responsive sideOverlayWidthRatio and maxWidth calculates sheet width correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final controller = TListController<_TestProduct, String>(
      items: [
        const _TestProduct('1', 'Product Alpha'),
      ],
      itemKey: (p) => p.id,
      expansionMode: TExpansionMode.single,
    );

    final headers = [
      TTableHeader<_TestProduct, String>.map('Name', (p) => p.name),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TTable<_TestProduct, String>(
            headers: headers,
            controller: controller,
            details: TTableDetails(
              mode: TTableExpansionMode.sideOverlay,
              sideOverlayWidthRatio: 0.5, // 50% of 1400 = 700
              sideOverlayMaxWidth: 800,
              sideOverlayMinWidth: 400,
              itemTitle: (p) => p.name,
              builder: (ctx, item, index) => Text('Details for ${item.data.name}'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Expand
    controller.expandDetail('1');
    await tester.pumpAndSettle();

    expect(find.text('Details for Product Alpha'), findsOneWidget);

    // Verify TSideSheet width
    final sideSheet = tester.widget<TSideSheet>(find.byType(TSideSheet));
    expect(sideSheet.widthRatio, 0.5);
    expect(sideSheet.maxWidth, 800);
    expect(sideSheet.minWidth, 400);

    final sideSheetBox = tester.renderObject(find.byType(TSideSheet)) as RenderBox;
    expect(sideSheetBox.size.width, 700.0);
  });
}
