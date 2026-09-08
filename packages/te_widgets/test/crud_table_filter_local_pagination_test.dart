import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

class TestProduct {
  final int id;
  final String name;
  final double price;
  final bool inStock;
  final DateTime createdAt;

  const TestProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.inStock,
    required this.createdAt,
  });
}

class TestProductForm extends TFormBase {
  final name = TFieldProp('');
  final price = TFieldProp<double>(0.0);

  @override
  List<TFormField> get fields => [
        TFormField.text(name, 'Name'),
        TFormField.number<double>(price, 'Price'),
      ];
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  final sampleProducts = [
    TestProduct(
      id: 1,
      name: 'MacBook Pro',
      price: 1999.99,
      inStock: true,
      createdAt: DateTime(2026, 1, 15),
    ),
    TestProduct(
      id: 2,
      name: 'iPhone 16 Pro',
      price: 999.99,
      inStock: true,
      createdAt: DateTime(2026, 2, 20),
    ),
    TestProduct(
      id: 3,
      name: 'iPad Air',
      price: 599.99,
      inStock: false,
      createdAt: DateTime(2026, 3, 10),
    ),
    TestProduct(
      id: 4,
      name: 'AirPods Max',
      price: 549.99,
      inStock: false,
      createdAt: DateTime(2026, 4, 5),
    ),
  ];

