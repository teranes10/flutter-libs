import 'package:flutter/material.dart';
import 'package:my_app/models/demo_product.dart';
import 'package:te_widgets/te_widgets.dart';

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
    return TPageWrapper(
      title: 'Row Expansion: Nested Sub-Items Table',
      description: 'Expand rows to view nested details lists using compact sub-item tables.',
      child: TTable<DemoProduct, String>(
        shrinkWrap: true,
        headers: demoProductHeaders(context),
        controller: _controller,
        details: TTableDetails(
          mode: TTableExpansionMode.bottom,
          builder: (ctx, item, index) {
            final data = item.data;
            // A nested sub-table of variants.
            final variants = [
              _ProductVariant(sku: 'V1', name: '${data.name} - Silver / 128GB', stock: 12, price: data.price),
              _ProductVariant(sku: 'V2', name: '${data.name} - Space Gray / 256GB', stock: 8, price: data.price * 1.15),
              _ProductVariant(sku: 'V3', name: '${data.name} - Space Gray / 512GB', stock: 3, price: data.price * 1.3),
            ];

            return TCard(
              title: 'Product Variants & Availability',
              icon: HugeIcons.strokeRoundedLayers01,
              margin: const EdgeInsets.fromLTRB(24, 8, 16, 8),
              child: TTable<_ProductVariant, String>(
                shrinkWrap: true,
                itemKey: (v) => v.sku,
                headers: [
                  TTableHeader<_ProductVariant, String>.map('SKU Code', (v) => v.sku),
                  TTableHeader<_ProductVariant, String>.map('Variant Description', (v) => v.name),
                  TTableHeader<_ProductVariant, String>.chip('Stock', (v) => '${v.stock} units', color: (v) => v.stockStatus.color(ctx)),
                  TTableHeader<_ProductVariant, String>.map('Price', (v) => '\$${v.price.toStringAsFixed(2)}'),
                ],
                items: variants,
              ),
            );
          },
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
  const _ProductVariant({required this.sku, required this.name, required this.stock, required this.price});

  DemoStockStatus get stockStatus => stock > 5 ? DemoStockStatus.inStock : DemoStockStatus.lowStock;
}
