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
  List<TSelectItem<V>> _displayItems = [];
  String _searchQuery = '';
  double _scrollPosition = 0.0;

  // Notifiers for reactive updates
  final ValueNotifier<List<TSelectItem<V>>> displayItemsNotifier = ValueNotifier([]);
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
  List<TSelectItem<V>> get displayItems => _displayItems;
  String get searchQuery => _searchQuery;
  double get scrollPosition => _scrollPosition;

  /// Updates all items (used for local pagination)
  void updateItems(List<T> items) {
    _internalItems = items.map(_convertToSelectItem).toList();
    _displayItems = List.from(_internalItems);
    _preserveSelectionStates();
    displayItemsNotifier.value = List.from(_displayItems);
    notifyListeners();
  }

  /// Updates display items (used for server-side pagination)
  void updateDisplayItems(List<T> items, {bool append = false}) {
    final newSelectItems = items.map(_convertToSelectItem).toList();

    if (append) {
      _displayItems.addAll(newSelectItems);
    } else {
      _displayItems = newSelectItems;
    }

    _preserveSelectionStates();
    displayItemsNotifier.value = List.from(_displayItems);
    notifyListeners();
  }

  /// Preserves selection states between internal and display items
  void _preserveSelectionStates() {
    for (final displayItem in _displayItems) {
      final internalItem = _findItemByKey(_internalItems, displayItem.key);
      if (internalItem != null) {
        displayItem.selected = internalItem.selected;
        displayItem.expanded = internalItem.expanded;
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

  /// Updates selected states for all items
  void updateSelectedStates(List<V> selectedValues) {
    _updateSelectedStatesRecursive(_internalItems, selectedValues);
    _updateSelectedStatesRecursive(_displayItems, selectedValues);
    displayItemsNotifier.value = List.from(_displayItems);
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

  /// Handles local search filtering (only used when pagination is local)
  void onLocalSearchChanged(String query) {
    _searchQuery = query;
    searchQueryNotifier.value = query;
    _applyLocalFiltering();
  }

  void _applyLocalFiltering() {
    if (_searchQuery.isEmpty) {
      _displayItems = List.from(_internalItems);
    } else {
      _displayItems = _internalItems.where((item) {
        return _itemMatchesQuery(item, _searchQuery.toLowerCase());
      }).toList();
    }

    displayItemsNotifier.value = List.from(_displayItems);
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

  /// Handles item tap (selection/expansion)
  void onItemTapped(TSelectItem<V> item) {
    // Handle hierarchical expansion
    if (item.hasChildren) {
      item.expanded = !item.expanded;
      _syncItemStates(item);
      displayItemsNotifier.value = List.from(_displayItems);
      notifyListeners();
      return;
    }

    // Handle selection
    if (isMultiple) {
      item.selected = !item.selected;
    } else {
      _clearAllSelections(_internalItems);
      _clearAllSelections(_displayItems);
      item.selected = true;
    }

    _syncItemStates(item);
    displayItemsNotifier.value = List.from(_displayItems);
    notifyListeners();
  }

  void _syncItemStates(TSelectItem<V> item) {
    // Sync state between internal and display items
    final internalItem = _findItemByKey(_internalItems, item.key);
    if (internalItem != null) {
      internalItem.selected = item.selected;
      internalItem.expanded = item.expanded;
    }

    final displayItem = _findItemByKey(_displayItems, item.key);
    if (displayItem != null && displayItem != item) {
      displayItem.selected = item.selected;
      displayItem.expanded = item.expanded;
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

  /// Updates scroll position
  void updateScrollPosition(double position) {
    _scrollPosition = position;
    scrollPositionNotifier.value = position;
  }

  /// Gets all selected items
  List<TSelectItem<V>> getSelectedItems() {
    List<TSelectItem<V>> selectedItems = [];
    _collectSelectedItems(_displayItems, selectedItems);
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

  /// Counts visible items in the tree
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

  /// Converts raw items to TSelectItem
  TSelectItem<V> _convertToSelectItem(T item) {
    assert(V != Null, 'Select labeled "$label": value type can not be Null.');

    switch (item) {
      case TSelectItem<V> i:
        return i;
      case TSelectRecord<V> record:
        return TSelectItem<V>.fromRecord(record);
      case String s:
        return TSelectItem<V>.simple(s, s as V, s);
      case int i:
        final text = i.toString();
        return TSelectItem<V>.simple(text, i as V, text);
      case double d:
        final text = d.toString();
        return TSelectItem<V>.simple(text, d as V, text);
      case bool b:
        final text = b.toString();
        return TSelectItem<V>.simple(text, b as V, text);
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
    displayItemsNotifier.dispose();
    searchQueryNotifier.dispose();
    scrollPositionNotifier.dispose();
    super.dispose();
  }
}
