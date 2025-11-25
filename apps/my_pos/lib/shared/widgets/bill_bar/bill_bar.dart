import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pos/features/cart/cart_provider.dart';
import 'package:my_pos/shared/widgets/bill_bar/bill_footer.dart';
import 'package:my_pos/shared/widgets/bill_bar/bill_header.dart';
import 'package:my_pos/shared/widgets/bill_bar/bill_item.dart';
import 'package:te_widgets/te_widgets.dart';

class TBillBar extends ConsumerWidget {
  const TBillBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final cartItems = ref.watch(cartProvider).values.toList();
    final cartNotifier = ref.read(cartProvider.notifier);

    return Container(
      width: 325,
      decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        children: [
          const TBillHeader(),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 7.5, vertical: 10),
              child: TListView(
                footerBuilder: (context) => TBillFooter(onPlaceOrder: () {}),
                footerSticky: true,
                items: cartItems.map((x) => TListItem(key: x.product.id, data: x)).toList(),
                itemBuilder: (context, item, index) => TBillItem(
                  item: item.data,
                  onRemove: () => cartNotifier.remove(item.data.product.id),
                  onIncrement: () => cartNotifier.changeQty(item.data.product.id, 1),
                  onDecrement: () => cartNotifier.changeQty(item.data.product.id, -1),
                ),
                emptyStateBuilder: (context) => TListTheme.buildEmptyState(
                  context.colors,
                  icon: Icons.shopping_cart_outlined,
                  title: 'Your Cart is Empty',
                  message: 'Add some products to get started!',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