  group('TFilterEvaluator Tests', () {
    test('matches string operations (contains, eq, ne, startsWith, endsWith, in, notIn)', () {
      final item = {'name': 'MacBook Pro', 'price': 1999.99};

      expect(TFilterEvaluator.matches(item, {'name': {'contains': 'Mac'}}), isTrue);
      expect(TFilterEvaluator.matches(item, {'name': {'contains': 'Windows'}}), isFalse);
      expect(TFilterEvaluator.matches(item, {'name': {'startsWith': 'mac'}}), isTrue);
      expect(TFilterEvaluator.matches(item, {'name': {'endsWith': 'pro'}}), isTrue);
      expect(TFilterEvaluator.matches(item, {'name': {'eq': 'macbook pro'}}), isTrue);
      expect(TFilterEvaluator.matches(item, {'name': {'ne': 'macbook air'}}), isTrue);
      expect(TFilterEvaluator.matches(item, {'name': {'in': ['MacBook Pro', 'Dell XPS']}}), isTrue);
      expect(TFilterEvaluator.matches(item, {'name': {'notIn': ['Dell XPS']}}), isTrue);
      expect(TFilterEvaluator.matches(item, {'name': {'notIn': ['MacBook Pro']}}), isFalse);
    });

    test('matches numeric comparisons (gt, gte, lt, lte, eq)', () {
      final item = {'price': 999.99};

      expect(TFilterEvaluator.matches(item, {'price': {'gt': 500}}), isTrue);
      expect(TFilterEvaluator.matches(item, {'price': {'gte': 999.99}}), isTrue);
      expect(TFilterEvaluator.matches(item, {'price': {'lt': 1500}}), isTrue);
      expect(TFilterEvaluator.matches(item, {'price': {'lte': 999.99}}), isTrue);
      expect(TFilterEvaluator.matches(item, {'price': {'gt': 1000}}), isFalse);
      expect(TFilterEvaluator.matches(item, {'price': {'eq': 999.99}}), isTrue);
    });

    test('matches boolean and nullability checks', () {
      final inStockItem = {'inStock': true, 'note': null};
      final outOfStockItem = {'inStock': false, 'note': 'Special order'};

      expect(TFilterEvaluator.matches(inStockItem, {'inStock': {'eq': true}}), isTrue);
      expect(TFilterEvaluator.matches(inStockItem, {'note': {'isNull': true}}), isTrue);
      expect(TFilterEvaluator.matches(outOfStockItem, {'note': {'isNull': false}}), isTrue);
      expect(TFilterEvaluator.matches(outOfStockItem, {'note': {'isNull': true}}), isFalse);
    });

    test('matches with TFilterDef map on typed model', () {
      final product = sampleProducts[0];
      final defs = [
        TFilter.text<TestProduct>('Product Name', key: 'name', map: (x) => x.name),
        TFilter.number<TestProduct>('Price', key: 'price', map: (x) => x.price),
        TFilter.boolean<TestProduct>('In Stock', key: 'inStock', map: (x) => x.inStock),
      ];

      expect(TFilterEvaluator.matches(product, {'name': {'contains': 'Mac'}}, defs), isTrue);
      expect(TFilterEvaluator.matches(product, {'price': {'gte': 1000}}, defs), isTrue);
      expect(TFilterEvaluator.matches(product, {'price': {'lt': 1000}}, defs), isFalse);
      expect(TFilterEvaluator.matches(product, {'inStock': {'eq': true}}, defs), isTrue);
    });

    test('matches nested map dot paths and nested object structures', () {
      final nestedMap = {
        'user': {
          'profile': {
            'fullName': 'Alice Smith',
            'age': 28,
          },
          'address': {
            'city': 'San Francisco',
            'zipCode': '94105',
          }
        },
        'status': 'active',
      };

      // 1. Dot-path key in flat criteria
      expect(TFilterEvaluator.matches(nestedMap, {'user.profile.fullName': {'contains': 'Alice'}}), isTrue);
      expect(TFilterEvaluator.matches(nestedMap, {'user.profile.age': {'gte': 21}}), isTrue);
      expect(TFilterEvaluator.matches(nestedMap, {'user.address.city': {'eq': 'San Francisco'}}), isTrue);
      expect(TFilterEvaluator.matches(nestedMap, {'user.address.city': {'eq': 'London'}}), isFalse);

      // 2. Nested JSON criteria structure
      expect(
        TFilterEvaluator.matches(nestedMap, {
          'user': {
            'address': {
              'city': {'eq': 'San Francisco'},
            }
          }
        }),
        isTrue,
      );

      // 3. Nested JSON to rules extraction
      final defs = [
        TFilter.text('City', key: 'user.address.city'),
        TFilter.number('Age', key: 'user.profile.age'),
      ];
      final extractedRules = TFilterRule.fromFilterJson({
        'user': {
          'address': {
            'city': {'contains': 'Francisco'},
          }
        }
      }, defs);

      expect(extractedRules.length, 1);
      expect(extractedRules.first.fieldKey, 'user.address.city');
      expect(extractedRules.first.operatorId, 'contains');
      expect(extractedRules.first.value, 'Francisco');
    });

    test('TFilter.map supports typed model expressions without manual string key', () {
      final product = sampleProducts[0];

      // Using TFilter.map with lambda expression
      final nameFilter = TFilter.map<TestProduct, String>('Custom Title With Mismatched Case', (p) => p.name);
      final priceFilter = TFilter.map<TestProduct, double>('Unit Retail Price', (p) => p.price);
      final inStockFilter = TFilter.map<TestProduct, bool>('Available In Warehouse', (p) => p.inStock);

      expect(nameFilter.type, TFilterType.text);
      expect(priceFilter.type, TFilterType.number);
      expect(inStockFilter.type, TFilterType.boolean);

      final defs = [nameFilter, priceFilter, inStockFilter];

      // Evaluator resolves using the expression map even if the key does not match any field on the model!
      expect(TFilterEvaluator.matches(product, {nameFilter.key: {'contains': 'MacBook'}}, defs), isTrue);
      expect(TFilterEvaluator.matches(product, {priceFilter.key: {'gt': 1500.0}}, defs), isTrue);
      expect(TFilterEvaluator.matches(product, {inStockFilter.key: {'eq': true}}, defs), isTrue);
    });
  });

