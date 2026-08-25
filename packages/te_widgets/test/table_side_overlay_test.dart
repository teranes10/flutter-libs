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
}
