import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _SampleItem {
  final String id;
  final String title;
  const _SampleItem(this.id, this.title);
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  testWidgets('TCrudTable options renders width split steppers and adjusts widths', (WidgetTester tester) async {
    final items = [
      const _SampleItem('1', 'Item 1'),
      const _SampleItem('2', 'Item 2'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TCrudTable<_SampleItem, String, TFormBase>(
            headers: [
              TTableHeader<_SampleItem, String>.map('Title', (x) => x.title),
            ],
            items: items,
            itemKey: (x) => x.id,
            dialogWidth: 800,
            sideOverlayWidth: 500,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Open options dropdown
    final moreOptionsButton = find.byIcon(Icons.more_vert);
    expect(moreOptionsButton, findsOneWidget);
    await tester.tap(moreOptionsButton);
    await tester.pumpAndSettle();

    // Hover or tap 'Expand Mode' to show children
    final expandModeItem = find.text('Expand Mode');
    expect(expandModeItem, findsOneWidget);
    await tester.tap(expandModeItem);
    await tester.pumpAndSettle();

    // Verify Overlay and Side Overlay options are present with number fields
    expect(find.text('Dialog'), findsOneWidget);
    expect(find.text('Side Overlay'), findsOneWidget);
    expect(find.byType(TNumberField<int>), findsAtLeastNWidgets(2));

    // Verify default values 800 and 500 in number fields
    expect(find.text('800'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
  });
}
