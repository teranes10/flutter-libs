typedef TSelectRecord<V> = ({
  String text,
  V value,
  String? key,
});

class TSelectItem<V> {
  final String text;
  final V value;
  final String key;
  final List<TSelectItem<V>>? children;

  bool selected = false;
  bool expanded = false;

  TSelectItem({
    required this.text,
    required this.value,
    String? key,
    this.children,
  }) : key = key ?? '${text}_$value';

  factory TSelectItem.fromRecord(TSelectRecord<V> record) {
    return TSelectItem(
      text: record.text,
      value: record.value,
      key: record.key,
    );
  }

  factory TSelectItem.simple(String text, V value, [String? key]) {
    return TSelectItem(text: text, value: value, key: key);
  }

  bool get hasChildren => children != null && children!.isNotEmpty;
  bool get isMultiLevel => hasChildren;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TSelectItem<V> && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'TSelectItem(text: $text, value: $value, key: $key)';
}

typedef ItemTextAccessor<T> = String Function(T item);
typedef ItemValueAccessor<T, V> = V Function(T item);
typedef ItemKeyAccessor<T> = String? Function(T item);
typedef ItemChildrenAccessor<T> = List<T>? Function(T item);

class TSelectItemCollector {
  static List<TSelectItem<V>> getSelectedItems<V>(List<TSelectItem<V>> items) {
    List<TSelectItem<V>> selected = [];

    void collectSelected(List<TSelectItem<V>> items) {
      for (final item in items) {
        if (item.selected) {
          selected.add(item);
        }
        if (item.hasChildren) {
          collectSelected(item.children!);
        }
      }
    }

    collectSelected(items);
    return selected;
  }

  static void clearAllSelections<V>(List<TSelectItem<V>> items) {
    for (final item in items) {
      item.selected = false;
      if (item.hasChildren) {
        clearAllSelections(item.children!);
      }
    }
  }
}

class TSelectItemBuilder {
  static List<TSelectItem<V>> fromMap<V>(Map<String, V> items) {
    return items.entries
        .map((entry) => TSelectItem<V>(
              text: entry.key,
              value: entry.value,
              key: entry.key,
            ))
        .toList();
  }

  static List<TSelectItem<V>> fromHierarchy<V>(
    List<Map<String, dynamic>> hierarchy,
  ) {
    return hierarchy
        .map((item) => TSelectItem<V>(
              text: item['text'] as String,
              value: item['value'] as V,
              key: item['key'] as String?,
              children: item['children'] != null ? fromHierarchy<V>(item['children'] as List<Map<String, dynamic>>) : null,
            ))
        .toList();
  }
}
