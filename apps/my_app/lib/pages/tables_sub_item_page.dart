import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'tables_bottom_page.dart';

class TablesSubItemPage extends StatefulWidget {
  const TablesSubItemPage({super.key});

  @override
  State<TablesSubItemPage> createState() => _TablesSubItemPageState();
}

class _TablesSubItemPageState extends State<TablesSubItemPage> {
  late final TListController<DemoProduct, String> _controller;

  @override
  void initState() {
    super.initState();
    _controller = TListController<DemoProduct, String>(items: demoProducts, itemKey: (p) => p.id, expansionMode: TExpansionMode.single);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final headers = [
      TTableHeader<DemoProduct, String>.image("Image", (x) => x.imageUrl, width: 60),
      TTableHeader<DemoProduct, String>.map("Name", (x) => x.name),
      TTableHeader<DemoProduct, String>.map("Category", (x) => x.category),
      TTableHeader<DemoProduct, String>.rating("Rating", (x) => x.rating),
      TTableHeader<DemoProduct, String>.chip(
        "StockStatus",
        (x) => x.stock > 10 ? 'In Stock (${x.stock})' : 'Low Stock (${x.stock})',
        color: (x) => x.stock > 10 ? context.theme.success : context.theme.danger,
      ),
      TTableHeader<DemoProduct, String>.map("Price", (x) => '\$${x.price.toStringAsFixed(2)}'),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          key: const ValueKey('tables_sub_item_container'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Row Expansion: Nested Sub-Items Table',
                style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Expand rows to view nested details lists using compact sub-item tables.',
                style: context.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              TTable<DemoProduct, String>(
                shrinkWrap: true,
                headers: headers,
                controller: _controller,
                details: TTableDetails(
                  mode: TTableExpansionMode.bottom,
                  builder: (ctx, item, index) {
                    final data = item.data;
                    // Render a nested sub-table showing variants
                    final mockVariants = [
                      _ProductVariant('V1', '${data.name} - Silver / 128GB', 12, data.price),
                      _ProductVariant('V2', '${data.name} - Space Gray / 256GB', 8, data.price * 1.15),
                      _ProductVariant('V3', '${data.name} - Space Gray / 512GB', 3, data.price * 1.3),
                    ];

                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 24.0, right: 16.0),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Variants & Availability',
                            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
                          ),
                          const SizedBox(height: 12),
                          TTable<_ProductVariant, String>(
                            shrinkWrap: true,
                            itemKey: (item) => item.name,
                            headers: [
                              TTableHeader('SKU Code', map: (v) => v.sku),
                              TTableHeader('Variant Description', map: (v) => v.name),
                              TTableHeader.chip(
                                'Stock',
                                (v) => '${v.stock} units',
                                color: (v) => v.stock > 5 ? context.theme.success : context.theme.danger,
                              ),
                              TTableHeader('Price', map: (v) => '\$${v.price.toStringAsFixed(2)}'),
                            ],
                            items: mockVariants,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductVariant {
  final String sku;
  final String name;
  final int stock;
  final num price;
  const _ProductVariant(this.sku, this.name, this.stock, this.price);
}
