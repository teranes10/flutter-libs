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
        )
      ],
      itemKey: (item) => item.id,
    );
  }

  @override
  void dispose() {
    listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TTable<Product, int>(
      headers: headers,
      controller: listController,
      editable: true,
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
