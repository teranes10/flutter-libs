import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  late final TListController<Product, String> reorderableController;

  @override
  void initState() {
    super.initState();
    reorderableController = TListController<Product, String>(
      items: List.from(products),
      itemKey: (p) => p.id,
      reorderable: true,
      onReorder: (oldIndex, newIndex) {
        // The list controller handles the internal reordering of displayItems.
        // You can sync with your external data source here if needed.
      },
    );
  }

  @override
  void dispose() {
    reorderableController.dispose();
    super.dispose();
  }

  void generatePdfWithTable(BuildContext ctx) async {
    final colors = context.colors;
    final pdf = pw.Document();

    final table = await TTableHelper.from(ctx, productHeaders, products);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          buildBackground: (context) => pw.FullPage(ignoreMargins: true, child: pw.Container(color: colors.surface.toPdfColor())),
        ),
        build: (context) => [
          pw.Text('Table 1: List of Participants', style: pw.TextStyle(fontSize: 16, color: colors.onSurfaceVariant.toPdfColor())),
          pw.SizedBox(height: 15),
          table,
        ],
      ),
    );

    await pdf.download();
  }

  void generatePdfWithGrid(BuildContext ctx) async {
    final colors = context.colors;
    final pdf = pw.Document();

    final imageCache = await TPdfWidgetHelper.preCacheImages(ctx, productHeaders, products);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          buildBackground: (context) => pw.FullPage(ignoreMargins: true, child: pw.Container(color: colors.surface.toPdfColor())),
        ),
        build: (context) => [
          pw.Text('Grid Table: Product Details', style: pw.TextStyle(fontSize: 16, color: colors.onSurfaceVariant.toPdfColor())),
          pw.SizedBox(height: 15),
          ...products.map(
            (product) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [TPdfGridTableHelper.fromHeaders(ctx, productHeaders, product, imageCache: imageCache)],
            ),
          ),
        ],
      ),
    );

    await pdf.download();
  }

  void generatePdfAdaptive(BuildContext ctx) async {
    final colors = context.colors;
    final pdf = pw.Document();

    final List<TTableHeader<Product, int>> wideHeaders = [
      ...productHeaders,
      TTableHeader<Product, int>.map("Manufacturer", (x) => "Global Tech Industries Inc."),
      TTableHeader<Product, int>.map("Status", (x) => "Available"),
      TTableHeader<Product, int>.map("Category", (x) => "Electronics & Accessories"),
      TTableHeader<Product, int>.map("Warehouse Location", (x) => "Building A, Shelf 12, Bin 4"),
    ];

    final tableAsync = TPdfGridTableHelper.adaptive(ctx, productHeaders, products);
    final gridAsync = TPdfGridTableHelper.adaptive(ctx, wideHeaders, products);
    final table = await tableAsync;
    final grid = await gridAsync;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          buildBackground: (context) => pw.FullPage(ignoreMargins: true, child: pw.Container(color: colors.surface.toPdfColor())),
        ),
        build: (context) => [
          pw.Text('Adaptive Table (Few Columns -> Table)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          table,
          pw.SizedBox(height: 30),
          pw.Text('Adaptive Table (Many Columns -> Grid)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          grid,
        ],
      ),
    );

    await pdf.download();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 25,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 12,
              children: [
                TButton(text: 'Print Table', onPressed: (_) => generatePdfWithTable(context)),
                TButton(text: 'Print Grid', onPressed: (_) => generatePdfWithGrid(context)),
                TButton(text: 'Print Adaptive', onPressed: (_) => generatePdfAdaptive(context)),
              ],
            ),
            TTable<Product, int>(shrinkWrap: true, headers: productHeaders, items: products),
            Text('Dense Table', style: context.textTheme.titleMedium),
            TTable<Product, int>(shrinkWrap: true, dense: true, headers: productHeaders, items: products),
            TTable<Product, int>(
              shrinkWrap: true,
              headers: [
                TTableHeader.map("Name", (x) => x.name),
                TTableHeader.map("Price", (x) => x.price),
                TTableHeader.chip("Stock", (x) => x.stock, color: (_) => context.theme.info),
                TTableHeader.actions(
                  (x) => [
                    TButtonGroupItem(tooltip: 'View', icon: Icons.remove_red_eye, color: context.theme.success, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Edit', icon: Icons.edit, color: context.theme.info, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Restore', icon: Icons.unarchive, color: context.theme.info, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Archive', icon: Icons.archive, color: context.theme.warning, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Delete', icon: Icons.delete_forever, color: context.theme.danger, onPressed: (_) => {}),
                  ],
                  count: 5,
                ),
              ],
              items: products,
            ),
            Text('Chips in Tables (Icons, Text & TVariant Variants)', style: context.textTheme.titleMedium),
            TTable<Product, int>(shrinkWrap: true, headers: chipsTableHeaders, items: products),
            Text('Reorderable Table', style: context.textTheme.titleMedium),
            TTable<Product, String>(
              shrinkWrap: true,
              headers: [
                TTableHeader.map("Name", (x) => x.name),
                TTableHeader.map("Price", (x) => x.price),
                TTableHeader.chip("Stock", (x) => x.stock, color: (x) => x.stock < 100 ? context.theme.warning : context.theme.success),
              ],
              controller: reorderableController,
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  User({required this.id, required this.name, required this.email, required this.role, required this.createdAt});
}

