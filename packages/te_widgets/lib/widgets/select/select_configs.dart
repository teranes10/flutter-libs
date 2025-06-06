abstract class TSelectItem<V> {
  final String text;
  final V value;
  final String key;
  bool selected;
  bool expanded;

  TSelectItem({
    required this.text,
    required this.value,
    required this.key,
    this.selected = false,
    this.expanded = false,
  });

  // Override equality and hashCode for better state management
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TSelectItem<V> && other.key == key && other.value == value && other.selected == selected && other.expanded == expanded;
  }

  @override
  int get hashCode => Object.hash(key, value, selected, expanded);
}

class TSimpleSelectItem<V> extends TSelectItem<V> {
  TSimpleSelectItem({
    required super.text,
    required super.value,
    required super.key,
    super.selected,
    super.expanded,
  });

  // Create a copy with updated state
  TSimpleSelectItem<V> copyWith({
    String? text,
    V? value,
    String? key,
    bool? selected,
    bool? expanded,
  }) {
    return TSimpleSelectItem<V>(
      text: text ?? this.text,
      value: value ?? this.value,
      key: key ?? this.key,
      selected: selected ?? this.selected,
      expanded: expanded ?? this.expanded,
    );
  }
}

class TMultiLevelSelectItem<V> extends TSelectItem<V> {
  final List<TMultiLevelSelectItem<V>>? items;

  TMultiLevelSelectItem({
    required super.text,
    required super.value,
    required super.key,
    super.selected,
    super.expanded,
    this.items,
  });

  bool get hasChildren => items != null && items!.isNotEmpty;

  // Create a copy with updated state
  TMultiLevelSelectItem<V> copyWith({
    String? text,
    V? value,
    String? key,
    bool? selected,
    bool? expanded,
    List<TMultiLevelSelectItem<V>>? items,
  }) {
    return TMultiLevelSelectItem<V>(
      text: text ?? this.text,
      value: value ?? this.value,
      key: key ?? this.key,
      selected: selected ?? this.selected,
      expanded: expanded ?? this.expanded,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TMultiLevelSelectItem<V> &&
        other.key == key &&
        other.value == value &&
        other.selected == selected &&
        other.expanded == expanded &&
        _listEquals(other.items, items);
  }

  @override
  int get hashCode => Object.hash(key, value, selected, expanded, items);

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

class TSelectItemBuilder {
  static List<TSimpleSelectItem<V>> fromMap<V>(Map<String, V> items) {
    return items.entries
        .map((entry) => TSimpleSelectItem<V>(
              text: entry.key,
              value: entry.value,
              key: entry.key,
            ))
        .toList();
  }

  static List<TSimpleSelectItem<String>> fromList(List<String> items) {
    return items
        .asMap()
        .entries
        .map((entry) => TSimpleSelectItem<String>(
              text: entry.value,
              value: entry.value,
              key: '${entry.key}_${entry.value}', // More unique key
            ))
        .toList();
  }

  static List<TMultiLevelSelectItem<V>> fromHierarchy<V>(
    List<Map<String, dynamic>> hierarchy,
  ) {
    return hierarchy
        .map((item) => TMultiLevelSelectItem<V>(
              text: item['text'] as String,
              value: item['value'] as V,
              key: item['key'] as String,
              items: item['children'] != null ? fromHierarchy<V>(item['children'] as List<Map<String, dynamic>>) : null,
            ))
        .toList();
  }
}
