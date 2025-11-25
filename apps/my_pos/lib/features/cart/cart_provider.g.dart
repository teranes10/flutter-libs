// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CartNotifier)
const cartProvider = CartNotifierProvider._();

final class CartNotifierProvider
    extends $NotifierProvider<CartNotifier, Map<String, CartItem>> {
  const CartNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartNotifierHash();

  @$internal
  @override
  CartNotifier create() => CartNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, CartItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, CartItem>>(value),
    );
  }
}

String _$cartNotifierHash() => r'4109ec44810537234095b72696caad072371e9d3';

abstract class _$CartNotifier extends $Notifier<Map<String, CartItem>> {
  Map<String, CartItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Map<String, CartItem>, Map<String, CartItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, CartItem>, Map<String, CartItem>>,
              Map<String, CartItem>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