  group('TListController Local Pagination with TFilter Tests', () {
    test('filters localItems using handleAdvancedSearchChange and handleFilterRulesChange', () {
      final defs = [
        TFilter.text<TestProduct>('Name', key: 'name', map: (x) => x.name),
        TFilter.number<TestProduct>('Price', key: 'price', map: (x) => x.price),
        TFilter.boolean<TestProduct>('In Stock', key: 'inStock', map: (x) => x.inStock),
      ];

      final controller = TListController<TestProduct, int>(
        items: sampleProducts,
        itemKey: (p) => p.id,
        itemsPerPage: 10,
        filterDefs: defs,
      );

      expect(controller.displayItems.length, 4);
      expect(controller.totalItems, 4);

      // Filter by inStock == true
      controller.handleAdvancedSearchChange({'inStock': {'eq': true}});
      expect(controller.displayItems.length, 2);
      expect(controller.totalItems, 2);
      expect(controller.displayItems.map((e) => e.data.name).toList(), ['MacBook Pro', 'iPhone 16 Pro']);
      expect(controller.activeFilterCount, 1);
      expect(controller.isFiltered, isTrue);

      // Combine filter with price > 1000
      controller.handleAdvancedSearchChange({
        'inStock': {'eq': true},
        'price': {'gt': 1000.0},
      });
      expect(controller.displayItems.length, 1);
      expect(controller.totalItems, 1);
      expect(controller.displayItems.first.data.name, 'MacBook Pro');

      // Clear filter
      controller.clearAdvancedSearch();
      expect(controller.displayItems.length, 4);
      expect(controller.totalItems, 4);
      expect(controller.activeFilterCount, 0);

      // Filter via rules
      final rules = [
        TFilterRule(fieldKey: 'name', operatorId: 'contains', value: 'Air'),
      ];
      controller.handleFilterRulesChange(rules, defs);
      expect(controller.displayItems.length, 2);
      expect(controller.displayItems.map((e) => e.data.name).toList(), ['iPad Air', 'AirPods Max']);

      controller.dispose();
    });
  });

  group('TTableHeader autoGenerateFilterDefs Tests', () {
    test('auto-generates filter definitions with inferred and explicit types', () {
      final headers = [
        TTableHeader<TestProduct, int>.map('Name', (p) => p.name),
        TTableHeader<TestProduct, int>.numberField('Price', (p) => p.price, (p, v) {}),
        TTableHeader<TestProduct, int>.toggle('In Stock', (p) => p.inStock, (p, v) {}),
        TTableHeader<TestProduct, int>.datetime('Created At', (p) => p.createdAt),
        TTableHeader<TestProduct, int>.actions((item) => []),
        TTableHeader<TestProduct, int>.image('Thumbnail', (p) => null),
      ];

      final defs = TTableHeader.autoGenerateFilterDefs(headers, sampleItems: sampleProducts);

      // actions and image should be skipped (filterable = false or map == null)
      expect(defs.length, 4);
      expect(defs[0].key, 'name');
      expect(defs[0].type, TFilterType.text);

      expect(defs[1].key, 'price');
      expect(defs[1].type, TFilterType.number);

      expect(defs[2].key, 'inStock');
      expect(defs[2].type, TFilterType.boolean);

      expect(defs[3].key, 'createdAt');
      expect(defs[3].type, TFilterType.dateTime);

      // Verify map expressions work
      final testProd = sampleProducts[0];
      expect(defs[0].map!(testProd), 'MacBook Pro');
      expect(defs[1].map!(testProd), 1999.99);
      expect(defs[2].map!(testProd), true);
      expect(defs[3].map!(testProd), DateTime(2026, 1, 15));
    });

    test('TTableHeader.map maps directly without string key matching issues', () {
      final headers = [
        // Title has human-friendly text that does NOT match model property name
        TTableHeader<TestProduct, int>.map('Product Display Title', (p) => p.name),
        TTableHeader<TestProduct, int>.map('Retail Price USD', (p) => p.price),
        TTableHeader<TestProduct, int>.map('Is Currently Available', (p) => p.inStock),
      ];

      final defs = TTableHeader.autoGenerateFilterDefs(headers, sampleItems: sampleProducts);

      expect(defs.length, 3);
      expect(defs[0].key, 'productDisplayTitle');
      expect(defs[1].key, 'retailPriceUsd');
      expect(defs[2].key, 'isCurrentlyAvailable');

      final controller = TListController<TestProduct, int>(
        items: sampleProducts,
        itemKey: (p) => p.id,
        filterDefs: defs,
      );

      // Filtering with the auto-generated key evaluates the direct prop expression!
      controller.handleAdvancedSearchChange({
        'productDisplayTitle': {'contains': 'iPhone'},
      });

      expect(controller.displayItems.length, 1);
      expect(controller.displayItems.first.data.name, 'iPhone 16 Pro');

      controller.handleAdvancedSearchChange({
        'retailPriceUsd': {'lt': 600.0},
      });

      expect(controller.displayItems.length, 2);
      expect(controller.displayItems.map((e) => e.data.name).toList(), ['iPad Air', 'AirPods Max']);

      controller.dispose();
    });
  });

