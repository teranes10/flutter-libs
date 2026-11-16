import 'package:flutter/material.dart';
import 'package:my_app/models/demo_product.dart';
import 'package:te_widgets/te_widgets.dart';

class TablesCreateBuilderPage extends StatefulWidget {
  const TablesCreateBuilderPage({super.key});

  @override
  State<TablesCreateBuilderPage> createState() => _TablesCreateBuilderPageState();
}

class _TablesCreateBuilderPageState extends State<TablesCreateBuilderPage> {
  late final TListController<DemoProduct, String> _controller;
  final _name = ValueNotifier<String?>(null);
  final _category = ValueNotifier<String?>(null);
  final _price = ValueNotifier<double?>(null);

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
    _name.dispose();
    _category.dispose();
    _price.dispose();
    super.dispose();
  }

  void _clearInputs() {
    _name.value = null;
    _category.value = null;
    _price.value = null;
  }

  void _create(BuildContext context) {
    _controller.addItem(
      DemoProduct(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        name: _name.value?.isNotEmpty == true ? _name.value! : 'New Product',
        category: _category.value?.isNotEmpty == true ? _category.value! : 'General',
        rating: 5.0,
        stock: 10,
        price: _price.value ?? 0.0,
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=100&h=100&fit=crop',
        sku: 'NEW-SKU',
        manufacturer: 'Unknown',
        warranty: 'None',
        weight: '0g',
        description: 'Created inline via createBuilder.',
      ),
    );
    TTableScope.of(context).close(context);
  }

  @override
  Widget build(BuildContext context) {
    return TPageWrapper(
      title: 'Row Expansion: Create Builder',
      description: 'Demo of createBuilder to configure inline/modal creation forms.',
      actions: [
        TButton(
          icon: HugeIcons.strokeRoundedAdd01,
          text: 'Add Product',
          onPressed: (_) {
            _clearInputs();
            _controller.beginCreateItem();
          },
        ),
      ],
      child: TTable<DemoProduct, String>(
        shrinkWrap: true,
        headers: demoProductHeaders(context, stock: false),
        controller: _controller,
        details: TTableDetails(
          mode: TTableExpansionMode.bottom,
          itemTitle: (item) => item.name,
          builder: _buildProductDetails,
          createBuilder: _buildProductForm,
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext ctx, TListItem<DemoProduct, String> item, int index) {
    final data = item.data;
    return TCard(
      title: data.name,
      margin: const EdgeInsets.all(16),
      child: TKeyValueSection(
        values: [
          TKeyValue.text('SKU', data.sku),
          TKeyValue.text('Manufacturer', data.manufacturer),
          TKeyValue.text('Description', data.description),
        ],
      ),
    );
  }

  Widget _buildProductForm(BuildContext context, TListItem<DemoProduct, String>? item, int? index) {
    return TCard(
      title: 'New Product',
      icon: HugeIcons.strokeRoundedPackageAdd,
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          TTextField(label: 'Product Name', valueNotifier: _name),
          TTextField(label: 'Category', valueNotifier: _category),
          TNumberField<double>(label: 'Price', valueNotifier: _price),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              TButton(
                baseTheme: TWidgetTheme.surfaceTheme(context.colors),
                text: 'Cancel',
                onPressed: (_) => TTableScope.of(context).close(context),
              ),
              TButton(text: 'Create', onPressed: (_) => _create(context)),
            ],
          ),
        ],
      ),
    );
  }
}
