import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Sample demonstration page for [TCsvEditor].
class CsvEditorPage extends StatefulWidget {
  const CsvEditorPage({super.key});

  @override
  State<CsvEditorPage> createState() => _CsvEditorPageState();
}

class _CsvEditorPageState extends State<CsvEditorPage> {
  Key _editorKey = UniqueKey();
  List<Map<String, dynamic>>? _initialData;
  List<Map<String, dynamic>>? _lastUploadedData;

  // Schema definitions
  final List<TCsvColumn> _columns = [
    const TCsvColumn.text(
      key: 'sku',
      header: 'SKU Code',
      isRequired: true,
      aliases: ['code', 'item_sku', 'product_code'],
      minWidth: 110,
    ),
    const TCsvColumn.text(
      key: 'name',
      header: 'Product Name',
      isRequired: true,
      aliases: ['item_title', 'product_name', 'title', 'product'],
      minWidth: 160,
    ),
    const TCsvColumn.text(
      key: 'category',
      header: 'Category',
      defaultValue: 'General',
      aliases: ['department', 'group', 'cat'],
      minWidth: 120,
    ),
    const TCsvColumn.number(
      key: 'price',
      header: 'Price (\$)',
      isRequired: true,
      aliases: ['cost', 'unit_price', 'rate', 'price_usd'],
      minWidth: 110,
    ),
    const TCsvColumn.integer(
      key: 'stock',
      header: 'Stock Qty',
      defaultValue: 0,
      aliases: ['qty', 'quantity', 'qty_available', 'count'],
      minWidth: 100,
    ),
    const TCsvColumn.boolean(
      key: 'in_stock',
      header: 'In Stock',
      defaultValue: true,
      aliases: ['available', 'is_available', 'active_flag', 'status'],
      minWidth: 90,
    ),
    const TCsvColumn.boolean(
      key: 'featured',
      header: 'Featured',
      defaultValue: false,
      aliases: ['is_featured', 'highlight', 'promo'],
      minWidth: 90,
    ),
  ];

  // Presets
  void _loadMatchingPreset() {
    setState(() {
      _initialData = [
        {
          'sku': 'SKU-001',
          'name': 'Ergonomic Mechanical Keyboard',
          'category': 'Electronics',
          'price': 129.99,
          'stock': 45,
          'in_stock': true,
          'featured': true,
        },
        {
          'sku': 'SKU-002',
          'name': 'Ultra-wide Curved Monitor 34"',
          'category': 'Electronics',
          'price': 499.00,
          'stock': 12,
          'in_stock': true,
          'featured': true,
        },
        {
          'sku': 'SKU-003',
          'name': 'Wireless Charging Mousepad',
          'category': 'Accessories',
          'price': 34.50,
          'stock': 0,
          'in_stock': false,
          'featured': false,
        },
        {
          'sku': 'SKU-004',
          'name': 'Noise-Cancelling Headphones',
          'category': 'Audio',
          'price': 199.95,
          'stock': 28,
          'in_stock': true,
          'featured': false,
        },
        {
          'sku': 'SKU-005',
          'name': 'USB-C Multi-Port Hub (8-in-1)',
          'category': 'Accessories',
          'price': 49.99,
          'stock': 110,
          'in_stock': true,
          'featured': false,
        },
      ];
      _editorKey = UniqueKey();
      _lastUploadedData = null;
    });

    TToastService.info(context, 'Loaded 5 sample products with matching schema.');
  }

  void _loadMismatchedHeadersPreset() {
    // CSV with different headers: item_sku, item_title, department, cost, qty_available, active_flag
    const csvContent = '''item_sku,item_title,department,cost,qty_available,active_flag,promo
LAP-991,MacBook Pro M3 Max 16",Computers,\$3499.00,8,true,true
DESK-104,Standing Motorized Desk,Furniture,\$650.00,15,true,false
CHAIR-22,Ergonomic Mesh Chair,Furniture,\$289.50,30,true,true
CABLE-05,Braided Thunderbolt 4 Cable,Accessories,\$29.99,150,true,false''';

    final parsed = TCsvParser.parse(csvContent);
    final headers = parsed.first;
    final dataRows = parsed.skip(1).toList();

    final autoMapping = TCsvHeaderMapping.autoMap(
      expectedColumns: _columns,
      csvHeaders: headers,
    );

    final mappedRows = dataRows.map((rawRow) {
      return autoMapping.mapRow(
        expectedColumns: _columns,
        csvHeaders: headers,
        csvRow: rawRow,
      );
    }).toList();

    setState(() {
      _initialData = mappedRows;
      _editorKey = UniqueKey();
      _lastUploadedData = null;
    });

    TToastService.warning(
      context,
      'Loaded CSV with mismatched header names (item_sku -> SKU Code, cost -> Price, active_flag -> In Stock).',
    );
  }

