import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

@immutable
class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final List<TTableHeader<Product, int>> headers;
  late final TListController<Product, int> listController;
  late final List<TTableHeader<ProductForm, int>> formHeaders;
  late final TListController<ProductForm, int> formController;

  @override
  void initState() {
    super.initState();

    headers = [
      TTableHeader.map('SKU', (x) => x.sku),
      TTableHeader.textField('Title', (x) => x.title, (x, v) => x.title = v),
      TTableHeader.textField('Category', (x) => x.category, (x, v) => x.category = v),
      TTableHeader.numberField('Price', (x) => x.price, (x, v) => x.price = v?.toDouble()),
      TTableHeader.numberField('Discount', (x) => x.discountPercentage, (x, v) => x.discountPercentage = v?.toDouble()),
      TTableHeader.numberField('Rating', (x) => x.rating, (x, v) => x.rating = v?.toDouble()),
    ];

    // Table columns generated from the form's fields; each row is one ProductForm.
    formHeaders = ProductForm(0).toTableHeaders<int>();
    formController = TListController<ProductForm, int>(
      reorderable: true,
      items: [for (var i = 1; i <= 4; i++) ProductForm(i, sku: 'sku $i', title: 'Item $i', category: 'category', price: 10.0 * i, discount: 5.0 * i, rating: 3)],
      itemKey: (item) => item.id,
    );

    listController = TListController<Product, int>(
      items: [
        Product(
          id: 1,
          title: "title",
          description: 'description',
          price: 10,
          discountPercentage: 10,
          rating: 2.34,
          stock: 100,
          category: 'category',
          sku: 'sku 1',
        ),
        Product(
          id: 2,
          title: "title",
          description: 'description',
          price: 10,
          discountPercentage: 10,
          rating: 2.34,
          stock: 100,
          category: 'category',
          sku: 'sku 2',
        ),
        Product(
          id: 3,
          title: "title",
          description: 'description',
          price: 10,
          discountPercentage: 10,
          rating: 2.34,
          stock: 100,
          category: 'category',
          sku: 'sku 3',
        ),
        Product(
          id: 4,
          title: "title",
          description: 'description',
          price: 10,
          discountPercentage: 10,
          rating: 2.34,
          stock: 100,
          category: 'category',
          sku: 'sku 4',
        ),
        Product(
          id: 5,
          title: "title",
          description: 'description',
          price: 10,
          discountPercentage: 10,
          rating: 2.34,
          stock: 100,
          category: 'category',
          sku: 'sku 5',
        ),
        Product(
          id: 6,
          title: "title",
          description: 'description',
          price: 10,
          discountPercentage: 10,
          rating: 2.34,
          stock: 100,
          category: 'category',
          sku: 'sku 6',
        ),
      ],
      itemKey: (item) => item.id,
    );
  }

  @override
  void dispose() {
    listController.dispose();
    formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: TTable<Product, int>(dense: true, headers: headers, controller: listController, editable: true),
        ),
        const SizedBox(height: 16),
        // Same table, but the columns come from a TFormBase via toTableHeaders().
        Expanded(
          child: TTable<ProductForm, int>(dense: true, headers: formHeaders, controller: formController, editable: true, removable: true),
        ),
      ],
    );
  }
}

class Product {
  final int id;
  String? title;
  String? description;
  String? sku;
  String? category;
  double? price;
  double? discountPercentage;
  double? rating;
  int? stock;

  Product({
    required this.id,
    this.title,
    this.description,
    this.sku,
    this.category,
    this.price,
    this.discountPercentage,
    this.rating,
    this.stock,
  });
}

/// A form whose fields are reused as table columns through [TFormBaseTableHeaders.toTableHeaders].
class ProductForm extends TFormBase {
  final int id;
  final sku = TFieldProp<String?>('');
  final title = TFieldProp<String?>('');
  final category = TFieldProp<String?>('');
  final price = TFieldProp<num?>(null);
  final discount = TFieldProp<num?>(null);
  final rating = TFieldProp<num?>(null);

  ProductForm(this.id, {String? sku, String? title, String? category, num? price, num? discount, num? rating}) {
    this.sku.value = sku;
    this.title.value = title;
    this.category.value = category;
    this.price.value = price;
    this.discount.value = discount;
    this.rating.value = rating;
  }

  // Built once so cell editors keep their state across table rebuilds.
  @override
  late final List<TFormField> fields = [
    TFormField.text(sku, 'SKU'),
    TFormField.text(title, 'Title', isRequired: true),
    TFormField.text(category, 'Category'),
    TFormField.number(price, 'Price'),
    TFormField.number(discount, 'Discount'),
    TFormField.number(rating, 'Rating'),
  ];
}
