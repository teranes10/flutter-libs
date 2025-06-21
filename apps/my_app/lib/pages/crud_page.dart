import 'package:flutter/material.dart';
import 'package:my_app/clients/posts_client.dart';
import 'package:my_app/clients/products_client.dart';
import 'package:my_app/models/product_dto.dart';
import 'package:te_widgets/te_widgets.dart';

class CrudPage extends StatelessWidget {
  const CrudPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TCrudTable<ProductDto, ProductForm>(
      headers: [
        TTableHeader(
          'Image',
          builder: (ctx, x) => x.thumbnail != null ? Image.network(x.thumbnail!, width: 50) : SizedBox.shrink(),
        ),
        TTableHeader.map('SKU', (x) => x.sku),
        TTableHeader.map('Title', (x) => x.title),
        TTableHeader.map('Category', (x) => x.category),
        TTableHeader.map('Price', (x) => x.price),
        TTableHeader.map('Discount', (x) => x.discountPercentage),
        TTableHeader.map('Rating', (x) => x.rating),
        TTableHeader.map('Created At', (x) => x.meta?.createdAt ?? ''),
      ],
      onLoad: ProductsClient().loadMore,
      onArchiveLoad: ProductsClient().loadMore,
      createForm: ProductForm(),
      onAddItem: (input) async {
        return ProductDto(
          id: productId++,
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
    );
  }
}

var productId = 1000;
var categories = ['Category 1', 'Category 2', 'Category 3'];

class ProductForm extends TFormBase {
  final title = TFieldProp('');
  final description = TFieldProp('');
  final price = TFieldProp(0.0);
  final date = TFieldProp(DateTime.now());
  final category = TFieldProp('Category 1');

  @override
  double get formWidth => 750;

  @override
  String get formTitle => 'Add New Product';

  @override
  String get formActionName => 'Add New Product';

  @override
  List<TFormField> get fields {
    return [
      TFormField.text(title, 'Title', isRequired: true).size(6),
      TFormField.number(price, 'Price').size(6),
      TFormField.select<ProductDto, String>(category, 'Category',
          onLoad: ProductsClient().loadMore, itemText: (x) => x.title, itemValue: (x) => x.sku),
      TFormField.date(date, "Date"),
      TFormField.text(description, 'Description', rows: 3),
    ];
  }
}
