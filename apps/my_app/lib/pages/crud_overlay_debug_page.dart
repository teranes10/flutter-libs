import 'package:flutter/material.dart';
import 'package:my_app/models/product_dto.dart';
import 'package:te_widgets/te_widgets.dart';
import 'crud_page.dart' show ProductForm;

class CrudOverlayDebugPage extends StatefulWidget {
  const CrudOverlayDebugPage({super.key});

  @override
  State<CrudOverlayDebugPage> createState() => _CrudOverlayDebugPageState();
}

class _CrudOverlayDebugPageState extends State<CrudOverlayDebugPage> {
  TTableExpansionMode _mode = TTableExpansionMode.dialog;
  var _productId = 5000;

  @override
  Widget build(BuildContext context) {
    final controller = TListController<ProductDto, int>(
      expansionMode: TExpansionMode.single,
      items: [
        ProductDto(
          id: 1,
          title: "Debug Product",
          description: 'description',
          price: 10,
          discountPercentage: 10,
          rating: 2.34,
          stock: 100,
          category: 'category',
          sku: 'sku',
        ),
      ],
    );

    List<TTableHeader<ProductDto, int>> headers = [
      TTableHeader.map('Title', (x) => x.title),
      TTableHeader.map('SKU', (x) => x.sku),
      TTableHeader.map('Price', (x) => '\$${x.price}'),
      TTableHeader.map('Stock', (x) => '${x.stock}'),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Mode: '),
                DropdownButton<TTableExpansionMode>(
                  value: _mode,
                  items: const [
                    DropdownMenuItem(value: TTableExpansionMode.dialog, child: Text('dialog')),
                    DropdownMenuItem(value: TTableExpansionMode.page, child: Text('page')),
                  ],
                  onChanged: (m) => setState(() => _mode = m!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TCrudTable<ProductDto, int, ProductForm>(
                headers: headers,
                createForm: () => ProductForm(),
                editForm: (ProductDto item) => ProductForm(item),
                onCreate: (input) async {
                  return ProductDto(
                    id: _productId++,
                    title: input.title.value,
                    description: input.description.value,
                    price: input.price.value,
                    discountPercentage: 1,
                    rating: 1,
                    stock: 1,
                    category: 'category',
                    sku: 'sku',
                  );
                },
                onEdit: (item, form) async {
                  return item.copyWith(title: form.title.value, description: form.description.value, price: form.price.value);
                },
                itemTitle: (item) => item.title,
                expansionMode: _mode,
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