  group('TCrudTable Filter Button and Local/Server Pagination Widget Tests', () {
    testWidgets('Client-side TCrudTable displays filter button with surface theme and opens filter dropdown on tap',
        (WidgetTester tester) async {
      final headers = [
        TTableHeader<TestProduct, int>.map('Name', (p) => p.name),
        TTableHeader<TestProduct, int>.map('Price', (p) => p.price),
        TTableHeader<TestProduct, int>.toggle('In Stock', (p) => p.inStock, (p, v) {}),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TCrudTable<TestProduct, int, TestProductForm>(
              items: sampleProducts,
              itemKey: (p) => p.id,
              headers: headers,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the filter button (should exist for client side)
      final filterIconFinder = find.byWidgetPredicate(
        (w) => w is TIcon && w.icon == HugeIcons.strokeRoundedFilter,
      );
      expect(filterIconFinder, findsOneWidget);

      // Verify 4 rows rendered initially
      expect(find.text('MacBook Pro'), findsOneWidget);
      expect(find.text('iPhone 16 Pro'), findsOneWidget);
      expect(find.text('iPad Air'), findsOneWidget);
      expect(find.text('AirPods Max'), findsOneWidget);

      // Tap filter button to open dropdown
      await tester.tap(filterIconFinder);
      await tester.pumpAndSettle();

      // Dropdown with TFilterField should be open
      expect(find.byType(TFilterField<Map<String, dynamic>>), findsOneWidget);
      expect(find.text('No filter conditions applied.'), findsOneWidget);

      // Add a filter condition inside the dropdown
      final addFilterBtn = find.text('Add Filter').first;
      await tester.tap(addFilterBtn);
      await tester.pumpAndSettle();

      // Field selector should be present with auto-generated definitions
      expect(find.byType(TSelect<TFilterDef, String, String>), findsOneWidget);
    });

    testWidgets('Server-side TCrudTable only displays filter button if filters are manually passed',
        (WidgetTester tester) async {
      final headers = [
        TTableHeader<TestProduct, int>.map('Name', (p) => p.name),
        TTableHeader<TestProduct, int>.map('Price', (p) => p.price),
      ];

      // 1. Server-side table WITHOUT manual filters -> NO filter button
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TCrudTable<TestProduct, int, TestProductForm>(
              onLoad: (options) async => TLoadResult(sampleProducts, sampleProducts.length),
              itemKey: (p) => p.id,
              headers: headers,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Filter button should NOT be present
      expect(
        find.byWidgetPredicate((w) => w is TIcon && w.icon == HugeIcons.strokeRoundedFilter),
        findsNothing,
      );

      final explicitFilters = [
        TFilter.text<TestProduct>('Product Name', key: 'name'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TCrudTable<TestProduct, int, TestProductForm>(
              onLoad: (options) async => TLoadResult(sampleProducts, sampleProducts.length),
              itemKey: (p) => p.id,
              headers: headers,
              filters: explicitFilters,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Filter button should now be present
      expect(
        find.byWidgetPredicate((w) => w is TIcon && w.icon == HugeIcons.strokeRoundedFilter),
        findsOneWidget,
      );
    });
  });
}
