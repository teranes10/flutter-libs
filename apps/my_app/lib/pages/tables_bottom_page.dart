import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TablesBottomPage extends StatefulWidget {
  const TablesBottomPage({super.key});

  @override
  State<TablesBottomPage> createState() => _TablesBottomPageState();
}

class _TablesBottomPageState extends State<TablesBottomPage> {
  late final TListController<DemoProduct, String> _controller;

  @override
  void initState() {
    super.initState();
    _controller = TListController<DemoProduct, String>(
      items: demoProducts,
      itemKey: (p) => p.id,
      expansionMode: TExpansionMode.single,
    );
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
          key: const ValueKey('tables_bottom_container'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Row Expansion: Bottom Mode',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Expands inline directly beneath the clicked row. Best suited for quick inline details, key-value reviews, and summary sub-tables.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: colors.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colors.outlineVariant.o(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TTable<DemoProduct, String>(
                    shrinkWrap: true,
                    headers: headers,
                    controller: _controller,
                    details: TTableDetails(
                      mode: TTableExpansionMode.bottom,
                      builder: (ctx, item, index) {
                        final product = item.data;
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest.o(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.outlineVariant.o(0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product Technical Specs & Summary',
                                  style: context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TKeyValueSection(
                                  values: [
                                    TKeyValue.text('SKU Code', product.sku),
                                    TKeyValue.text('Manufacturer', product.manufacturer),
                                    TKeyValue.text('Warranty Period', product.warranty),
                                    TKeyValue.text('Weight', product.weight),
                                    TKeyValue.text('Description', product.description),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DemoProduct {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int stock;
  final double price;
  final String imageUrl;
  final String sku;
  final String manufacturer;
  final String warranty;
  final String weight;
  final String description;

  DemoProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.stock,
    required this.price,
    required this.imageUrl,
    required this.sku,
    required this.manufacturer,
    required this.warranty,
    required this.weight,
    required this.description,
  });
}

final List<DemoProduct> demoProducts = [
  DemoProduct(
    id: 'p1',
    name: 'Quantum X Pro Smartphone',
    category: 'Mobile Devices',
    rating: 4.8,
    stock: 45,
    price: 1199.00,
    imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=100&h=100&fit=crop',
    sku: 'QX-PRO-128-GRY',
    manufacturer: 'Quantum Technologies Inc.',
    warranty: '2 Years International',
    weight: '185g',
    description: 'A revolutionary smartphone featuring next-generation quantum computing chipsets and a high-refresh crystal screen.',
  ),
  DemoProduct(
    id: 'p2',
    name: 'AcousticWave ANC Headphones',
    category: 'Audio Equipment',
    rating: 4.5,
    stock: 5,
    price: 349.99,
    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=100&h=100&fit=crop',
    sku: 'AW-ANC-BLK',
    manufacturer: 'AcousticWave Labs',
    warranty: '1 Year Manufacturer',
    weight: '250g',
    description: 'Industry-leading hybrid active noise cancelling over-ear headphones with custom spatial acoustics.',
  ),
  DemoProduct(
    id: 'p3',
    name: 'Helios Smartwatch Series 7',
    category: 'Wearable Tech',
    rating: 4.6,
    stock: 82,
    price: 429.00,
    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=100&h=100&fit=crop',
    sku: 'HL-SW7-SILV',
    manufacturer: 'Helios Devices',
    warranty: '1 Year Limited',
    weight: '45g',
    description: 'Premium titanium smartwatch with integrated continuous health monitoring, GPS tracking, and cellular connectivity.',
  ),
];
