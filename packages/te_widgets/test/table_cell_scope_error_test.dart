import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _SampleRow {
  final String id;
  String name;
  num age;
  Map<String, String> errors;

  _SampleRow(this.id, this.name, this.age, {Map<String, String>? errors})
      : errors = errors ?? {};
}

void main() {
  final appTheme = TAppTheme.defaultTheme();
  final theme = appTheme.lightTheme;

  testWidgets('TTableCellScope and TTable handle cell errors at editable table level', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final items = [
      _SampleRow('row_1', 'John Doe', 25),
      _SampleRow('row_2', '', -5, errors: {'name': 'Name is required', 'age': 'Age must be positive'}),
    ];

    final headers = [
      TTableHeader<_SampleRow, String>.textField(
        'Name',
        (row) => row.name,
        (row, val) => row.name = val ?? '',
        placeholder: 'Enter name',
      ),
      TTableHeader<_SampleRow, String>.numberField(
        'Age',
        (row) => row.age,
        (row, val) => row.age = val ?? 0,
        placeholder: '0',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TTable<_SampleRow, String>(
            items: items,
            itemKey: (row) => row.id,
            headers: headers,
            editable: true,
            cellErrorBuilder: (row, col) => row.errors[col.toLowerCase()],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Row 1: Valid cells
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);

    // Row 2: Invalid cells with error indicators and tooltips
    expect(find.text('Enter name'), findsOneWidget); // Empty with error shows placeholder
    expect(find.text('-5'), findsOneWidget);
    expect(find.byType(HugeIcon), findsWidgets); // Alert icons for errors

    // Tooltip should be present with the error message
    final nameTooltip = find.byWidgetPredicate(
      (w) => w is Tooltip && w.message == 'Name is required',
    );
    expect(nameTooltip, findsOneWidget);

    final ageTooltip = find.byWidgetPredicate(
      (w) => w is Tooltip && w.message == 'Age must be positive',
    );
    expect(ageTooltip, findsOneWidget);

    // Tap on row_2 age to enter edit mode and verify error tooltip is active on editor
    await tester.tap(find.text('-5'));
    await tester.pumpAndSettle();

    expect(find.byType(TNumberField<num>), findsOneWidget);
    final editorTooltip = find.ancestor(
      of: find.byType(TNumberField<num>),
      matching: find.byWidgetPredicate((w) => w is Tooltip && w.message == 'Age must be positive'),
    );
    expect(editorTooltip, findsOneWidget);
  });
}
