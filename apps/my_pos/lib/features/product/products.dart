import 'package:my_pos/features/category/categories.dart';
import 'package:my_pos/features/product/product_api.dart';
import 'package:my_pos/models/product.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'products.g.dart';

@riverpod
class Products extends _$Products {
  @override
  Future<Map<String, Product>> build() async {
    final api = ref.read(productApiProvider);
    final products = await api.fetchProducts();

    return {
      for (var product in products)
        product.id.toString(): Product(
          id: product.id.toString(),
          categoryId: product.category.id.toString(),
          name: product.title,
          price: product.price,
          image: product.images.first,
        ),
    };
  }
}

@riverpod
class CategoryProducts extends _$CategoryProducts {
  @override
  Future<Map<String, List<Product>>> build() async {
    final productsMap = await ref.watch(productsProvider.future);
    final Map<String, List<Product>> grouped = {};

    for (var product in productsMap.values) {
      grouped.putIfAbsent(product.categoryId, () => []).add(product);
    }

    return grouped;
  }
}

@riverpod
class CurrentCategoryProducts extends _$CurrentCategoryProducts {
  @override
  Future<List<Product>> build() async {
    final groupedProducts = await ref.watch(categoryProductsProvider.future);
    final currentCategoryId = ref.watch(currentCategoryProvider);

    if (currentCategoryId == null) {
      return groupedProducts.values.expand((list) => list).toList();
    }

    return groupedProducts[currentCategoryId] ?? [];
  }
}
