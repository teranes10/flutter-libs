import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

void main() {
  group('TCsvParser Delimiter & Format Auto-Detection tests', () {
    test('parses basic comma-separated CSV', () {
      const csv = 'Name,Price,Stock\nApple,1.50,100\nBanana,0.75,250';
      final rows = TCsvParser.parse(csv);

      expect(rows.length, 3);
      expect(rows[0], ['Name', 'Price', 'Stock']);
      expect(rows[1], ['Apple', '1.50', '100']);
      expect(rows[2], ['Banana', '0.75', '250']);
      expect(TCsvParser.detectDelimiter(csv), ',');
      expect(TCsvParser.detectFormat(csv), TCsvFileFormat.csv);
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

    test('auto-detects semicolon delimiter (;)', () {
      const csv = 'ID;Product;Category\n1;Monitor;Electronics\n2;Desk;Furniture';
      final rows = TCsvParser.parse(csv);

      expect(rows.length, 3);
      expect(rows[0], ['ID', 'Product', 'Category']);
      expect(rows[1], ['1', 'Monitor', 'Electronics']);
      expect(TCsvParser.detectDelimiter(csv), ';');
      expect(TCsvParser.detectFormat(csv), TCsvFileFormat.semicolon);
    });

    test('auto-detects tab delimiter (TSV)', () {
      const tsv = "ID\tProduct\tCategory\n1\tMonitor\tElectronics\n2\tDesk\tFurniture";
      final rows = TCsvParser.parse(tsv);

      expect(rows.length, 3);
      expect(rows[0], ['ID', 'Product', 'Category']);
      expect(rows[1], ['1', 'Monitor', 'Electronics']);
      expect(TCsvParser.detectDelimiter(tsv), '\t');
      expect(TCsvParser.detectFormat(tsv), TCsvFileFormat.tsv);
    });

    test('auto-detects pipe delimiter (|)', () {
      const pipe = 'ID|Product|Category\n1|Monitor|Electronics\n2|Desk|Furniture';
      final rows = TCsvParser.parse(pipe);

      expect(rows.length, 3);
      expect(rows[0], ['ID', 'Product', 'Category']);
      expect(rows[1], ['1', 'Monitor', 'Electronics']);
      expect(TCsvParser.detectDelimiter(pipe), '|');
      expect(TCsvParser.detectFormat(pipe), TCsvFileFormat.pipe);
    });

    test('auto-detects JSON array and wrapped JSON object', () {
      const jsonArray = '[{"sku": "A1", "price": 10.5}, {"sku": "B2", "price": 20.0}]';
      expect(TCsvParser.isJson(jsonArray), true);
      expect(TCsvParser.detectFormat(jsonArray), TCsvFileFormat.json);

      const jsonWrapped = '{"data": [{"sku": "A1", "price": 10.5}]}';
      expect(TCsvParser.isJson(jsonWrapped), true);
      expect(TCsvParser.detectFormat(jsonWrapped), TCsvFileFormat.json);

      const nonJson = 'Name,Price\nItem,10';
      expect(TCsvParser.isJson(nonJson), false);
    });
  });

  group('TCsvParser Generic Parsing & toMaps tests', () {
    final columns = [
      const TCsvColumn.text(key: 'sku', header: 'SKU Code', isRequired: true, aliases: ['item_sku']),
      const TCsvColumn.number(key: 'price', header: 'Price', isRequired: true, aliases: ['cost']),
      const TCsvColumn.boolean(key: 'active', header: 'Active', defaultValue: false),
    ];

    test('parseGeneric with JSON payload extracts headers and typed rows', () {
      const json = '[{"item_sku": "SKU-99", "cost": 49.99, "active": true}]';
      final result = TCsvParser.parseGeneric(json);

      expect(result.format, TCsvFileFormat.json);
      expect(result.headers, containsAll(['item_sku', 'cost', 'active']));
      expect(result.rows.length, 1);
      expect(result.jsonMaps?.length, 1);

      final maps = TCsvParser.parseToMaps(json, columns: columns);
      expect(maps.length, 1);
      expect(maps[0]['sku'], 'SKU-99');
      expect(maps[0]['price'], 49.99);
      expect(maps[0]['active'], true);
    });

    test('parseGeneric with Semicolon DSV extracts headers and rows', () {
      const dsv = 'item_sku;cost;active\nSKU-50;19.95;true\nSKU-51;29.95;false';
      final result = TCsvParser.parseGeneric(dsv);

      expect(result.format, TCsvFileFormat.semicolon);
      expect(result.delimiter, ';');
      expect(result.headers, ['item_sku', 'cost', 'active']);
      expect(result.rows.length, 2);

      final maps = TCsvParser.parseToMaps(dsv, columns: columns);
      expect(maps.length, 2);
      expect(maps[0]['sku'], 'SKU-50');
      expect(maps[0]['price'], 19.95);
      expect(maps[0]['active'], true);
      expect(maps[1]['sku'], 'SKU-51');
      expect(maps[1]['price'], 29.95);
      expect(maps[1]['active'], false);
    });

    test('parseGeneric with Pipe DSV extracts headers and rows', () {
      const psv = 'sku|price|active\nPIPE-1|100|true';
      final result = TCsvParser.parseGeneric(psv);

      expect(result.format, TCsvFileFormat.pipe);
      expect(result.delimiter, '|');
      expect(result.headers, ['sku', 'price', 'active']);
      expect(result.rows.length, 1);

      final maps = TCsvParser.parseToMaps(psv, columns: columns);
      expect(maps.length, 1);
      expect(maps[0]['sku'], 'PIPE-1');
      expect(maps[0]['price'], 100.0);
      expect(maps[0]['active'], true);
    });
  });

  group('TCsvParser Serialization & Output Helpers tests', () {
    final headers = ['sku', 'name', 'price'];
    final rows = [
      ['A1', 'Widget "Pro"', 19.99],
      ['B2', 'Cable, 2m', 9.50],
    ];

    test('toCsv produces RFC-compliant comma-separated string', () {
      final csv = TCsvParser.toCsv(headers, rows);
      expect(csv, contains('sku,name,price'));
      expect(csv, contains('A1,"Widget ""Pro""",19.99'));
      expect(csv, contains('B2,"Cable, 2m",9.5'));
    });

    test('toTsv produces tab-separated string', () {
      final tsv = TCsvParser.toTsv(headers, rows);
      expect(tsv, contains("sku\tname\tprice"));
      expect(tsv, contains("A1\t\"Widget \"\"Pro\"\"\"\t19.99"));
    });

    test('toSemicolon produces semicolon-separated string', () {
      final semi = TCsvParser.toSemicolon(headers, rows);
      expect(semi, contains('sku;name;price'));
      expect(semi, contains('A1;"Widget ""Pro""";19.99'));
    });

    test('toPipe produces pipe-separated string', () {
      final pipe = TCsvParser.toPipe(headers, rows);
      expect(pipe, contains('sku|name|price'));
      expect(pipe, contains('A1|"Widget ""Pro"""|19.99'));
    });

    test('toJson and toJsonFromRows produce valid JSON strings', () {
      final maps = [
        {'sku': 'A1', 'price': 19.99},
        {'sku': 'B2', 'price': 9.50},
      ];

      final jsonStr = TCsvParser.toJson(maps);
      expect(jsonStr, contains('"sku": "A1"'));
      expect(jsonStr, contains('"price": 19.99'));

      final jsonFromRows = TCsvParser.toJsonFromRows(headers, rows);
      expect(jsonFromRows, contains('"sku": "A1"'));
      expect(jsonFromRows, contains('"price": 19.99'));
    });

    test('toCsvFromMaps with different delimiters', () {
      final maps = [
        {'sku': 'A1', 'name': 'Item A', 'price': 10.0},
      ];

      final comma = TCsvParser.toCsvFromMaps(maps);
      expect(comma, contains('sku,name,price'));
      expect(comma, contains('A1,Item A,10.0'));

      final semi = TCsvParser.toSemicolonFromMaps(maps);
      expect(semi, contains('sku;name;price'));
      expect(semi, contains('A1;Item A;10.0'));

      final pipe = TCsvParser.toPipeFromMaps(maps);
      expect(pipe, contains('sku|name|price'));
      expect(pipe, contains('A1|Item A|10.0'));

      final tsv = TCsvParser.toTsvFromMaps(maps);
      expect(tsv, contains("sku\tname\tprice"));
    });

    test('generateTemplate across multiple formats', () {
      final columns = [
        const TCsvColumn.text(key: 'name', header: 'Product Name', isRequired: true),
        const TCsvColumn.number(key: 'price', header: 'Price'),
        const TCsvColumn.boolean(key: 'in_stock', header: 'In Stock'),
      ];

      final csvTemplate = TCsvParser.generateTemplate(columns, format: TCsvFileFormat.csv);
      expect(csvTemplate, contains('Product Name,Price,In Stock'));
      expect(csvTemplate, contains('Sample Product Name'));

      final semiTemplate = TCsvParser.generateTemplate(columns, format: TCsvFileFormat.semicolon);
      expect(semiTemplate, contains('Product Name;Price;In Stock'));

      final tsvTemplate = TCsvParser.generateTemplate(columns, format: TCsvFileFormat.tsv);
      expect(tsvTemplate, contains("Product Name\tPrice\tIn Stock"));

      final pipeTemplate = TCsvParser.generateTemplate(columns, format: TCsvFileFormat.pipe);
      expect(pipeTemplate, contains('Product Name|Price|In Stock'));

      final jsonTemplate = TCsvParser.generateTemplate(columns, format: TCsvFileFormat.json);
      expect(jsonTemplate, contains('"name": "Sample Product Name"'));
      expect(jsonTemplate, contains('"price": 29.99'));
      expect(jsonTemplate, contains('"in_stock": false'));
    });

    test('formatOutput helper works across formats', () {
      final maps = [
        {'id': '1', 'name': 'Alpha'},
      ];

      expect(TCsvParser.formatOutput(maps, format: TCsvFileFormat.json), contains('"name": "Alpha"'));
      expect(TCsvParser.formatOutput(maps, format: TCsvFileFormat.csv), contains('id,name'));
      expect(TCsvParser.formatOutput(maps, format: TCsvFileFormat.semicolon), contains('id;name'));
      expect(TCsvParser.formatOutput(maps, format: TCsvFileFormat.tsv), contains("id\tname"));
      expect(TCsvParser.formatOutput(maps, format: TCsvFileFormat.pipe), contains('id|name'));
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

    testWidgets('adding new row in All tab immediately updates the table without switching tabs', (tester) async {
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
                  {'name': 'Item A', 'price': 10.0},
                  {'name': 'Item B', 'price': 20.0},
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All (2)'), findsOneWidget);
      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);

      // Tap 'Add Row' button
      await tester.tap(find.text('Add Row'));
      await tester.pumpAndSettle();

      // Row count in tabs should be updated immediately
      expect(find.text('All (3)'), findsOneWidget);
      expect(find.text('Errors (1)'), findsOneWidget); // New empty row has validation errors

      // The 3rd row should be rendered in the table immediately
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
    });

    testWidgets('TCsvHeaderMapperModal renders TSelect dropdowns for column mapping', (tester) async {
      final columns = [
        const TCsvColumn.text(key: 'sku', header: 'SKU', isRequired: true),
        const TCsvColumn.text(key: 'name', header: 'Product Name', isRequired: true),
      ];
      final headers = ['SKU', 'Title', 'Extra'];
      final initialMapping = TCsvHeaderMapping({'sku': 'SKU', 'name': null});

      await tester.pumpWidget(
        MaterialApp(
          theme: TAppTheme.defaultTheme().lightTheme,
          home: Scaffold(
            body: TCsvHeaderMapperModal(
              expectedColumns: columns,
              csvHeaders: headers,
              sampleRows: const [
                ['SKU-01', 'Widget A', '123'],
              ],
              initialMapping: initialMapping,
              onConfirm: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check TSelect dropdowns are used for mapping
      expect(find.byType(TSelect<String, String, String>), findsNWidgets(2));
      expect(find.text('SKU'), findsAtLeastNWidgets(1));
      expect(find.text('-- Do not import --'), findsAtLeastNWidgets(1));
    });

    testWidgets('card view renders number fields left-aligned with proper spacing between fields', (tester) async {
      tester.view.physicalSize = const Size(700, 800); // Forces card view
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final columns = [
        const TCsvColumn.text(key: 'name', header: 'Product Name'),
        const TCsvColumn.number(key: 'price', header: 'Price (\$)'),
        const TCsvColumn.integer(key: 'qty', header: 'Stock Qty'),
      ];

      final lightTheme = TAppTheme.defaultTheme().lightTheme;
      final widgetTheme = lightTheme.extension<TWidgetThemeExtension>()!;
      final cardTheme = lightTheme.copyWith(
        extensions: [
          ...lightTheme.extensions.values.where((e) => e is! TWidgetThemeExtension),
          widgetTheme.copyWith(
            tableTheme: widgetTheme.tableTheme.copyWith(forceCardStyle: true),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: cardTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: TCsvEditor(
                columns: columns,
                initialData: const [
                  {'name': 'iPhone 15 Pro', 'price': 999.0, 'qty': 50},
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check card is rendered
      expect(find.byType(TTableMobileCard<TCsvRow, String>), findsOneWidget);
      expect(find.text('Price (\$)'), findsOneWidget);
      expect(find.text('999.0'), findsOneWidget);
      expect(find.text('Stock Qty'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);

      final priceLabelRect = tester.getRect(find.text('Price (\$)'));
      final priceValueRect = tester.getRect(find.text('999.0'));

      expect(priceValueRect.top, greaterThanOrEqualTo(priceLabelRect.top));
    });
  });
}
