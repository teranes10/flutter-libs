import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/clients/products_client.dart';
import 'package:my_app/models/product_dto.dart';
import 'package:my_app/pages/crud_page.dart';
import 'package:te_widgets/te_widgets.dart';

class ProductsNotifier extends AsyncNotifier<List<ProductDto>> {
  @override
  FutureOr<List<ProductDto>> build() async {
    final result = await ProductsClient().fetchProducts();
    return result.$1;
  }
}

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<ProductDto>>(ProductsNotifier.new);

final productTableControllerProvider = Provider<TListController<ProductDto, int>>((ref) {
  final controller = TListController<ProductDto, int>(
    selectionMode: TSelectionMode.multiple,
    expansionMode: TExpansionMode.single,
    itemKey: (x) => x.id,
    loading: true,
  );

  ref.listen(productsProvider, (_, next) => controller.handleAsyncValue(next));

  ref.onDispose(() => controller.dispose());

  return controller;
});

class CrudRiverpodPage extends ConsumerWidget {
  const CrudRiverpodPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(productTableControllerProvider);

    return TCrudTable<ProductDto, int, ProductForm>(
      controller: controller,
      headers: [
        TTableHeader.image("Image", (x) => x.thumbnail ?? ''),
        TTableHeader.map('SKU', (x) => x.sku),
        TTableHeader.map('Title', (x) => x.title),
        TTableHeader.map('Category', (x) => x.category),
        TTableHeader.map('Price', (x) => x.price),
        TTableHeader.chip('Stock', (x) => x.stock, color: (_) => AppColors.info),
      ],
      createForm: () => ProductForm(),
      editForm: (ProductDto item) => ProductForm(item),
      onCreate: (input) async {
        final newItem = ProductDto(
          id: productId++,
          title: input.title.value,
          description: input.description.value,
          price: input.price.value,
          discountPercentage: 0,
          rating: 0,
          stock: 0,
          category: input.category.value,
          sku: 'NEW-SKU',
        );
        controller.addItem(newItem);
        TToastService.success(context, 'Product created successfully');
        return newItem;
      },
      onEdit: (item, form) async {
        final updatedItem = item.copyWith(
          title: form.title.value,
          description: form.description.value,
          price: form.price.value,
          category: form.category.value,
        );
        controller.updateItem(item, updatedItem);
        TToastService.success(context, 'Product updated successfully');
        return updatedItem;
      },
    );
  }
}
