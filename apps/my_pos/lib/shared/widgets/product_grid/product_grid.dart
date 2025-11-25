import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_pos/features/cart/cart_provider.dart';
import 'package:my_pos/features/product/products.dart';
import 'package:my_pos/models/product.dart';
import 'package:te_widgets/te_widgets.dart';

class TProductGrid extends ConsumerWidget {
  const TProductGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(currentCategoryProductsProvider).value ?? [];
    return TListView(
      grid: TGridMode.masonry,
      gridDelegate: (context) => TGridDelegate(maxCrossAxisExtent: 275),
      items: products.map((x) => TListItem(key: x.id, data: x)).toList(),
      itemBuilder: (context, item, index) {
        return TProductCard(product: item.data, onTap: () => ref.read(cartProvider.notifier).add(item.data));
      },
      emptyStateBuilder: (context) =>
          TListTheme.buildEmptyState(context.colors, title: 'No Products Found', message: 'There are no products in this category yet.'),
    );
  }
}

class TProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const TProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        hoverColor: colors.surfaceDim.withAlpha(100),
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TImage.circle(size: 100, url: product.image, disabled: true),
              const SizedBox(height: 12),
              Text(
                product.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: colors.onSurface),
              ),
              const SizedBox(height: 3),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
