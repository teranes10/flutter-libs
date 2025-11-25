import 'package:flutter/material.dart';
import 'package:my_pos/models/cart_item.dart';
import 'package:te_widgets/te_widgets.dart';

class TBillItem extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const TBillItem({super.key, required this.item, required this.onRemove, required this.onIncrement, required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              width: constraints.maxWidth,
              margin: const EdgeInsets.only(bottom: 7.5),
              padding: const EdgeInsets.only(left: 5, right: 15, top: 7.5, bottom: 5),
              decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
              child: TImage.circle(
                size: 50,
                url: item.product.image,
                title: item.product.name,
                subTitle:
                    '\$${item.product.price.toStringAsFixed(2)}${item.quantity > 1 ? ' * ${item.quantity} = \$${item.lineSubtotal.toStringAsFixed(2)}' : ''}',
                disabled: true,
              ),
            ),
            Positioned(
              top: 2.5,
              right: 2.5,
              child: buildButton(icon: Icons.close, background: colors.error, color: colors.onError, onTap: onRemove),
            ),
            Positioned(
              bottom: 10,
              right: 2,
              child: Container(
                decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    buildButton(icon: Icons.remove, background: colors.surfaceDim, color: colors.onSurface, onTap: onDecrement),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onSurface),
                      ),
                    ),
                    buildButton(icon: Icons.add, background: colors.primary, color: colors.onPrimary, onTap: onIncrement),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildButton({required Color background, required Color color, required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(3.5),
          child: Icon(icon, size: 10, color: color),
        ),
      ),
    );
  }
}
