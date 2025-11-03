extension IterableX<T> on Iterable<T> {
  /// Returns the first element matching the test, or null if none found
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Returns the last element matching the test, or null if none found
  T? lastWhereOrNull(bool Function(T element) test) {
    T? result;
    for (final element in this) {
      if (test(element)) result = element;
    }
    return result;
  }

  /// Checks if this iterable equals another element by element
  bool equalsEach(Iterable<T> other) {
    final a = iterator;
    final b = other.iterator;

    while (a.moveNext()) {
      if (!b.moveNext() || a.current != b.current) return false;
    }
    return !b.moveNext();
  }

  /// Counts elements that match the test
  int countWhere(bool Function(T element) test) {
    int count = 0;
    for (final element in this) {
      if (test(element)) count++;
    }
    return count;
  }

  /// Returns true if any element is null
  bool get containsNull => any((e) => e == null);

  /// Returns a copy without null values (for nullable types)
  Iterable<T> whereNotNull() => where((e) => e != null);

  /// Groups elements by a key function
  Map<K, List<T>> groupBy<K>(K Function(T element) keyOf) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keyOf(element);
      (map[key] ??= []).add(element);
    }
    return map;
  }

  /// Returns chunks of the specified size
  Iterable<List<T>> chunked(int size) sync* {
    if (size <= 0) throw ArgumentError('Size must be positive');
    final it = iterator;
    while (it.moveNext()) {
      final chunk = <T>[it.current];
      for (int i = 1; i < size && it.moveNext(); i++) {
        chunk.add(it.current);
      }
      yield chunk;
    }
  }

  /// Returns distinct elements (removes duplicates)
  Iterable<T> distinct() => toSet();

  /// Returns distinct elements by a key selector
  Iterable<T> distinctBy<K>(K Function(T element) keyOf) {
    final seen = <K>{};
    return where((element) => seen.add(keyOf(element)));
  }

  /// Usage: list.forEachIndexed((index, item) => print('$index: $item'))
  void forEachIndexed(void Function(int index, T element) action) {
    int index = 0;
    for (final element in this) {
      action(index++, element);
    }
  }

  /// Maps with index
  Iterable<R> mapIndexed<R>(R Function(int index, T element) transform) sync* {
    int index = 0;
    for (final element in this) {
      yield transform(index++, element);
    }
  }
}

extension IterableNumX<T extends num> on Iterable<T> {
  /// Returns sum of all elements
  num sum() {
    num total = 0;
    for (final element in this) {
      total += element;
    }
    return total;
  }

  /// Returns average of all elements
  double average() {
    if (isEmpty) return 0;
    return sum() / length;
  }

  /// Returns the maximum element or null if empty
  num? get maxOrNull => isEmpty ? null : reduce((a, b) => a > b ? a : b);

  /// Returns the minimum element or null if empty
  num? get minOrNull => isEmpty ? null : reduce((a, b) => a < b ? a : b);
}

extension IterableIntX on Iterable<int> {
  /// Returns sum of all elements
  int sum() {
    int total = 0;
    for (final element in this) {
      total += element;
    }
    return total;
  }

  /// Returns average of all elements
  double average() {
    if (isEmpty) return 0;
    return sum() / length;
  }
}

extension IterableDoubleX on Iterable<double> {
  /// Returns sum of all elements
  double sum() {
    double total = 0;
    for (final element in this) {
      total += element;
    }
    return total;
  }

  /// Returns average of all elements
  double average() {
    if (isEmpty) return 0;
    return sum() / length;
  }
}
