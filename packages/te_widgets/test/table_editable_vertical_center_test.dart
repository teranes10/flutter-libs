import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _EditableItem {
  final String id;
  String title;
  num count;

  _EditableItem(this.id, this.title, this.count);
}

void main() {
  final appTheme = TAppTheme.defaultTheme();
  final theme = appTheme.lightTheme;

  testWidgets('TTableHeader editable, textField, and numberField align vertically in the center', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final items = [
      _EditableItem('1', 'Alpha Title', 42),
    ];

    final headers = [
      TTableHeader<_EditableItem, String>.textField('Title', (x) => x.title, (x, v) => x.title = v ?? ''),
      TTableHeader<_EditableItem, String>.numberField('Count', (x) => x.count, (x, v) => x.count = v ?? 0),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TTable<_EditableItem, String>(
            items: items,
            itemKey: (i) => i.id,
            headers: headers,
            editable: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial text display is rendered
    expect(find.text('Alpha Title'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    // Tap on 'Alpha Title' to enter editing mode
    await tester.tap(find.text('Alpha Title'));
    await tester.pumpAndSettle();

    // Verify TTextField is rendered and centered
    expect(find.byType(TTextField<String>), findsOneWidget);
    final textFieldAlign = tester.widget<Align>(
      find.ancestor(
        of: find.byType(TTextField<String>),
        matching: find.byType(Align),
      ).first,
    );
    expect((textFieldAlign.alignment as Alignment).y, equals(0.0)); // vertically centered

    // Tap on '42' to enter number editing mode
    await tester.tap(find.text('42'));
    await tester.pumpAndSettle();

    // Verify TNumberField is rendered and centered
    expect(find.byType(TNumberField<num>), findsOneWidget);
    final numberFieldAlign = tester.widget<Align>(
      find.ancestor(
        of: find.byType(TNumberField<num>),
        matching: find.byType(Align),
      ).first,
    );
    expect((numberFieldAlign.alignment as Alignment).y, equals(0.0)); // vertically centered
  });

  testWidgets('Standard and editable columns align on the exact same vertical line in a row', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final items = [
      _EditableItem('1', 'Alpha Title', 42),
    ];

    final headers = [
      TTableHeader<_EditableItem, String>.map('SKU', (x) => 'SKU-001'),
      TTableHeader<_EditableItem, String>.textField('Title', (x) => x.title, (x, v) => x.title = v ?? ''),
      TTableHeader<_EditableItem, String>.numberField('Count', (x) => x.count, (x, v) => x.count = v ?? 0),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TTable<_EditableItem, String>(
            items: items,
            itemKey: (i) => i.id,
            headers: headers,
            editable: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final skuFinder = find.text('SKU-001');
    final titleFinder = find.text('Alpha Title');
    final countFinder = find.text('42');

    expect(skuFinder, findsOneWidget);
    expect(titleFinder, findsOneWidget);
    expect(countFinder, findsOneWidget);

    final skuCenter = tester.getCenter(skuFinder);
    final titleCenter = tester.getCenter(titleFinder);
    final countCenter = tester.getCenter(countFinder);

    // Verify that all cell texts in the same row share the exact same vertical center line (Y coordinate)
    expect(titleCenter.dy, closeTo(skuCenter.dy, 1.0));
    expect(countCenter.dy, closeTo(skuCenter.dy, 1.0));
  });

  testWidgets('Table header and data row card columns have identical horizontal bounds', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final items = [
      _EditableItem('1', 'Alpha Title', 42),
    ];

    final headers = [
      TTableHeader<_EditableItem, String>.map('SKU', (x) => 'SKU-001', minWidth: 110),
      TTableHeader<_EditableItem, String>.textField('Title', (x) => x.title, (x, v) => x.title = v ?? '', minWidth: 160),
      TTableHeader<_EditableItem, String>.numberField('Count', (x) => x.count, (x, v) => x.count = v ?? 0, minWidth: 100),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TTable<_EditableItem, String>(
            items: items,
            itemKey: (i) => i.id,
            headers: headers,
            editable: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tables = tester.widgetList<Table>(find.byType(Table)).toList();
    expect(tables.length, greaterThanOrEqualTo(2));

    final headerTable = tables[0];
    final rowTable = tables[1];

    for (int c = 0; c < headers.length; c++) {
      final headerCell = headerTable.children[0].children[c];
      final rowCell = rowTable.children[0].children[c];

      final headerRect = tester.getRect(find.byWidget(headerCell));
      final rowRect = tester.getRect(find.byWidget(rowCell));

      expect(rowRect.left, closeTo(headerRect.left, 0.5), reason: 'Column $c left bound mismatch');
      expect(rowRect.right, closeTo(headerRect.right, 0.5), reason: 'Column $c right bound mismatch');
    }
  });
}
