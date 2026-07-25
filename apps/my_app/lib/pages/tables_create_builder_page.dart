import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'tables_bottom_page.dart';

class TablesCreateBuilderPage extends StatefulWidget {
  const TablesCreateBuilderPage({super.key});

  @override
  State<TablesCreateBuilderPage> createState() => _TablesCreateBuilderPageState();
}

class _TablesCreateBuilderPageState extends State<TablesCreateBuilderPage> {
  late final TListController<DemoProduct, String> _controller;
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TListController<DemoProduct, String>(
      items: List.from(demoProducts),
      itemKey: (p) => p.id,
      expansionMode: TExpansionMode.single,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _clearInputs() {
    _nameController.clear();
    _categoryController.clear();
    _priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final headers = [
      TTableHeader<DemoProduct, String>.image("Image", (x) => x.imageUrl, width: 60),
      TTableHeader<DemoProduct, String>.map("Name", (x) => x.name),
      TTableHeader<DemoProduct, String>.map("Category", (x) => x.category),
      TTableHeader<DemoProduct, String>.rating("Rating", (x) => x.rating),
      TTableHeader<DemoProduct, String>.map("Price", (x) => '\$${x.price.toStringAsFixed(2)}'),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        key: const ValueKey('tables_create_builder_container'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Row Expansion: Create Builder',
                      style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Demo of createBuilder to configure inline/modal creation forms.',
                      style: context.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
                TButton(
                  icon: Icons.add,
                  text: 'Add Product',
                  onPressed: (_) {
                    _clearInputs();
                    _controller.beginCreateItem();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 0,
                color: colors.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colors.outlineVariant.o(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TTable<DemoProduct, String>(
                    headers: headers,
                    controller: _controller,
                    details: TTableDetails(
                      mode: TTableExpansionMode.bottom,
                      itemTitle: (item) => item.name,
                      builder: _buildProductDetails,
                      createBuilder: _buildProductForm,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext ctx, TListItem<DemoProduct, String> item, int index) {
    final data = item.data;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.name, style: ctx.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('SKU: ${data.sku}'),
          const SizedBox(height: 8),
          Text('Manufacturer: ${data.manufacturer}'),
          const SizedBox(height: 8),
          Text('Description: ${data.description}'),
        ],
      ),
    );
  }

  Widget _buildProductForm(BuildContext context, TListItem<DemoProduct, String>? item, int? index) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Product Form', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => TTableScope.of(context).close(context), child: const Text('Cancel')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(_priceController.text) ?? 0.0;
                  final newProduct = DemoProduct(
                    id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                    name: _nameController.text.isEmpty ? 'New Product' : _nameController.text,
                    category: _categoryController.text.isEmpty ? 'General' : _categoryController.text,
                    rating: 5.0,
                    stock: 10,
                    price: price,
                    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=100&h=100&fit=crop',
                    sku: 'NEW-SKU',
                    manufacturer: 'Unknown',
                    warranty: 'None',
                    weight: '0g',
                    description: 'Created inline via createBuilder.',
                  );
                  _controller.addItem(newProduct);
                  TTableScope.of(context).close(context);
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
