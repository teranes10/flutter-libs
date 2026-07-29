part of 'list_controller.dart';

extension TListControllerRiverpod<T, K> on TListController<T, K> {
  void bindAsync(
    WidgetRef ref,
    ProviderListenable<AsyncValue<List<T>>> provider,
  ) {
    handleAsyncValue(ref.read(provider));

    ref.listen(
      provider,
      (_, next) => handleAsyncValue(next),
    );
  }

  void bindAsyncMap<S>(
    WidgetRef ref,
    ProviderListenable<AsyncValue<S>> provider, {
    required List<T> Function(S v) map,
  }) {
    handleAsyncValueMap(ref.read(provider), map);

    ref.listen(
      provider,
      (_, next) => handleAsyncValueMap(next, map),
    );
  }

  void handleAsyncValue(AsyncValue<List<T>> next) {
    next.when(
      data: updateItems,
      error: updateError,
      loading: updateLoading,
    );
  }

  void handleAsyncValueMap<S>(AsyncValue<S> next, List<T> Function(S v) map) {
    next.when(
      data: (s) => updateItems(map(s)),
      error: updateError,
      loading: updateLoading,
    );
  }
}
