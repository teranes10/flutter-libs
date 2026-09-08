import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum ProductCategory { electronics, clothing, books, home, beauty }

enum ProductStatus { inStock, lowStock, outOfStock, discontinued }

class StatusItem {
  final String id;
  final String label;
  final String description;
  final dynamic icon;

  const StatusItem(this.id, this.label, this.description, this.icon);
}

const productStatusItems = [
  StatusItem('active', 'Active', 'Product is live and visible to all customers', HugeIcons.strokeRoundedCheckmarkCircle01),
  StatusItem('draft', 'Draft', 'Product is still being created or edited', HugeIcons.strokeRoundedEdit02),
  StatusItem('pending', 'Pending Approval', 'Waiting for catalog manager review', HugeIcons.strokeRoundedClock01),
  StatusItem('archived', 'Archived', 'Product is hidden and no longer available', HugeIcons.strokeRoundedArchive01),
  StatusItem('banned', 'Suspended', 'Product violated marketplace policies', HugeIcons.strokeRoundedAlert02),
];

class CategoryEntity {
  final String id;
  final String name;
  final String code;
  const CategoryEntity(this.id, this.name, this.code);
}

const mockCategories = [
  CategoryEntity('a1111111-1111-1111-1111-111111111111', 'Smartphones & Mobile', 'ELEC-PHONE'),
  CategoryEntity('a2222222-2222-2222-2222-222222222222', 'Laptops & Computers', 'ELEC-LAPTOP'),
  CategoryEntity('a3333333-3333-3333-3333-333333333333', 'Audio & Headphones', 'ELEC-AUDIO'),
  CategoryEntity('a4444444-4444-4444-4444-444444444444', 'Men\'s Apparel', 'CLOTH-MEN'),
  CategoryEntity('a5555555-5555-5555-5555-555555555555', 'Women\'s Fashion', 'CLOTH-WOMEN'),
  CategoryEntity('a6666666-6666-6666-6666-666666666666', 'Home & Kitchen', 'HOME-KIT'),
  CategoryEntity('a7777777-7777-7777-7777-777777777777', 'Books & Stationery', 'BOOK-STAT'),
];

class BrandEntity {
  final String id;
  final String name;
  final String country;
  const BrandEntity(this.id, this.name, this.country);
}

const mockBrands = [
  BrandEntity('b1111111-1111-1111-1111-111111111111', 'Apple', 'USA'),
  BrandEntity('b2222222-2222-2222-2222-222222222222', 'Samsung', 'South Korea'),
  BrandEntity('b3333333-3333-3333-3333-333333333333', 'Sony', 'Japan'),
  BrandEntity('b4444444-4444-4444-4444-444444444444', 'Nike', 'USA'),
  BrandEntity('b5555555-5555-5555-5555-555555555555', 'Adidas', 'Germany'),
];

Future<TLoadResult<CategoryEntity>> _loadCategories(TLoadOptions<CategoryEntity> options) async {
  await Future.delayed(const Duration(milliseconds: 100));
  final query = options.search?.toLowerCase() ?? '';
  final filtered = mockCategories.where((c) => c.name.toLowerCase().contains(query) || c.code.toLowerCase().contains(query)).toList();
  return TLoadResult<CategoryEntity>(filtered, filtered.length, hasNextPage: false);
}

Future<TLoadResult<BrandEntity>> _loadBrands(TLoadOptions<BrandEntity> options) async {
  await Future.delayed(const Duration(milliseconds: 100));
  final query = options.search?.toLowerCase() ?? '';
  final filtered = mockBrands.where((b) => b.name.toLowerCase().contains(query) || b.country.toLowerCase().contains(query)).toList();
  return TLoadResult<BrandEntity>(filtered, filtered.length, hasNextPage: false);
}

class ProductFilter {
  final StringFilter? name;
  final GuidFilter? brandId;
  final GuidFilter? categoryId;
  final BoolFilter? isActive;
  final DateTimeFilter? createdAt;
  final NumberFilter<double>? price;
  final EnumFilter<ProductCategory>? category;
  final EnumFilter<ProductStatus>? status;

  const ProductFilter({this.name, this.brandId, this.categoryId, this.isActive, this.createdAt, this.price, this.category, this.status});

  factory ProductFilter.fromJson(Map<String, dynamic> json) => ProductFilter(
    name: json['name'] != null ? StringFilter.fromJson(Map<String, dynamic>.from(json['name'] as Map)) : null,
    brandId: json['brandId'] != null ? GuidFilter.fromJson(Map<String, dynamic>.from(json['brandId'] as Map)) : null,
    categoryId: json['categoryId'] != null ? GuidFilter.fromJson(Map<String, dynamic>.from(json['categoryId'] as Map)) : null,
    isActive: json['isActive'] != null ? BoolFilter.fromJson(Map<String, dynamic>.from(json['isActive'] as Map)) : null,
    createdAt: json['createdAt'] != null ? DateTimeFilter.fromJson(Map<String, dynamic>.from(json['createdAt'] as Map)) : null,
    price: json['price'] != null ? NumberFilter<double>.fromJson(Map<String, dynamic>.from(json['price'] as Map)) : null,
    category: json['category'] != null
        ? EnumFilter<ProductCategory>.fromJson(Map<String, dynamic>.from(json['category'] as Map), values: ProductCategory.values)
        : null,
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
    if (category != null) 'category': category!.toJson(),
    if (status != null) 'status': status!.toJson(),
  };
}

