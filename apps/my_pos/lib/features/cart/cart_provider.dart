import 'package:my_pos/models/cart_item.dart';
import 'package:my_pos/models/product.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_provider.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  List<CartItem> build() => [];

  void add(Product product, {int qty = 1}) {
    final existing = state.where((i) => i.product.id == product.id).toList();

    if (existing.isEmpty) {
      state = [...state, CartItem(product: product, quantity: qty)];
    } else {
      final current = existing.first;
      final updated = current.copyWith(quantity: current.quantity + qty);
      state = [
        for (final item in state)
          if (item.product.id == product.id) updated else item,
      ];
    }
  }

  void updateQty(String productId, int qty) {
    state = [
      for (final item in state)
        if (item.product.id == productId) item.copyWith(quantity: qty) else item,
    ];
  }

  void remove(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void clear() => state = [];

  double get subtotal => state.fold(0, (sum, item) => sum + item.lineSubtotal);
  double get totalTax => state.fold(0, (sum, item) => sum + item.lineTax);
  double get grandTotal => subtotal + totalTax;
}
