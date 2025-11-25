// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(productApi)
const productApiProvider = ProductApiProvider._();

final class ProductApiProvider
    extends $FunctionalProvider<ProductApi, ProductApi, ProductApi>
    with $Provider<ProductApi> {
  const ProductApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productApiHash();

  @$internal
  @override
  $ProviderElement<ProductApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProductApi create(Ref ref) {
    return productApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductApi>(value),
    );
  }
}

String _$productApiHash() => r'eef2a0defb957a4f031125a75542c2370c814f86';