List<TFilterDef> _createProductFilterDefs() => [
  TFilter.text('Product Name', key: 'name', icon: HugeIcons.strokeRoundedText, placeholder: 'e.g. iPhone 16 Pro'),
  TFilter.guid(
    'Brand',
    key: 'brandId',
    icon: HugeIcons.strokeRoundedBookmark01,
    onLoad: _loadBrands,
    itemText: (b) => (b as BrandEntity).name,
    itemSubText: (b) => (b as BrandEntity).country,
    itemValue: (b) => (b as BrandEntity).id,
    placeholder: 'Search brand...',
  ),
  TFilter.guid(
    'Category (Server)',
    key: 'categoryId',
    icon: HugeIcons.strokeRoundedFolder01,
    onLoad: _loadCategories,
    itemText: (c) => (c as CategoryEntity).name,
    itemSubText: (c) => (c as CategoryEntity).code,
    itemValue: (c) => (c as CategoryEntity).id,
    placeholder: 'Search category...',
  ),
  TFilter.boolean('Is Active', key: 'isActive', icon: HugeIcons.strokeRoundedToggleOn),
  TFilter.dateTime('Created At', key: 'createdAt', icon: HugeIcons.strokeRoundedCalendar01),
  TFilter.number('Price (\$)', key: 'price', icon: HugeIcons.strokeRoundedMoney01, placeholder: 'e.g. 99.99'),
  TFilter.enumFilter('Category', key: 'category', icon: HugeIcons.strokeRoundedTag01, values: ProductCategory.values),
  TFilter.enumFilter('Status', key: 'status', icon: HugeIcons.strokeRoundedCheckmarkCircle01, values: ProductStatus.values),
];

class ProductFilterForm extends TFormBase {
  final filterProp = TFieldProp<ProductFilter?>(null);

  @override
  String get formTitle => 'Advanced Product Filter';

  @override
  String get formActionName => 'Apply Filters';

  @override
  double get formWidth => 800;

  @override
  List<TFormField> get fields => [
    TFormField.filter<ProductFilter>(
      filterProp,
      'Filter Conditions',
      construct: (json) => ProductFilter.fromJson(json),
      filters: _createProductFilterDefs(),
    ).size(12),
  ];
}

class FilterFieldPage extends StatefulWidget {
  const FilterFieldPage({super.key});

  @override
  State<FilterFieldPage> createState() => _FilterFieldPageState();
}

class _FilterFieldPageState extends State<FilterFieldPage> {
  final ValueNotifier<ProductFilter?> _filterNotifier = ValueNotifier<ProductFilter?>(
    ProductFilter(
      name: const StringFilter(contains: 'Pro'),
      isActive: const BoolFilter(eq: true),
      price: const NumberFilter<double>(lte: 999.99),
    ),
  );

