import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

enum ProductStatus { inStock, outOfStock, discontinued }

class ProductFilter {
  final StringFilter? name;
  final GuidFilter? brandId;
  final GuidFilter? categoryId;
  final BoolFilter? isActive;
  final DateTimeFilter? createdAt;
  final NumberFilter<double>? price;
  final EnumFilter<ProductStatus>? status;

  const ProductFilter({
    this.name,
    this.brandId,
    this.categoryId,
    this.isActive,
    this.createdAt,
    this.price,
    this.status,
  });

  factory ProductFilter.fromJson(Map<String, dynamic> json) => ProductFilter(
        name: json['name'] != null ? StringFilter.fromJson(Map<String, dynamic>.from(json['name'] as Map)) : null,
        brandId: json['brandId'] != null ? GuidFilter.fromJson(Map<String, dynamic>.from(json['brandId'] as Map)) : null,
        categoryId: json['categoryId'] != null ? GuidFilter.fromJson(Map<String, dynamic>.from(json['categoryId'] as Map)) : null,
        isActive: json['isActive'] != null ? BoolFilter.fromJson(Map<String, dynamic>.from(json['isActive'] as Map)) : null,
        createdAt: json['createdAt'] != null ? DateTimeFilter.fromJson(Map<String, dynamic>.from(json['createdAt'] as Map)) : null,
        price: json['price'] != null ? NumberFilter<double>.fromJson(Map<String, dynamic>.from(json['price'] as Map)) : null,
        status: json['status'] != null
            ? EnumFilter<ProductStatus>.fromJson(Map<String, dynamic>.from(json['status'] as Map), values: ProductStatus.values)
            : null,
      );

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name!.toJson(),
        if (brandId != null) 'brandId': brandId!.toJson(),
        if (categoryId != null) 'categoryId': categoryId!.toJson(),
        if (isActive != null) 'isActive': isActive!.toJson(),
        if (createdAt != null) 'createdAt': createdAt!.toJson(),
        if (price != null) 'price': price!.toJson(),
        if (status != null) 'status': status!.toJson(),
      };
}

class ProductFilterForm extends TFormBase {
  final filterProp = TFieldProp<ProductFilter?>(null);

  @override
  List<TFormField> get fields => [
        TFormField.filter<ProductFilter>(
          filterProp,
          'Product Filters',
          construct: (json) => ProductFilter.fromJson(json),
          filters: [
            TFilter.text('Name', key: 'name'),
            TFilter.guid('Brand ID', key: 'brandId'),
            TFilter.guid('Category ID', key: 'categoryId'),
            TFilter.boolean('Is Active', key: 'isActive'),
            TFilter.dateTime('Created At', key: 'createdAt'),
            TFilter.number<double>('Price', key: 'price'),
            TFilter.enumFilter<ProductStatus>('Status', key: 'status', values: ProductStatus.values),
          ],
        ),
      ];
}

