import 'package:my_pos/models/cart_item.dart';
import 'package:my_pos/models/product.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_provider.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  Map<String, CartItem> build() => {};

  void add(Product product, {int qty = 1}) {
    final existing = state[product.id];
    if (existing == null) {
      state = {...state, product.id: CartItem(product: product, quantity: qty)};
    } else {
      state = {...state, product.id: existing.copyWith(quantity: existing.quantity + qty)};
    }
  }

  void updateQty(String productId, int qty) {
    final existing = state[productId];
    if (existing == null) return;

    state = {...state, productId: existing.copyWith(quantity: qty)};
  }

  void changeQty(String productId, int delta) {
    final existing = state[productId];
    if (existing == null) return;

    final newQty = existing.quantity + delta;

    if (newQty <= 0) {
      final newState = Map.of(state);
      newState.remove(productId);
      state = newState;
    } else {
      state = {...state, productId: existing.copyWith(quantity: newQty)};
    }
  }

  void remove(String productId) {
    final newState = Map.of(state);
    newState.remove(productId);
    state = newState;
  }

  void clear() => state = {};

  double get subtotal => state.values.fold(0, (sum, item) => sum + item.lineSubtotal);

  double get totalTax => state.values.fold(0, (sum, item) => sum + item.lineTax);

  double get grandTotal => subtotal + totalTax;
}