class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? category;
  final List<String> tags;
  final List<String> features;
  final List<String> badges;

  Product(
    this.id,
    this.name,
    this.price,
    this.stock, {
    this.imageUrl,
    this.category,
    this.tags = const [],
    this.features = const [],
    this.badges = const [],
  });
}

final List<TTableHeader<Product, int>> chipsTableHeaders = [
  TTableHeader.tile(
    "Product",
    (x) => x.name,
    subtitle: (x) => x.category,
    icon: (x) => Icons.inventory_2_outlined,
    iconColor: (_) => AppColors.primary,
    iconBackgroundColor: (_) => AppColors.primary.withAlpha(25),
  ),
  // 1. Multiple Chips from Strings via TChip.fromStrings (merges common header color/size)
  TTableHeader.chips(
    "Tags (Wrap)",
    (x) => TChip.fromStrings(x.tags),
    color: (x, tag) => tag == 'Best Seller' ? AppColors.primary : null,
    spacing: 4.0,
  ),
  // 2. Declarative TChip Items (Each chip defines its own icon/variant/color, or falls back to common config)
  TTableHeader.chips(
    "Features (TChip)",
    (x) => [
      if (x.features.contains('Pro'))
        const TChip.solid(text: 'Pro', icon: Icons.star_rounded, color: AppColors.warning),
      if (x.features.contains('Verified'))
        const TChip.tonal(text: 'Verified', icon: Icons.verified_rounded, color: AppColors.info),
      if (x.features.contains('Fast Ship'))
        const TChip.outline(text: 'Fast Ship', icon: Icons.local_shipping_rounded),
    ],
    spacing: 4.0,
  ),
  // 3. Chips with Direct TChip Variants (solid, tonal, outline, softOutline)
  TTableHeader.chips(
    "Badges",
    (x) => [
      for (final badge in x.badges)
        if (badge == 'Admin Only')
          const TChip.solid(text: 'Admin Only', color: AppColors.danger)
        else if (badge == 'Popular')
          const TChip.tonal(text: 'Popular', color: AppColors.primary)
        else if (badge == 'New')
          const TChip.softOutline(text: 'New', color: AppColors.success)
        else
          TChip(text: badge), // inherits common fallback config
    ],
    type: TVariant.outline,
    spacing: 4.0,
  ),
  // 4. Single Chip with Icon and TVariant
  TTableHeader.chip(
    "Status",
    (x) => x.stock > 0 ? 'In Stock' : 'Out of Stock',
    icon: (x) => x.stock > 0 ? Icons.check_circle_rounded : Icons.cancel_rounded,
    typeBuilder: (x) => x.stock > 0 ? TVariant.tonal : TVariant.outline,
    color: (x) => x.stock > 0 ? AppColors.success : AppColors.danger,
  ),
];

final List<TTableHeader<Product, int>> productHeaders = [
  TTableHeader.tile(
    "Product",
    (x) => x.name,
    subtitle: (x) => x.category,
    icon: (x) => Icons.inventory_2_outlined,
    iconColor: (_) => AppColors.primary,
    iconBackgroundColor: (_) => AppColors.primary.withAlpha(25),
  ),
  TTableHeader.progress("Target Goal", (x) => x.stock / 200, valueText: (x) => '${x.stock}/200', colorBuilder: (value, percentage) => percentage < 30 ? AppColors.danger : percentage < 70 ? AppColors.warning : AppColors.success),
  TTableHeader.chips(
    "Tags",
    (x) => TChip.fromStrings(x.tags),
    spacing: 4.0,
  ),
  // Custom Row with STRICT widthEstimator
  TTableHeader.row(
    "Custom Badges",
    (x) => [
      TChip.tonal(text: x.category ?? 'Item', size: TChipSize.sm),
      TChip.solid(
        text: x.stock > 100 ? 'High Stock' : 'Limited',
        color: x.stock > 100 ? AppColors.success : AppColors.warning,
        size: TChipSize.sm,
      ),
    ],
    widthEstimator: (x) =>
        TTableTheme.measureTextWidth(x.category ?? 'Item') +
        24.0 +
        TTableTheme.measureTextWidth(x.stock > 100 ? 'High Stock' : 'Limited') +
        24.0 +
        8.0,
  ),
  TTableHeader.keyValues("Details", (x) => [TKeyValue('ID', value: '#${x.id}'), TKeyValue('Price', value: '\$${x.price}')]),
];

final List<Product> products = [
  Product(
    '1',
    'Premium Smartphone',
    999.99,
    50,
    category: 'Electronics',
    imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=100&h=100&fit=crop',
    tags: ['Flagship', '5G', 'Best Seller'],
    features: ['Pro', 'Verified', 'Fast Ship'],
    badges: ['Popular', 'Admin Only'],
  ),
  Product(
    '2',
    'Wireless Headphones',
    199.99,
    150,
    category: 'Audio',
    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=100&h=100&fit=crop',
    tags: ['Wireless', 'Noise Cancelling'],
    features: ['Verified', 'Fast Ship'],
    badges: ['New', 'Popular'],
  ),
  Product(
    '3',
    'Smart Watch',
    299.99,
    75,
    category: 'Wearables',
    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=100&h=100&fit=crop',
    tags: ['Fitness', 'Waterproof'],
    features: ['Pro', 'Fast Ship'],
    badges: ['New'],
  ),
];
