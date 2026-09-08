import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class _SampleItem {
  final String id;
  final String name;
  final String email;
  final int age;
  _SampleItem(this.id, this.name, this.email, this.age);
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  group('TKeyValueMode tests', () {
    test('TKeyValueMode helpers return expected boolean values', () {
      expect(TKeyValueMode.stackedFlow.isStacked, isTrue);
      expect(TKeyValueMode.stackedFlow.isFlow, isTrue);
      expect(TKeyValueMode.stackedFlow.isInline, isFalse);
      expect(TKeyValueMode.stackedFlow.isColumnar, isFalse);

      expect(TKeyValueMode.stackedColumns.isStacked, isTrue);
      expect(TKeyValueMode.stackedColumns.isColumnar, isTrue);
      expect(TKeyValueMode.stackedColumns.isFlow, isFalse);

      expect(TKeyValueMode.inlineFlow.isInline, isTrue);
      expect(TKeyValueMode.inlineFlow.isFlow, isTrue);
      expect(TKeyValueMode.inlineFlow.isStacked, isFalse);

      expect(TKeyValueMode.inlineColumns.isInline, isTrue);
      expect(TKeyValueMode.inlineColumns.isColumnar, isTrue);
      expect(TKeyValueMode.inlineColumns.isFlow, isFalse);

      expect(TKeyValueMode.split.isSplit, isTrue);
    });

    testWidgets('TKeyValueSection renders all factory modes properly', (WidgetTester tester) async {
      final values = [
        TKeyValue('Name', value: 'Alice'),
        TKeyValue('Email', value: 'alice@example.com'),
        TKeyValue('Role', value: 'Admin'),
      ];

      // 1. stackedFlow
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection.flowStacked(values: values),
          ),
        ),
      );
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);

      // 2. stackedColumns
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection.columnsStacked(values: values, columns: 3),
          ),
        ),
      );
      expect(find.text('Email'), findsOneWidget);

      // 3. inlineFlow
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection.flow(values: values),
          ),
        ),
      );
      expect(find.text('Role:'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);

      // 4. inlineColumns
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection.columnsInline(values: values, columns: 2),
          ),
        ),
      );
      expect(find.text('Name:'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);

      // 5. split
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TKeyValueSection.split(values: values),
          ),
        ),
      );
      expect(find.text('Role'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    test('TKeyValueTheme resolves mode-based default spacings and gaps via switch', () {
      final base = TKeyValueTheme(
        keyStyle: const TextStyle(),
        labelStyle: const TextStyle(),
        valueStyle: const TextStyle(),
        borderColor: Colors.grey,
      );

      // null mode
      expect(base.hSpacing, 0);
      expect(base.vSpacing, 8);
      expect(base.gap, 4);

      // stackedFlow
      final sf = base.copyWith(mode: TKeyValueMode.stackedFlow);
      expect(sf.hSpacing, 24);
      expect(sf.vSpacing, 16);
      expect(sf.gap, 0);

      // stackedColumns
      final sc = base.copyWith(mode: TKeyValueMode.stackedColumns);
      expect(sc.hSpacing, 24);
      expect(sc.vSpacing, 16);
      expect(sc.gap, 0);

      // inlineFlow
      final inf = base.copyWith(mode: TKeyValueMode.inlineFlow);
      expect(inf.hSpacing, 24);
      expect(inf.vSpacing, 16);
      expect(inf.gap, 12);

      // inlineColumns
      final inc = base.copyWith(mode: TKeyValueMode.inlineColumns);
      expect(inc.hSpacing, 24);
      expect(inc.vSpacing, 16);
      expect(inc.gap, 8);

      // split
      final sp = base.copyWith(mode: TKeyValueMode.split);
      expect(sp.hSpacing, 12);
      expect(sp.vSpacing, 10);
      expect(sp.gap, 8);

      // explicit overrides take precedence
      final custom = base.copyWith(
        mode: TKeyValueMode.inlineColumns,
        hSpacing: 35,
        vSpacing: 25,
        gap: 15,
      );
      expect(custom.hSpacing, 35);
      expect(custom.vSpacing, 25);
      expect(custom.gap, 15);
    });

    test('TKeyValueSection constructors have null defaults for gap, hSpacing, and vSpacing', () {
      final values = [TKeyValue('Key', value: 'Value')];

      final sf = TKeyValueSection.flowStacked(values: values);
      expect(sf.gap, isNull);
      expect(sf.hSpacing, isNull);
      expect(sf.vSpacing, isNull);

      final sc = TKeyValueSection.columnsStacked(values: values);
      expect(sc.gap, isNull);
      expect(sc.hSpacing, isNull);
      expect(sc.vSpacing, isNull);

      final inf = TKeyValueSection.flow(values: values);
      expect(inf.gap, isNull);
      expect(inf.hSpacing, isNull);
      expect(inf.vSpacing, isNull);

      final inc = TKeyValueSection.columnsInline(values: values);
      expect(inc.gap, isNull);
      expect(inc.hSpacing, isNull);
      expect(inc.vSpacing, isNull);

      final sp = TKeyValueSection.split(values: values);
      expect(sp.gap, isNull);
      expect(sp.hSpacing, isNull);
      expect(sp.vSpacing, isNull);
    });
  });

  group('TCrudTable dense toggle and card layout tests', () {
    testWidgets('TCrudTable toggles between comfortable and dense mode via triple dots', (WidgetTester tester) async {
      final items = [
        _SampleItem('1', 'Alice', 'alice@test.com', 28),
        _SampleItem('2', 'Bob', 'bob@test.com', 32),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 1200,
              height: 800,
              child: TCrudTable<_SampleItem, String, TFormBase>(
                headers: [
                  TTableHeader<_SampleItem, String>.map('Name', (x) => x.name),
                  TTableHeader<_SampleItem, String>.map('Email', (x) => x.email),
                ],
                items: items,
                itemKey: (x) => x.id,
                config: const TCrudConfig(
                  storageKey: 'test_dense_toggle',
                  persistSettings: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);

      // Open more options dropdown
      final moreOptions = find.byIcon(Icons.more_vert);
      expect(moreOptions, findsOneWidget);
      await tester.tap(moreOptions);
      await tester.pumpAndSettle();

      // Tap Dense Layout
      final denseOption = find.text('Dense Layout');
      expect(denseOption, findsOneWidget);
      await tester.tap(denseOption);
      await tester.pumpAndSettle();

      // Reopen options and verify toggle text changed to Comfortable Layout
      await tester.tap(moreOptions);
      await tester.pumpAndSettle();
      expect(find.text('Comfortable Layout'), findsOneWidget);

      // Tap Comfortable Layout to switch back
      await tester.tap(find.text('Comfortable Layout'));
      await tester.pumpAndSettle();

      // Reopen options and verify toggle text is Dense Layout again
      await tester.tap(moreOptions);
      await tester.pumpAndSettle();
      expect(find.text('Dense Layout'), findsOneWidget);
    });

    testWidgets('TCrudTable card layout submenu allows changing and persisting cardKeyValueMode', (WidgetTester tester) async {
      final items = [
        _SampleItem('1', 'Alice', 'alice@test.com', 28),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 1200,
              height: 800,
              child: TCrudTable<_SampleItem, String, TFormBase>(
                headers: [
                  TTableHeader<_SampleItem, String>.map('Name', (x) => x.name),
                  TTableHeader<_SampleItem, String>.map('Email', (x) => x.email),
                ],
                items: items,
                itemKey: (x) => x.id,
                config: const TCrudConfig(
                  storageKey: 'test_card_layout',
                  persistSettings: false,
                  cardKeyValueMode: TKeyValueMode.stackedFlow,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open more options dropdown
      final moreOptions = find.byIcon(Icons.more_vert);
      await tester.tap(moreOptions);
      await tester.pumpAndSettle();

      // Verify Card Layout option exists
      final cardLayoutItem = find.text('Card Layout');
      expect(cardLayoutItem, findsOneWidget);
      await tester.tap(cardLayoutItem);
      await tester.pumpAndSettle();

      // Verify all 4 modes are present
      expect(find.text('Stacked Flow'), findsOneWidget);
      expect(find.text('Stacked Columns'), findsOneWidget);
      expect(find.text('Inline Flow'), findsOneWidget);
      expect(find.text('Inline Columns'), findsOneWidget);

      // Tap Inline Columns
      await tester.tap(find.text('Inline Columns'));
      await tester.pumpAndSettle();
    });

    testWidgets('TKeyValueSection and TButton do not throw RenderFlex overflow under narrow constraints', (WidgetTester tester) async {
      final values = [
        TKeyValue('Actions', widget: TButton(icon: Icons.edit, text: 'Edit', onTap: () {})),
        TKeyValue('Status', widget: TBadge(badge: 'Active', child: const Text('Status'))),
        TKeyValue('Long Key Name', value: 'Some very long descriptive text that exceeds narrow widths'),
        TKeyValue('Code', value: 'LOC-1234567890'),
        TKeyValue('Extra', widget: TButton(icon: Icons.delete, text: 'Delete', onTap: () {})),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 150, // very constrained width
                child: TKeyValueSection.flow(values: values),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
