import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _Item {
  String id;
  String sku;
  _Item(this.id, this.sku);
}

void main() {
  final appTheme = TAppTheme.defaultTheme();
  final theme = appTheme.lightTheme;

  testWidgets('Editable cell tap on far right of column activates editor', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final items = [_Item('1', 'A')]; // Very short 1-char text 'A' in 200px column
    final headers = [
      TTableHeader<_Item, String>.textField(
        'SKU',
        (x) => x.sku,
        (x, v) => x.sku = v ?? '',
        minWidth: 200,
        maxWidth: 200,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TTable<_Item, String>(
            items: items,
            itemKey: (i) => i.id,
            headers: headers,
            editable: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify display mode initially
    expect(find.text('A'), findsOneWidget);
    expect(find.byType(TTextField<String>), findsNothing);

    // Find the cell bounds
    final textFinder = find.text('A');
    final textRect = tester.getRect(textFinder);

    // Tap far to the right of the text (e.g. +100px to the right of 'A')
    final farRightOffset = Offset(textRect.right + 100, textRect.center.dy);
    await tester.tapAt(farRightOffset);
    await tester.pumpAndSettle();

    // Now the text field editor should be active!
    expect(find.byType(TTextField<String>), findsOneWidget);
  });
}
