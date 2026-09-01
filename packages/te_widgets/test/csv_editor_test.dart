import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  group('TCsvParser tests', () {
    test('parses basic comma-separated CSV', () {
      const csv = 'Name,Price,Stock\nApple,1.50,100\nBanana,0.75,250';
      final rows = TCsvParser.parse(csv);

      expect(rows.length, 3);
      expect(rows[0], ['Name', 'Price', 'Stock']);
      expect(rows[1], ['Apple', '1.50', '100']);
      expect(rows[2], ['Banana', '0.75', '250']);
    });

    test('parses quoted values with commas and escaped quotes', () {
      const csv = 'Title,Description,Price\n"Laptop, 15 inch","Fast ""Pro"" Model",1299.99';
      final rows = TCsvParser.parse(csv);

      expect(rows.length, 2);
      expect(rows[0], ['Title', 'Description', 'Price']);
      expect(rows[1][0], 'Laptop, 15 inch');
      expect(rows[1][1], 'Fast "Pro" Model');
      expect(rows[1][2], '1299.99');
    });

    test('auto-detects semicolon delimiter', () {
      const csv = 'ID;Product;Category\n1;Monitor;Electronics\n2;Desk;Furniture';
      final rows = TCsvParser.parse(csv);

      expect(rows.length, 3);
      expect(rows[0], ['ID', 'Product', 'Category']);
      expect(rows[1], ['1', 'Monitor', 'Electronics']);
    });

    test('toCsv and template generation', () {
      final columns = [
        const TCsvColumn.text(key: 'name', header: 'Product Name', isRequired: true),
        const TCsvColumn.number(key: 'price', header: 'Price'),
        const TCsvColumn.boolean(key: 'in_stock', header: 'In Stock'),
      ];

      final template = TCsvParser.generateTemplate(columns);
      expect(template, contains('Product Name,Price,In Stock'));
      expect(template, contains('Sample Product Name'));
    });
  });

  group('TCsvColumn & Type Coercion tests', () {
    test('text column coercion & validation', () {
      const col = TCsvColumn.text(key: 'name', header: 'Name', isRequired: true);
      expect(col.parseValue('  Hello  '), 'Hello');
      expect(col.parseValue(''), null);
      expect(col.validate(null), 'Name is required');
      expect(col.validate(''), 'Name is required');
      expect(col.validate('John'), null);
    });

    test('number column coercion & validation', () {
      const col = TCsvColumn.number(key: 'price', header: 'Price', isRequired: true);
      expect(col.parseValue('\$1,249.50'), 1249.50);
      expect(col.parseValue('45.00'), 45.00);
      expect(col.validate('invalid_num'), 'Price must be a valid number');
      expect(col.validate(123.45), null);
    });

    test('integer column coercion & validation', () {
      const col = TCsvColumn.integer(key: 'qty', header: 'Quantity', defaultValue: 0);
      expect(col.parseValue('15'), 15);
      expect(col.parseValue(''), 0);
      expect(col.validate('abc'), 'Quantity must be a whole number');
      expect(col.validate(10), null);
    });

    test('boolean column coercion', () {
      const col = TCsvColumn.boolean(key: 'active', header: 'Active', defaultValue: false);
      expect(col.parseValue('true'), true);
      expect(col.parseValue('1'), true);
      expect(col.parseValue('yes'), true);
      expect(col.parseValue('active'), true);
      expect(col.parseValue('false'), false);
      expect(col.parseValue('0'), false);
      expect(col.parseValue('no'), false);
      expect(col.parseValue(''), false);
    });
  });

  group('TCsvHeaderMapping tests', () {
    test('auto-matches headers with exact, normalized, and alias matching', () {
      final expectedColumns = [
        const TCsvColumn.text(key: 'product_name', header: 'Product Name', isRequired: true),
        const TCsvColumn.number(key: 'unit_price', header: 'Unit Price', aliases: ['cost', 'price', 'rate']),
        const TCsvColumn.boolean(key: 'is_active', header: 'Is Active', aliases: ['active', 'status', 'available']),
      ];

      final csvHeaders = ['product_name', 'Cost', 'status', 'ExtraColumn'];

      final mapping = TCsvHeaderMapping.autoMap(
        expectedColumns: expectedColumns,
        csvHeaders: csvHeaders,
      );

      expect(mapping.mapping['product_name'], 'product_name');
      expect(mapping.mapping['unit_price'], 'Cost');
      expect(mapping.mapping['is_active'], 'status');
      expect(mapping.isComplete(expectedColumns), true);

      final row = mapping.mapRow(
        expectedColumns: expectedColumns,
        csvHeaders: csvHeaders,
        csvRow: ['Wireless Mouse', '\$29.99', 'true', 'IgnoreMe'],
      );

      expect(row['product_name'], 'Wireless Mouse');
      expect(row['unit_price'], 29.99);
      expect(row['is_active'], true);
    });

    test('detects unmapped required columns', () {
      final expectedColumns = [
        const TCsvColumn.text(key: 'name', header: 'Name', isRequired: true),
        const TCsvColumn.number(key: 'sku', header: 'SKU Code', isRequired: true),
      ];

      final csvHeaders = ['Name', 'OtherHeader'];
      final mapping = TCsvHeaderMapping.autoMap(
        expectedColumns: expectedColumns,
        csvHeaders: csvHeaders,
      );

      expect(mapping.isComplete(expectedColumns), false);
      expect(mapping.getUnmappedRequired(expectedColumns).length, 1);
      expect(mapping.getUnmappedRequired(expectedColumns).first.key, 'sku');
    });
  });

  group('TCsvRow tests', () {
    test('validates row cells and computes validity', () {
      final columns = [
        const TCsvColumn.text(key: 'name', header: 'Name', isRequired: true),
        const TCsvColumn.number(key: 'price', header: 'Price', isRequired: true),
      ];

      final validRow = TCsvRow(values: {'name': 'Gadget', 'price': 99.99});
      validRow.validate(columns);
      expect(validRow.isValid, true);
      expect(validRow.errors, isEmpty);

      final invalidRow = TCsvRow(values: {'name': '', 'price': 'bad_price'});
      invalidRow.validate(columns);
      expect(invalidRow.isValid, false);
      expect(invalidRow.errors.containsKey('name'), true);
      expect(invalidRow.errors.containsKey('price'), true);
    });
  });

  group('TCsvEditor Widget tests', () {
    testWidgets('renders TCsvEditor with TTable, inputs, and switch', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final columns = [
        const TCsvColumn.text(key: 'name', header: 'Product Name', isRequired: true),
        const TCsvColumn.number(key: 'price', header: 'Price'),
        const TCsvColumn.boolean(key: 'active', header: 'Active'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: TAppTheme.defaultTheme().lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: TCsvEditor(
                columns: columns,
                initialData: [
                  {'name': 'Keyboard', 'price': 89.99, 'active': true},
                  {'name': 'Mouse', 'price': 29.99, 'active': false},
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check TTable is rendered
      expect(find.byType(TTable<TCsvRow, String>), findsOneWidget);
      expect(find.text('Product Name *'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);

      // Check text values are displayed in the cells
      expect(find.text('Keyboard'), findsOneWidget);
      expect(find.text('Mouse'), findsOneWidget);
      expect(find.text('89.99'), findsOneWidget);
      expect(find.text('29.99'), findsOneWidget);

      // Check that only 1 text field exists initially (the search bar in the toolbar)
      expect(find.byType(TTextField<String>), findsOneWidget);
      expect(find.byType(TNumberField<num>), findsNothing);

      // Tap on 'Keyboard' to activate inline editor for product name
      await tester.tap(find.text('Keyboard'));
      await tester.pumpAndSettle();

      // Now 2 TTextFields exist (search bar + the active name cell)
      expect(find.byType(TTextField<String>), findsNWidgets(2));
      expect(find.byType(TNumberField<num>), findsNothing);

      // Tap on '89.99' to switch active editor to the price cell
      await tester.tap(find.text('89.99'));
      await tester.pumpAndSettle();

      // Price cell is now active as TNumberField, and name cell went back to display text
      expect(find.byType(TNumberField<num>), findsOneWidget);
      expect(find.byType(TTextField<String>), findsOneWidget); // Only search bar is TTextField
    });

    testWidgets('switches filter tab between All, Valid, and Errors using TTabs', (tester) async {
      final columns = [
        const TCsvColumn.text(key: 'name', header: 'Name', isRequired: true),
        const TCsvColumn.number(key: 'price', header: 'Price', isRequired: true),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: TAppTheme.defaultTheme().lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: TCsvEditor(
                columns: columns,
                initialData: const [
                  {'name': 'Valid Item', 'price': 10.0},
                  {'name': '', 'price': 20.0}, // Invalid: empty name
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check TTabs is rendered with 3 tabs
      expect(find.byType(TTabs<int>), findsOneWidget);
      expect(find.text('All (2)'), findsOneWidget);
      expect(find.text('Valid (1)'), findsOneWidget);
      expect(find.text('Errors (1)'), findsOneWidget);

      // Initially both rows are shown
      expect(find.text('Valid Item'), findsOneWidget);

      // Tap 'Valid (1)' tab
      await tester.tap(find.text('Valid (1)'));
      await tester.pumpAndSettle();

      // Only valid item is shown
      expect(find.text('Valid Item'), findsOneWidget);

      // Tap 'Errors (1)' tab
      await tester.tap(find.text('Errors (1)'));
      await tester.pumpAndSettle();

      // Valid item is filtered out
      expect(find.text('Valid Item'), findsNothing);
      expect(find.text('20.0'), findsOneWidget);
    });
  });
}