void main() {
  final theme = TAppTheme.defaultTheme().lightTheme;

  group('Filter Models Unit Tests', () {
    test('StringFilter serialization, deserialization, and methods', () {
      const filter = StringFilter(
        contains: 'Phone',
        startsWith: 'i',
        inField: ['iPhone 15', 'iPhone 16'],
      );

      final json = filter.toJson();
      expect(json['contains'], 'Phone');
      expect(json['startsWith'], 'i');
      expect(json['in'], ['iPhone 15', 'iPhone 16']);

      final deserialized = StringFilter.fromJson(json);
      expect(deserialized.contains, 'Phone');
      expect(deserialized.startsWith, 'i');
      expect(deserialized.inField, ['iPhone 15', 'iPhone 16']);
      expect(deserialized == filter, isTrue);
      expect(deserialized.isNotEmpty, isTrue);

      const emptyFilter = StringFilter();
      expect(emptyFilter.isEmpty, isTrue);
    });

    test('NumberFilter serialization and parsing for int/double', () {
      const numFilter = NumberFilter<double>(
        gte: 100.0,
        lte: 500.0,
        notIn: [200.0, 300.0],
      );

      final json = numFilter.toJson();
      expect(json['gte'], 100.0);
      expect(json['lte'], 500.0);
      expect(json['notIn'], [200.0, 300.0]);

      final deserialized = NumberFilter<double>.fromJson(json);
      expect(deserialized.gte, 100.0);
      expect(deserialized.lte, 500.0);
      expect(deserialized.notIn, [200.0, 300.0]);
      expect(deserialized == numFilter, isTrue);
    });

    test('DateTimeFilter serialization and ISO parsing', () {
      final now = DateTime.utc(2026, 9, 3, 12, 0, 0);
      final dateFilter = DateTimeFilter(gte: now, isNull: false);

      final json = dateFilter.toJson();
      expect(json['gte'], now.toIso8601String());
      expect(json['isNull'], false);

      final deserialized = DateTimeFilter.fromJson(json);
      expect(deserialized.gte, now);
      expect(deserialized.isNull, false);
    });

    test('BoolFilter and GuidFilter serialization', () {
      const boolFilter = BoolFilter(eq: true, isNull: false);
      expect(boolFilter.toJson(), {'isNull': false, 'eq': true});

      const guidFilter = GuidFilter(eq: '123e4567-e89b-12d3-a456-426614174000');
      expect(guidFilter.toJson(), {'eq': '123e4567-e89b-12d3-a456-426614174000'});
      final deserializedGuid = GuidFilter.fromJson(guidFilter.toJson());
      expect(deserializedGuid.eq, '123e4567-e89b-12d3-a456-426614174000');
    });

    test('EnumFilter serialization and value parsing', () {
      const enumFilter = EnumFilter<ProductStatus>(eq: ProductStatus.inStock, notIn: [ProductStatus.discontinued]);
      final json = enumFilter.toJson();
      expect(json['eq'], 'inStock');
      expect(json['notIn'], ['discontinued']);

      final deserialized = EnumFilter<ProductStatus>.fromJson(json, values: ProductStatus.values);
      expect(deserialized.eq, ProductStatus.inStock);
      expect(deserialized.notIn, [ProductStatus.discontinued]);
    });
  });

  group('TFilterRule & Serialization Integration', () {
    test('rulesToJson and fromFilterJson conversions', () {
      final defs = [
        TFilter.text('Name', key: 'name'),
        TFilter.number<double>('Price', key: 'price'),
        TFilter.boolean('Active', key: 'isActive'),
      ];

      final rules = [
        TFilterRule(fieldKey: 'name', operatorId: 'contains', value: 'Google'),
        TFilterRule(fieldKey: 'price', operatorId: 'gte', value: 99.99),
        TFilterRule(fieldKey: 'isActive', operatorId: 'eq', value: true),
      ];

      final json = TFilterRule.rulesToJson(rules, defs);
      expect(json['name'], {'contains': 'Google'});
      expect(json['price'], {'gte': 99.99});
      expect(json['isActive'], {'eq': true});

      final restoredRules = TFilterRule.fromFilterJson(json, defs);
      expect(restoredRules.length, 3);
      expect(restoredRules.any((r) => r.fieldKey == 'name' && r.operatorId == 'contains' && r.value == 'Google'), isTrue);
      expect(restoredRules.any((r) => r.fieldKey == 'price' && r.operatorId == 'gte' && r.value == 99.99), isTrue);
      expect(restoredRules.any((r) => r.fieldKey == 'isActive' && r.operatorId == 'eq' && r.value == true), isTrue);
    });
  });

  group('TFilterField & TFormField Widget Tests', () {
    testWidgets('Renders empty state and adds a filter rule', (WidgetTester tester) async {
      ProductFilter? emittedFilter;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TFilterField<ProductFilter>(
                  label: 'Filter Products',
                  construct: (json) => ProductFilter.fromJson(json),
                  filters: [
                    TFilter.text('Name', key: 'name'),
                    TFilter.number<double>('Price', key: 'price'),
                    TFilter.boolean('Is Active', key: 'isActive'),
                  ],
                  onValueChanged: (val) {
                    emittedFilter = val;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Filter Products'), findsOneWidget);
      expect(find.text('No filter conditions applied.'), findsOneWidget);

      // Tap "Add Filter"
      final addBtn = find.text('Add Filter').first;
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Verify a rule row is created with Field TSelect, Operator TDropdown, Value input
      expect(find.byType(TSelect<TFilterDef, String, String>), findsOneWidget);
      expect(find.byType(TDropdown), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Badge with count 1
      expect(emittedFilter, isNotNull);
    });

    testWidgets('TFormField.filter integrates within TFormBuilder', (WidgetTester tester) async {
      final form = ProductFilterForm();

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TFormBuilder(input: form),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Product Filters'), findsOneWidget);
      expect(find.text('No filter conditions applied.'), findsOneWidget);

      // Add a filter condition
      await tester.tap(find.text('Add Filter').first);
      await tester.pumpAndSettle();

      expect(form.isChanged, isTrue);
    });

    testWidgets('TFilterField with isNull operator does not render switch or extra input', (WidgetTester tester) async {
      Map<String, dynamic>? emittedJson;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TFilterField<Map<String, dynamic>>(
                  filters: [
                    TFilter.boolean('Is Active', key: 'isActive'),
                  ],
                  construct: (json) => json,
                  onValueChanged: (val) => emittedJson = val,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add filter condition
      await tester.tap(find.text('Add Filter').first);
      await tester.pumpAndSettle();

      // Initial operator is 'eq', so a TSwitch for boolean value is present
      expect(find.byType(TSwitch), findsOneWidget);

      // Tap operator TDropdown trigger to switch to 'Is Null'
      final operatorDropdown = find.byType(TDropdown);
      await tester.tap(operatorDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Is Null'));
      await tester.pumpAndSettle();

      // For isNull operator, no TSwitch or extra input widget should be rendered
      expect(find.byType(TSwitch), findsNothing);
      expect(emittedJson?['isActive'], {'isNull': true});
    });

    test('TDropdownTheme.copyWith creates a new instance with overridden values', () {
      final baseTheme = TDropdownTheme.defaultTheme(const ColorScheme.light());
      final copied = baseTheme.copyWith(
        defaultColor: Colors.red,
        iconSize: 24.0,
        offset: 12.0,
        fontSize: 16.0,
      );

      expect(copied, isA<TDropdownTheme>());
      expect(copied.defaultColor, Colors.red);
      expect(copied.iconSize, 24.0);
      expect(copied.offset, 12.0);
      expect(copied.fontSize, 16.0);
      expect(copied.hoverColor, baseTheme.hoverColor);
      expect(copied.activeColor, baseTheme.activeColor);
    });

    testWidgets('TFilter.guid and TFilter.select with onLoad renders TSelect for single and TMultiSelect for list operators',
        (WidgetTester tester) async {
      const serverCategories = [
        ('cat-1', 'Electronics', 'ELEC'),
        ('cat-2', 'Clothing', 'CLOTH'),
      ];

      final filterDef = TFilter.guid<(String, String, String)>(
        'Category',
        key: 'categoryId',
        onLoad: (options) async {
          return const TLoadResult<(String, String, String)>(
            serverCategories,
            2,
            hasNextPage: false,
          );
        },
        itemText: (x) => x.$2,
        itemValue: (x) => x.$1,
        itemSubText: (x) => x.$3,
      );

      Map<String, dynamic>? emittedJson;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: SizedBox(
                    width: 700,
                    child: TFilterField<Map<String, dynamic>>(
                      filters: [filterDef],
                      construct: (json) => json,
                      onValueChanged: (val) {
                        emittedJson = val;
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add category filter rule
      await tester.tap(find.text('Add Filter').first);
      await tester.pumpAndSettle();

      // For 'eq' operator, TSelect is rendered
      expect(find.byType(TSelect<dynamic, dynamic, String>), findsWidgets);

      // Change operator to 'In'
      final operatorDropdown = find.byType(TDropdown);
      await tester.tap(operatorDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('In'));
      await tester.pumpAndSettle();

      // For list operator 'In', TMultiSelect is rendered
      expect(find.byType(TMultiSelect<dynamic, dynamic, String>), findsOneWidget);
      expect(emittedJson, isNotNull);
    });
  });
}
