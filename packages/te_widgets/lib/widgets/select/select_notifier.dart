import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';

class TSelectStateNotifier<T, V> extends ChangeNotifier {
  final List<T> _originalItems;
  final ItemTextAccessor<T>? itemText;
  final ItemValueAccessor<T, V>? itemValue;
  final ItemKeyAccessor<T>? itemKey;
  final ItemChildrenAccessor<T>? itemChildren;
  final bool isMultiple;
  final String? label;

  List<TSelectItem<V>> _internalItems = [];
  List<TSelectItem<V>> _filteredItems = [];
  String _searchQuery = '';
  double _scrollPosition = 0.0;
  Timer? _debounceTimer;

  final ValueNotifier<List<TSelectItem<V>>> filteredItemsNotifier = ValueNotifier([]);
  final ValueNotifier<String> searchQueryNotifier = ValueNotifier('');
  final ValueNotifier<double> scrollPositionNotifier = ValueNotifier(0.0);

  TSelectStateNotifier({
    required List<T> items,
    required this.isMultiple,
    this.itemText,
    this.itemValue,
    this.itemKey,
    this.itemChildren,
    this.label,
  }) : _originalItems = items {
    _initializeItems();
  }

  // Getters
  List<TSelectItem<V>> get internalItems => _internalItems;
  List<TSelectItem<V>> get filteredItems => _filteredItems;
  String get searchQuery => _searchQuery;
  double get scrollPosition => _scrollPosition;

  void _initializeItems() {
    _internalItems = _originalItems.map(_convertToSelectItem).toList();
    _filteredItems = List.from(_internalItems);
    filteredItemsNotifier.value = _filteredItems;
  }

  void updateItems(List<T> newItems) {
    if (!listEquals(_originalItems, newItems)) {
      _originalItems.clear();
      _originalItems.addAll(newItems);
      _initializeItems();
    }
  }

  void updateSelectedStates(List<V> selectedValues) {
    _updateSelectedStatesRecursive(_internalItems, selectedValues);
    _updateSelectedStatesRecursive(_filteredItems, selectedValues);
    filteredItemsNotifier.value = List.from(_filteredItems);
  }

  bool _updateSelectedStatesRecursive(List<TSelectItem<V>> items, List<V> selectedValues) {
    bool anySelected = false;

    for (final item in items) {
      bool isDirectlySelected = selectedValues.contains(item.value);
      item.selected = isDirectlySelected;

      bool hasSelectedChildren = false;
      if (item.hasChildren) {
        hasSelectedChildren = _updateSelectedStatesRecursive(item.children!, selectedValues);
        item.expanded = hasSelectedChildren;
      }

      if (isDirectlySelected || hasSelectedChildren) {
        anySelected = true;
      }
    }

    return anySelected;
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _filterItems(query);
    });
  }

  void _filterItems(String query) {
    _searchQuery = query;
    searchQueryNotifier.value = query;

    if (query.isEmpty) {
      _filteredItems = List.from(_internalItems);
    } else {
      _filteredItems = _internalItems.where((item) {
        return _itemMatchesQuery(item, query.toLowerCase());
      }).toList();
    }

    filteredItemsNotifier.value = _filteredItems;
  }

  bool _itemMatchesQuery(TSelectItem<V> item, String query) {
    if (item.text.toLowerCase().contains(query)) {
      return true;
    }

    if (item.hasChildren) {
      return item.children!.any((child) => _itemMatchesQuery(child, query));
    }

    return false;
  }

  void onItemTapped(TSelectItem<V> item) {
    if (item.hasChildren) {
      item.expanded = !item.expanded;
      filteredItemsNotifier.value = List.from(_filteredItems);
      return;
    }

    if (isMultiple) {
      item.selected = !item.selected;
    } else {
      _clearAllSelections(_internalItems);
      _clearAllSelections(_filteredItems);
      item.selected = true;
    }

    filteredItemsNotifier.value = List.from(_filteredItems);
  }

  void _clearAllSelections(List<TSelectItem<V>> items) {
    for (final item in items) {
      item.selected = false;
      if (item.hasChildren) {
        _clearAllSelections(item.children!);
      }
    }
  }

  void updateScrollPosition(double position) {
    _scrollPosition = position;
    scrollPositionNotifier.value = position;
  }

  void onScrollEnd() {}

  List<TSelectItem<V>> getSelectedItems() {
    List<TSelectItem<V>> selectedItems = [];
    _collectSelectedItems(_internalItems, selectedItems);
    return selectedItems;
  }

  void _collectSelectedItems(List<TSelectItem<V>> items, List<TSelectItem<V>> selectedItems) {
    for (final item in items) {
      if (item.selected && !item.hasChildren) {
        selectedItems.add(item);
      }
      if (item.hasChildren) {
        _collectSelectedItems(item.children!, selectedItems);
      }
    }
  }

  int countVisibleItems(List<TSelectItem<V>> items) {
    int count = 0;
    for (final item in items) {
      count++;
      if (item.hasChildren && item.expanded) {
        count += countVisibleItems(item.children!);
      }
    }
    return count;
  }

  TSelectItem<V> _convertToSelectItem(T item) {
    assert(V != Null, 'Select labeled "$label": value type can not be Null.');

    switch (item) {
      case TSelectItem<V> i:
        return i;
      case TSelectRecord<V> record:
        return TSelectItem<V>.fromRecord(record);
      case String s when V == String:
        return TSelectItem<V>.simple(s, s as V, s);
      case int i when V == int:
        final text = i.toString();
        return TSelectItem<V>.simple(text, i as V, text);
      case double d when V == double:
        final text = d.toString();
        return TSelectItem<V>.simple(text, d as V, text);
      case bool b when V == bool:
        final text = b.toString();
        return TSelectItem<V>.simple(text, b as V, text);
      case num n when V == num:
        final text = n.toString();
        return TSelectItem<V>.simple(text, n as V, text);
      default:
        final text = itemText?.call(item);
        final value = itemValue != null ? itemValue!.call(item) : item;
        final key = itemKey?.call(item);
        final children = itemChildren?.call(item);

        assert(
          text != null,
          'Select labeled "$label": For custom item "$item", `itemText` must not return null.',
        );

        assert(
          value is V,
          'Select labeled "$label": `itemValue` result is not of type $V. Got: ${value.runtimeType} from item "$item".',
        );

        return TSelectItem<V>(
          text: text!,
          value: value as V,
          key: key,
          children: children?.map(_convertToSelectItem).toList(),
        );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    filteredItemsNotifier.dispose();
    searchQueryNotifier.dispose();
    scrollPositionNotifier.dispose();
    super.dispose();
  }
}
