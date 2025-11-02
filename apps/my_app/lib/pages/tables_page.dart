import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  void generatePdfWithTable(BuildContext ctx) async {
    final colors = context.colors;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: colors.surface.toPdfColor()),
          ),
        ),
        build: (context) => [
          pw.Text('Table 1: List of Participants', style: pw.TextStyle(fontSize: 16, color: colors.onSurfaceVariant.toPdfColor())),
          pw.SizedBox(height: 15),
          TTableHelper.from(ctx, productHeaders, products),
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
          children: [
            TButton(text: 'Print', onPressed: (_) => generatePdfWithTable(context)),
            TTable<Product, int>(
              theme: TTableTheme(shrinkWrap: true, infiniteScroll: false, headerSticky: false),
              headers: productHeaders,
              items: products,
            ),
            TTable<Product, int>(
              theme: TTableTheme(shrinkWrap: true, infiniteScroll: false, headerSticky: false),
              headers: [
                TTableHeader.map("Name", (x) => x.name),
                TTableHeader.map("Price", (x) => x.price),
                TTableHeader.chip("Stock", (x) => x.stock, color: AppColors.info),
                TTableHeader.actions(
                  (x) => [
                    TButtonGroupItem(tooltip: 'View', icon: Icons.remove_red_eye, color: AppColors.success, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Edit', icon: Icons.edit, color: AppColors.info, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Restore', icon: Icons.unarchive, color: AppColors.info, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Archive', icon: Icons.archive, color: AppColors.warning, onPressed: (_) => {}),
                    TButtonGroupItem(tooltip: 'Delete', icon: Icons.delete_forever, color: AppColors.danger, onPressed: (_) => {}),
                  ],
                  maxWidth: 45 * 5,
                ),
              ],
              items: products,
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

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final int stock;

  Product(this.id, this.name, this.price, this.stock);
}

final List<TTableHeader<Product>> productHeaders = [
  TTableHeader.map("Name", (x) => x.name),
  TTableHeader.map("Price", (x) => x.price),
  TTableHeader.map("Stock", (x) => x.stock),
];

final List<Product> products = List.generate(
  3,
  (index) => Product(
    'ID-${index + 1}',
    'Product Description ${index + 1}',
    10.0 + (index * 0.5),
    100 - index,
  ),
);
