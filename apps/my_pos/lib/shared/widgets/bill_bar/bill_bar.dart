import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pos/features/cart/cart_provider.dart';
import 'package:my_pos/shared/widgets/bill_bar/bill_footer.dart';
import 'package:my_pos/shared/widgets/bill_bar/bill_header.dart';
import 'package:my_pos/shared/widgets/bill_bar/bill_item.dart';
import 'package:my_pos/models/cart_item.dart';
import 'package:te_widgets/te_widgets.dart';

class TBillBar extends ConsumerWidget {
  const TBillBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final cartItems = ref.watch(cartProvider);

    return Container(
      width: 325,
      decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        children: [
          const TBillHeader(),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 7.5, vertical: 10),
              child: TList<CartItem, int>(
                theme: context.theme.listTheme.copyWith(footerBuilder: (context) => TBillFooter(onPlaceOrder: () {}), footerSticky: true),
                items: cartItems,
                itemBuilder: (context, item, index) => TBillItem(item: item.data, onRemove: () {}, onIncrement: () {}, onDecrement: () {}),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