  ProductFilter? _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = _filterNotifier.value;
    _filterNotifier.addListener(() {
      setState(() {
        _currentFilter = _filterNotifier.value;
      });
    });
  }

  @override
  void dispose() {
    _filterNotifier.dispose();
    super.dispose();
  }

  void _applyPreset1() {
    _filterNotifier.value = ProductFilter(
      name: const StringFilter(contains: 'Wireless'),
      category: const EnumFilter<ProductCategory>(eq: ProductCategory.electronics),
      price: const NumberFilter<double>(gte: 50.0, lte: 250.0),
      isActive: const BoolFilter(eq: true),
    );
  }

  void _applyPreset2() {
    _filterNotifier.value = ProductFilter(
      status: const EnumFilter<ProductStatus>(inField: [ProductStatus.inStock, ProductStatus.lowStock]),
      createdAt: DateTimeFilter(gte: DateTime.now().subtract(const Duration(days: 30))),
    );
  }

  void _clearPreset() {
    _filterNotifier.value = const ProductFilter();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jsonEncoder = const JsonEncoder.withIndent('  ');
    final jsonString = _currentFilter != null ? jsonEncoder.convert(_currentFilter!.toJson()) : '{}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Title Row
          TAlignedRow(
            wrapperModeThreshold: 2,
            moveAllToSecondRow: true,
            left: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter & Select Options', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Explore dynamic filter rules and TSelect display modes (Text, Icon Only on Selected, Icon + Text in Drawer).',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
            right: [
              TButton(icon: Icons.auto_awesome, text: 'Preset: Electronics', type: TButtonType.tonal, onTap: _applyPreset1),
              TButton(icon: Icons.history, text: 'Preset: Recent Stock', type: TButtonType.tonal, onTap: _applyPreset2),
              TButton(icon: Icons.clear_all, text: 'Clear All', type: TButtonType.softText, onTap: _clearPreset),
              TButton(
                icon: Icons.open_in_new,
                text: 'Open in Form Modal',
                type: TButtonType.solid,
                onPressed: (_) async {
                  final form = ProductFilterForm();
                  form.filterProp.value = _currentFilter;
                  final result = await TFormService.show(context, form);
                  if (result != null) {
                    _filterNotifier.value = form.filterProp.value;
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          TGridRow(
            gapX: 20,
            gapY: 20,
            children: [
              // Left Column: The Interactive Filter Field
              TGridCol(
                sm: 12,
                lg: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: TFilterField<ProductFilter>(
                        label: 'Product Filter Rules',
                        helperText: 'Add filter conditions to filter products by name, brand, category, price, and status.',
                        valueNotifier: _filterNotifier,
                        construct: (json) => ProductFilter.fromJson(json),
                        filters: _createProductFilterDefs(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActiveFilterChips(context, _createProductFilterDefs()),
                  ],
                ),
              ),

              // Right Column: Real-Time JSON Output & Explanation
              TGridCol(
                sm: 12,
                lg: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Live Generated Filter JSON', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                              const TChip(text: 'JSON Output', type: TVariant.tonal),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(100)),
                            ),
                            child: SelectableText(jsonString, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Supported Filter Types', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          _buildTypeRow('StringFilter', 'eq, ne, startsWith, endsWith, contains, in, notIn, isNull'),
                          _buildTypeRow('NumberFilter<T>', 'eq, ne, gt, gte, lt, lte, in, notIn, isNull'),
                          _buildTypeRow('DateTimeFilter', 'eq, ne, gt, gte, lt, lte, in, notIn, isNull'),
                          _buildTypeRow('BoolFilter', 'eq, ne, isNull'),
                          _buildTypeRow('GuidFilter', 'eq, ne, in, notIn, isNull'),
                          _buildTypeRow('EnumFilter<T>', 'eq, ne, gt, gte, lt, lte, in, notIn, isNull'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips(BuildContext context, List<TFilterDef> defs) {
    final theme = Theme.of(context);
    final json = _currentFilter?.toJson() ?? {};
    final rules = _currentFilter != null ? TFilterRule.fromFilterJson(json, defs) : <TFilterRule>[];

    if (rules.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(100)),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list_off, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text('No active filter rules applied.', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('Applied Filters (${rules.length})', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              TButton(
                text: 'Clear All',
                size: TButtonSize.xxs,
                type: TButtonType.softText,
                color: theme.colorScheme.error,
                onTap: _clearPreset,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: rules.map((rule) {
              final def = defs.firstWhere((d) => d.key == rule.fieldKey, orElse: () => defs.first);
              final op = TFilterOperator.fromId(rule.operatorId);
              final displayVal = _formatRuleValueForChip(rule);
              final labelText = op.isNullOperator ? '${def.label} ${op.label}' : '${def.label} ${op.shortLabel ?? op.label} $displayVal';

              return TChip(
                size: TChipSize.sm,
                type: TVariant.tonal,
                icon: def.icon,
                text: labelText,
                trailing: TIcon.close(size: 11, padding: EdgeInsets.zero, onTap: () => _removeRule(rule, defs)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatRuleValueForChip(TFilterRule rule) {
    if (rule.value == null) return '';
    if (rule.fieldKey == 'brandId') {
      if (rule.value is List) {
        return (rule.value as List)
            .map((id) {
              final found = mockBrands.where((b) => b.id == id).firstOrNull;
              return found?.name ?? id;
            })
            .join(', ');
      }
      final found = mockBrands.where((b) => b.id == rule.value).firstOrNull;
      return found?.name ?? rule.value.toString();
    }
    if (rule.fieldKey == 'categoryId') {
      if (rule.value is List) {
        return (rule.value as List)
            .map((id) {
              final found = mockCategories.where((c) => c.id == id).firstOrNull;
              return found?.name ?? id;
            })
            .join(', ');
      }
      final found = mockCategories.where((c) => c.id == rule.value).firstOrNull;
      return found?.name ?? rule.value.toString();
    }
    if (rule.value is List) {
      return (rule.value as List).join(', ');
    }
    if (rule.value is DateTime) {
      final dt = rule.value as DateTime;
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    if (rule.value is Enum) {
      return (rule.value as Enum).name;
    }
    return rule.value.toString();
  }

  void _removeRule(TFilterRule ruleToRemove, List<TFilterDef> defs) {
    if (_currentFilter == null) return;
    final json = Map<String, dynamic>.from(_currentFilter!.toJson());
    final rules = TFilterRule.fromFilterJson(json, defs);
    rules.removeWhere((r) => r.fieldKey == ruleToRemove.fieldKey && r.operatorId == ruleToRemove.operatorId);
    final newJson = TFilterRule.rulesToJson(rules, defs);
    _filterNotifier.value = ProductFilter.fromJson(newJson);
  }

  Widget _buildTypeRow(String typeName, String operators) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(25), borderRadius: BorderRadius.circular(4)),
            child: Text(
              typeName,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(operators, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }
}
