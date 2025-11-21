extension ListX<T> on List<T> {
  /// Adds an item to the beginning or end of the iterable
  List<T> copyWithItem(T item, [bool prepend = false]) {
    return prepend ? [item, ...this] : [...this, item];
  }

  /// Adds multiple items to the beginning or end of the iterable
  List<T> copyWithItems(Iterable<T> items, [bool prepend = false]) {
    return prepend ? [...items, ...this] : [...this, ...items];
  }

  /// Returns a new iterable with elements removed that match the test
  List<T> copyWithRemovedWhere(bool Function(T element) test) {
    final newList = List<T>.from(this);
    newList.removeWhere(test);
    return newList;
  }

  /// Returns a reversed copy of the iterable
  List<T> copyReversed() => reversed.toList();

  /// Returns a sorted copy of the iterable
  List<T> copySorted([int Function(T a, T b)? compare]) {
    final list = List<T>.from(this);
    list.sort(compare);
    return list;
  }

  /// Returns a copy with the first occurrence of oldItem replaced
  List<T> copyWithReplaced(T oldItem, T newItem) {
    final index = indexOf(oldItem);
    if (index == -1) return List.of(this);
    return [...sublist(0, index), newItem, ...sublist(index + 1)];
  }

  /// Returns a copy with all occurrences of oldItem replaced
  List<T> copyWithReplacedAll(T oldItem, T newItem) {
    return map((e) => e == oldItem ? newItem : e).toList();
  }

  /// Returns a copy with the first element matching test replaced
  List<T> copyWithReplacedWhere(bool Function(T item) test, T newItem) {
    final index = indexWhere(test);
    if (index == -1) return List.of(this);
    return [...sublist(0, index), newItem, ...sublist(index + 1)];
  }

  /// Returns a copy with the element at index replaced
  List<T> copyWithReplacedAt(int index, T newItem) {
    if (index < 0 || index >= length) {
      throw RangeError('Index $index out of bounds for list of length $length');
    }
    return [...sublist(0, index), newItem, ...sublist(index + 1)];
  }

  /// Returns a copy with the first occurrence of item removed
  List<T> copyWithRemoved(T item) {
    final index = indexOf(item);
    if (index == -1) return List.of(this);
    return [...sublist(0, index), ...sublist(index + 1)];
  }

  /// Returns a copy with all specified items removed
  List<T> copyWithRemovedItems(Iterable<T> itemsToRemove) {
    if (itemsToRemove.isEmpty) return List.of(this);
    final toRemove = itemsToRemove.toSet();
    return where((e) => !toRemove.contains(e)).toList();
  }

  /// Returns a copy with the element at index removed
  List<T> copyWithRemovedAt(int index) {
    if (index < 0 || index >= length) {
      throw RangeError.index(index, this, 'index', null, length);
    }
    return [...sublist(0, index), ...sublist(index + 1)];
  }

  /// Returns a copy with item inserted at index
  List<T> copyWithInserted(int index, T item) {
    if (index < 0 || index > length) {
      throw RangeError('Index $index out of bounds for list of length $length');
    }
    return [...sublist(0, index), item, ...sublist(index)];
  }

  /// Returns a copy with items inserted at index
  List<T> copyWithInsertedAll(int index, Iterable<T> items) {
    if (index < 0 || index > length) {
      throw RangeError('Index $index out of bounds for list of length $length');
    }
    return [...sublist(0, index), ...items, ...sublist(index)];
  }

  /// Returns a copy with elements moved from oldIndex to newIndex
  List<T> copyWithMoved(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= length) {
      throw RangeError('oldIndex $oldIndex out of bounds');
    }
    if (newIndex < 0 || newIndex >= length) {
      throw RangeError('newIndex $newIndex out of bounds');
    }
    if (oldIndex == newIndex) return List.of(this);

    final item = this[oldIndex];
    final temp = List<T>.from(this);
    temp.removeAt(oldIndex);
    temp.insert(newIndex, item);
    return temp;
  }

  /// Returns a copy with elements swapped at two indices
  List<T> copyWithSwapped(int index1, int index2) {
    if (index1 < 0 || index1 >= length) {
      throw RangeError('index1 $index1 out of bounds');
    }
    if (index2 < 0 || index2 >= length) {
      throw RangeError('index2 $index2 out of bounds');
    }
    if (index1 == index2) return List.of(this);

    final newList = List<T>.from(this);
    final temp = newList[index1];
    newList[index1] = newList[index2];
    newList[index2] = temp;
    return newList;
  }

  /// Checks if this list equals another element by element
  bool equalsEach(List<T> other) {
    if (length != other.length) return false;
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }

  /// Returns a copy with duplicates removed while preserving order
  List<T> copyDistinct() {
    final seen = <T>{};
    return where((e) => seen.add(e)).toList();
  }

  /// Returns the element at index, or null if out of bounds
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Splits the list at the specified index
  (List<T>, List<T>) splitAt(int index) {
    if (index < 0 || index > length) {
      throw RangeError('Index $index out of bounds');
    }
    return (sublist(0, index), sublist(index));
  }

  List<T> reorder(int oldIndex, int newIndex) {
    final newList = List<T>.from(this);
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    return newList;
  }
}
