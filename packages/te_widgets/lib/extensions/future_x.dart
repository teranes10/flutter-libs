extension FutureX<T> on Future<T> {
  /// Ignores any error that occurs during the future execution.
  /// Usage: fetchData().ignoreError()
  Future<T?> ignoreError() async {
    try {
      return await this;
    } catch (_) {
      return null;
    }
  }

  /// Executes [onSuccess] if the future completes successfully,
  /// and [onError] if it fails.
  Future<T> result({
    void Function(T data)? onSuccess,
    void Function(Object error)? onError,
  }) async {
    try {
      final data = await this;
      onSuccess?.call(data);
      return data;
    } catch (e) {
      onError?.call(e);
      rethrow;
    }
  }
}