  void _loadErrorsPreset() {
    setState(() {
      _initialData = [
        {
          'sku': '', // Missing required
          'name': 'Wireless Speaker',
          'category': 'Audio',
          'price': 'invalid_num', // Invalid number
          'stock': 10,
          'in_stock': true,
          'featured': false,
        },
        {
          'sku': 'SKU-007',
          'name': '', // Missing required name
          'category': 'General',
          'price': 15.00,
          'stock': 20,
          'in_stock': true,
          'featured': false,
        },
        {
          'sku': 'SKU-008',
          'name': 'Valid Tablet Stand',
          'category': 'Accessories',
          'price': 22.50,
          'stock': 65,
          'in_stock': true,
          'featured': true,
        },
      ];
      _editorKey = UniqueKey();
      _lastUploadedData = null;
    });

    TToastService.warning(context, 'Loaded data with validation errors to test error indicators and filter tabs.');
  }

  void _resetEmpty() {
    setState(() {
      _initialData = [];
      _editorKey = UniqueKey();
      _lastUploadedData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick Preset Toolbar
          TCard(
            title: 'TCsvEditor Interactive Showcase',
            subtitle: 'Try preloaded datasets, mismatched headers, validation checking, or upload your own CSV.',
            icon: Icons.auto_awesome_rounded,
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(
                  text: 'Matching Preset (5 Products)',
                  icon: Icons.check_circle_outline,
                  type: TButtonType.tonal,
                  size: TButtonSize.xs,
                  onPressed: (_) => _loadMatchingPreset(),
                ),
                TButton(
                  text: 'Mismatched Headers Preset',
                  icon: Icons.alt_route_rounded,
                  type: TButtonType.tonal,
                  color: AppColors.warning,
                  size: TButtonSize.xs,
                  onPressed: (_) => _loadMismatchedHeadersPreset(),
                ),
                TButton(
                  text: 'Validation Errors Preset',
                  icon: Icons.error_outline,
                  type: TButtonType.tonal,
                  color: AppColors.danger,
                  size: TButtonSize.xs,
                  onPressed: (_) => _loadErrorsPreset(),
                ),
                TButton(
                  text: 'Reset to Empty Dropzone',
                  icon: Icons.refresh_rounded,
                  type: TButtonType.softText,
                  size: TButtonSize.xs,
                  onPressed: (_) => _resetEmpty(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Main TCsvEditor Component
          TCsvEditor(
            key: _editorKey,
            title: 'Product Catalog Import',
            subtitle: 'Upload CSV or edit inline. Fields support Text, Number, and Interactive True/False Switches.',
            columns: _columns,
            initialData: _initialData,
            saveButtonText: 'Upload & Process Records',
            onSave: (data) async {
              // Simulate network call
              await Future.delayed(const Duration(milliseconds: 600));
              setState(() {
                _lastUploadedData = data;
              });
            },
            onDataChanged: (data) {
              debugPrint('Data changed: ${data.length} records');
            },
          ),

          // Output Results Viewer (when saved/uploaded)
          if (_lastUploadedData != null) ...[
            const SizedBox(height: 24),
            TCard(
              title: 'Uploaded & Processed JSON Output (${_lastUploadedData!.length} records)',
              subtitle: 'Data successfully validated, type-coerced, and submitted.',
              icon: Icons.data_object_rounded,
              padding: const EdgeInsets.all(16),
              trailing: TButton(
                text: 'Dismiss',
                type: TButtonType.softText,
                size: TButtonSize.xs,
                onPressed: (_) {
                  setState(() {
                    _lastUploadedData = null;
                  });
                },
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(_lastUploadedData),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
