import 'package:my_pos/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(product: product ?? this.product, quantity: quantity ?? this.quantity);
  }

  double get lineSubtotal => product.price * quantity;
  double get lineTax => 0;
}
