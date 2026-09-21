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
      aliases: ['code', 'item_sku', 'product_code', 'id'],
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

  void _loadJsonPreset() {
    const jsonContent = '''[
  {
    "sku": "JSON-01",
    "name": "Smart Fitness Watch Ultra",
    "category": "Wearables",
    "price": 249.99,
    "stock": 35,
    "in_stock": true,
    "featured": true
  },
  {
    "sku": "JSON-02",
    "name": "Bluetooth Tracker Tag",
    "category": "Accessories",
    "price": 29.00,
    "stock": 140,
    "in_stock": true,
    "featured": false
  },
  {
    "sku": "JSON-03",
    "name": "MagSafe Magnetic Stand",
    "category": "Accessories",
    "price": 39.95,
    "stock": 60,
    "in_stock": true,
    "featured": true
  }
]''';

    final mappedRows = TCsvParser.parseToMaps(jsonContent, columns: _columns);

    setState(() {
      _initialData = mappedRows;
      _editorKey = UniqueKey();
      _lastUploadedData = null;
    });

    TToastService.success(context, 'Loaded 3 records from JSON payload with auto-type coercion.');
  }

  void _loadSemicolonPreset() {
    const semicolonContent = '''sku;name;category;price;stock;in_stock;featured
SEM-101;Espresso Machine Pro;Appliances;599.00;8;true;true
SEM-102;Coffee Grinder Burr;Appliances;89.50;25;true;false
SEM-103;Double Walled Glass Set;Kitchen;24.99;80;true;false''';

    final mappedRows = TCsvParser.parseToMaps(semicolonContent, columns: _columns);

    setState(() {
      _initialData = mappedRows;
      _editorKey = UniqueKey();
      _lastUploadedData = null;
    });

    TToastService.info(context, 'Loaded Semicolon-delimited (;) dataset with auto-delimiter detection.');
  }

  void _loadTsvPreset() {
    const tsvContent =
        "sku\tname\tcategory\tprice\tstock\tin_stock\tfeatured\n"
        "TSV-501\tStudio Microphone USB\tAudio\t149.00\t18\ttrue\ttrue\n"
        "TSV-502\tBoom Arm Stand\tAudio\t45.00\t40\ttrue\tfalse\n"
        "TSV-503\tPop Filter Shield\tAudio\t15.99\t100\ttrue\tfalse";

    final mappedRows = TCsvParser.parseToMaps(tsvContent, columns: _columns);

    setState(() {
      _initialData = mappedRows;
      _editorKey = UniqueKey();
      _lastUploadedData = null;
    });

    TToastService.info(context, 'Loaded TSV (Tab-delimited) dataset with auto-delimiter detection.');
  }

  void _loadPipePreset() {
    const pipeContent = '''sku|name|category|price|stock|in_stock|featured
PIPE-901|Portable SSD 2TB|Storage|159.99|50|true|true
PIPE-902|NVMe M.2 Enclosure|Storage|32.50|75|true|false
PIPE-903|High-Speed SD Card 256GB|Storage|28.00|120|true|false''';

    final mappedRows = TCsvParser.parseToMaps(pipeContent, columns: _columns);

    setState(() {
      _initialData = mappedRows;
      _editorKey = UniqueKey();
      _lastUploadedData = null;
    });

    TToastService.info(context, 'Loaded Pipe-delimited (|) dataset with auto-delimiter detection.');
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

    final autoMapping = TCsvHeaderMapping.autoMap(expectedColumns: _columns, csvHeaders: headers);

    final mappedRows = dataRows.map((rawRow) {
      return autoMapping.mapRow(expectedColumns: _columns, csvHeaders: headers, csvRow: rawRow);
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
            title: 'Generic Data & CSV Editor Interactive Showcase',
            subtitle: 'Try CSV, TSV, Semicolon, Pipe, JSON datasets, mismatched headers, validation checking, or upload your own file.',
            icon: Icons.auto_awesome_rounded,
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(
                  text: 'Standard CSV (5 Items)',
                  icon: Icons.check_circle_outline,
                  type: TButtonType.tonal,
                  size: TButtonSize.xs,
                  onPressed: (_) => _loadMatchingPreset(),
                ),
                TButton(
                  text: 'JSON Dataset (.json)',
                  icon: Icons.data_object_rounded,
                  type: TButtonType.tonal,
                  color: colors.primary,
                  size: TButtonSize.xs,
                  onPressed: (_) => _loadJsonPreset(),
                ),
                TButton(
                  text: 'TSV Dataset (Tab \\t)',
                  icon: Icons.table_rows_rounded,
                  type: TButtonType.tonal,
                  size: TButtonSize.xs,
                  onPressed: (_) => _loadTsvPreset(),
                ),
                TButton(
                  text: 'Semicolon Dataset (;)',
                  icon: Icons.grid_on_rounded,
                  type: TButtonType.tonal,
                  size: TButtonSize.xs,
                  onPressed: (_) => _loadSemicolonPreset(),
                ),
                TButton(
                  text: 'Pipe Dataset (|)',
                  icon: Icons.view_column_outlined,
                  type: TButtonType.tonal,
                  size: TButtonSize.xs,
                  onPressed: (_) => _loadPipePreset(),
                ),
                TButton(
                  text: 'Mismatched Headers',
                  icon: Icons.alt_route_rounded,
                  type: TButtonType.tonal,
                  color: AppColors.warning,
                  size: TButtonSize.xs,
                  onPressed: (_) => _loadMismatchedHeadersPreset(),
                ),
                TButton(
                  text: 'Validation Errors',
                  icon: Icons.error_outline,
                  type: TButtonType.tonal,
                  color: AppColors.danger,
                  size: TButtonSize.xs,
                  onPressed: (_) => _loadErrorsPreset(),
                ),
                TButton(
                  text: 'Reset / Empty Dropzone',
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
            title: 'Product Catalog Import & Editor',
            subtitle: 'Upload CSV, TSV, Semicolon, Pipe, or JSON. Inline fields support Text, Number, and Interactive Switches.',
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
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: colors.onSurface),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
