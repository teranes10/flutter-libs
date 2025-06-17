import 'package:flutter/foundation.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';

class TSelectStateNotifier<T, V> extends ChangeNotifier {
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

  // Notifiers for reactive updates
  final ValueNotifier<List<TSelectItem<V>>> filteredItemsNotifier = ValueNotifier([]);
  final ValueNotifier<String> searchQueryNotifier = ValueNotifier('');
  final ValueNotifier<double> scrollPositionNotifier = ValueNotifier(0.0);

  TSelectStateNotifier({
    required this.isMultiple,
    this.itemText,
    this.itemValue,
    this.itemKey,
    this.itemChildren,
    this.label,
  });

  // Getters
  List<TSelectItem<V>> get internalItems => _internalItems;
  List<TSelectItem<V>> get filteredItems => _filteredItems;
  String get searchQuery => _searchQuery;
  double get scrollPosition => _scrollPosition;

  void updateItems(List<T> items) {
    _internalItems = items.map(_convertToSelectItem).toList();
    _applyFiltering();
  }

  void updateFilteredItems(List<T> items) {
    _filteredItems = items.map(_convertToSelectItem).toList();

    // Preserve selection states from internal items
    _preserveSelectionStates();

    filteredItemsNotifier.value = List.from(_filteredItems);
    notifyListeners();
  }

  void _preserveSelectionStates() {
    for (final filteredItem in _filteredItems) {
      final internalItem = _findItemByKey(_internalItems, filteredItem.key);
      if (internalItem != null) {
        filteredItem.selected = internalItem.selected;
        filteredItem.expanded = internalItem.expanded;
      }
    }
  }

  TSelectItem<V>? _findItemByKey(List<TSelectItem<V>> items, String key) {
    for (final item in items) {
      if (item.key == key) return item;
      if (item.hasChildren) {
        final found = _findItemByKey(item.children!, key);
        if (found != null) return found;
      }
    }
    return null;
  }

  void updateSelectedStates(List<V> selectedValues) {
    _updateSelectedStatesRecursive(_internalItems, selectedValues);
    _updateSelectedStatesRecursive(_filteredItems, selectedValues);
    filteredItemsNotifier.value = List.from(_filteredItems);
    notifyListeners();
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
    _searchQuery = query;
    searchQueryNotifier.value = query;
    _applyFiltering();
  }

  void _applyFiltering() {
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_internalItems);
    } else {
      _filteredItems = _internalItems.where((item) {
        return _itemMatchesQuery(item, _searchQuery.toLowerCase());
      }).toList();
    }

    filteredItemsNotifier.value = List.from(_filteredItems);
    notifyListeners();
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
    // Handle hierarchical expansion
    if (item.hasChildren) {
      item.expanded = !item.expanded;
      _syncItemStates(item);
      filteredItemsNotifier.value = List.from(_filteredItems);
      notifyListeners();
      return;
    }

    // Handle selection
    if (isMultiple) {
      item.selected = !item.selected;
    } else {
      _clearAllSelections(_internalItems);
      _clearAllSelections(_filteredItems);
      item.selected = true;
    }

    _syncItemStates(item);
    filteredItemsNotifier.value = List.from(_filteredItems);
    notifyListeners();
  }

  void _syncItemStates(TSelectItem<V> item) {
    // Sync state between internal and filtered items
    final internalItem = _findItemByKey(_internalItems, item.key);
    if (internalItem != null) {
      internalItem.selected = item.selected;
      internalItem.expanded = item.expanded;
    }

    final filteredItem = _findItemByKey(_filteredItems, item.key);
    if (filteredItem != null && filteredItem != item) {
      filteredItem.selected = item.selected;
      filteredItem.expanded = item.expanded;
    }
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
    filteredItemsNotifier.dispose();
    searchQueryNotifier.dispose();
    scrollPositionNotifier.dispose();
    super.dispose();
  }
}
