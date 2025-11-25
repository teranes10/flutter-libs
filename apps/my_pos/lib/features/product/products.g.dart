// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Products)
const productsProvider = ProductsProvider._();

final class ProductsProvider
    extends $AsyncNotifierProvider<Products, Map<String, Product>> {
  const ProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsHash();

  @$internal
  @override
  Products create() => Products();
}

String _$productsHash() => r'c53cadad63c3b204a3ab99ece6ad90f12954acdf';

abstract class _$Products extends $AsyncNotifier<Map<String, Product>> {
  FutureOr<Map<String, Product>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<Map<String, Product>>, Map<String, Product>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, Product>>,
                Map<String, Product>
              >,
              AsyncValue<Map<String, Product>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CategoryProducts)
const categoryProductsProvider = CategoryProductsProvider._();

final class CategoryProductsProvider
    extends
        $AsyncNotifierProvider<CategoryProducts, Map<String, List<Product>>> {
  const CategoryProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryProductsHash();

  @$internal
  @override
  CategoryProducts create() => CategoryProducts();
}

String _$categoryProductsHash() => r'86c16a3763d08f8ea949a32082e7fdf2a4d27f6b';

abstract class _$CategoryProducts
    extends $AsyncNotifier<Map<String, List<Product>>> {
  FutureOr<Map<String, List<Product>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, List<Product>>>,
              Map<String, List<Product>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, List<Product>>>,
                Map<String, List<Product>>
              >,
              AsyncValue<Map<String, List<Product>>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CurrentCategoryProducts)
const currentCategoryProductsProvider = CurrentCategoryProductsProvider._();

final class CurrentCategoryProductsProvider
    extends $AsyncNotifierProvider<CurrentCategoryProducts, List<Product>> {
  const CurrentCategoryProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentCategoryProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentCategoryProductsHash();

  @$internal
  @override
  CurrentCategoryProducts create() => CurrentCategoryProducts();
}

String _$currentCategoryProductsHash() =>
    r'72322a360e1596f7625081e21cb415057bade950';

abstract class _$CurrentCategoryProducts extends $AsyncNotifier<List<Product>> {
  FutureOr<List<Product>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Product>>, List<Product>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Product>>, List<Product>>,
              AsyncValue<List<Product>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
