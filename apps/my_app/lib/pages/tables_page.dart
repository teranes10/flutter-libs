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
              children: [
                TPdfGridTableHelper.fromHeaders(ctx, productHeaders, product, imageCache: imageCache),
                pw.SizedBox(height: 15),
                pw.Divider(thickness: 0.2),
                pw.SizedBox(height: 15),
              ],
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

    final table = await TPdfGridTableHelper.adaptive(ctx, productHeaders, products);
    final grid = await TPdfGridTableHelper.adaptive(ctx, wideHeaders, products);

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
                TTableHeader.chip("Stock", (x) => x.stock, color: (_) => AppColors.info),
                TTableHeader.actions(
                  (x) => [
                    TButtonGroupItem(tooltip: 'View', icon: Icons.remove_red_eye, color: AppColors.success, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Edit', icon: Icons.edit, color: AppColors.info, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Restore', icon: Icons.unarchive, color: AppColors.info, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Archive', icon: Icons.archive, color: AppColors.warning, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Delete', icon: Icons.delete_forever, color: AppColors.danger, onPressed: (_) => {}),
                  ],
                  count: 5,
                ),
              ],
              items: products,
            ),
            Text('Reorderable Table', style: context.textTheme.titleMedium),
            TTable<Product, String>(
              shrinkWrap: true,
              headers: [
                TTableHeader.map("Name", (x) => x.name),
                TTableHeader.map("Price", (x) => x.price),
                TTableHeader.chip("Stock", (x) => x.stock, color: (x) => x.stock < 100 ? AppColors.warning : AppColors.success),
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

  Product(this.id, this.name, this.price, this.stock, {this.imageUrl, this.category});
}

final List<TTableHeader<Product, int>> productHeaders = [
  TTableHeader.image("Image", (x) => x.imageUrl, width: 40),
  TTableHeader.map("Name", (x) => x.name),
  TTableHeader.chip("Stock", (x) => x.stock, color: (x) => x.stock < 100 ? AppColors.warning : AppColors.success),
  TTableHeader.map("Price", (x) => x.price),
];

final List<Product> products = [
  Product(
    '1',
    'Premium Smartphone',
    999.99,
    50,
    category: 'Electronics',
    imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=100&h=100&fit=crop',
  ),
  Product(
    '2',
    'Wireless Headphones',
    199.99,
    150,
    category: 'Audio',
    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=100&h=100&fit=crop',
  ),
  Product(
    '3',
    'Smart Watch',
    299.99,
    75,
    category: 'Wearables',
    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=100&h=100&fit=crop',
  ),
];
