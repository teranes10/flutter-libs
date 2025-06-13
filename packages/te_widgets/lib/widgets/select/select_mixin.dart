// select_mixin.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/select/select_dropdown.dart';

mixin TSelectMixin<T, V> on TInputFieldMixin {
  List<T> get items;
  bool get multiLevel;
  bool get filterable;
  double get dropdownMaxHeight;
  String? get footerMessage;
  VoidCallback? get onExpanded;
  VoidCallback? get onCollapsed;

  ItemTextAccessor<T>? get itemText;
  ItemValueAccessor<T, V>? get itemValue;
  ItemKeyAccessor<T>? get itemKey;
  ItemChildrenAccessor<T>? get itemChildren;
}

mixin TSelectStateMixin<T, V, W extends StatefulWidget> on State<W> {
  TSelectMixin<T, V> get _widget => widget as TSelectMixin<T, V>;

  void onItemTapped(TSelectItem<V> item);
  bool get isMultiple;

  late List<TSelectItem<V>> internalItems;
  List<TSelectItem<V>> filteredItems = [];
  bool isExpanded = false;
  String searchQuery = '';
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;
  Timer? debounce;
  bool openUpward = false;
  final GlobalKey selectKey = GlobalKey();

  // Scroll position preservation
  double _scrollPosition = 0.0;

  // Initialize common functionality
  void initializeCommon() {
    internalItems = _widget.items.map((x) => _convertToSelectItem(x)).toList();
    updateSelectedStates();
    filteredItems = List.from(internalItems);
  }

  // Clean up common resources
  void disposeCommon() {
    hideDropdown();
    debounce?.cancel();
  }

  // Update widget when items change
  void didUpdateItems(List<T> oldItems) {
    if (_widget.items != oldItems) {
      internalItems = _widget.items.map((x) => _convertToSelectItem(x)).toList();
      updateSelectedStates();
      filterItems(searchQuery);
    }
  }

  // Search with debounce
  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      filterItems(value);
    });
  }

  // Abstract method to be implemented by subclasses
  void updateSelectedStates();

  // Filter items based on search query
  void filterItems(String query) {
    if (!mounted) return;

    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredItems = List.from(internalItems);
      } else {
        filteredItems = internalItems.where((item) {
          return itemMatchesQuery(item, query.toLowerCase());
        }).toList();
      }
    });

    if (isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && overlayEntry != null) {
          rebuildDropdown();
        }
      });
    }
  }

  // Check if item matches search query
  bool itemMatchesQuery(TSelectItem<V> item, String query) {
    if (item.text.toLowerCase().contains(query)) {
      return true;
    }

    if (item.hasChildren) {
      return item.children!.any((child) => itemMatchesQuery(child, query));
    }

    return false;
  }

  // Handle item tap with common logic
  void handleItemTap(TSelectItem<V> item) {
    if (item.hasChildren) {
      setState(() {
        item.expanded = !item.expanded;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && overlayEntry != null) {
          rebuildDropdown();
        }
      });
      return;
    }

    onItemTapped(item);
  }

  // Auto-expand parents with selected children (for multi-level)
  void autoExpandParentsWithSelectedChildren() {
    if (!_widget.multiLevel) return;

    void expandIfHasSelectedChildren(List<TSelectItem<V>> items) {
      for (final item in items) {
        if (item.hasChildren) {
          bool hasSelectedChild = hasSelectedChildRecursive(item);
          if (hasSelectedChild) {
            item.expanded = true;
          }
          expandIfHasSelectedChildren(item.children!);
        }
      }
    }

    expandIfHasSelectedChildren(internalItems);
  }

  // Check if parent has selected children recursively
  bool hasSelectedChildRecursive(TSelectItem<V> parent) {
    if (!parent.hasChildren) return false;

    for (final child in parent.children!) {
      if (child.selected) return true;
      if (child.hasChildren) {
        if (hasSelectedChildRecursive(child)) return true;
      }
    }
    return false;
  }

  // Update children selection state
  void updateChildrenSelection(TSelectItem<V> parent, List selectedValues) {
    if (!parent.hasChildren) return;

    for (final child in parent.children!) {
      child.selected = selectedValues.contains(child.value);
      if (child.hasChildren) {
        updateChildrenSelection(child, selectedValues);
      }
    }
  }

  // Clear children selection
  void clearChildrenSelection(TSelectItem<V> parent) {
    if (!parent.hasChildren) return;

    for (final child in parent.children!) {
      child.selected = false;
      if (child.hasChildren) {
        clearChildrenSelection(child);
      }
    }
  }

  // Calculate dropdown position based on container bounds
  void calculatePosition() {
    final RenderBox? renderBox = selectKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    final spaceBelow = screenHeight - (position.dy + size.height);
    final spaceAbove = position.dy;

    final dropdownHeight = math.min(_widget.dropdownMaxHeight, calculateDropdownHeight());

    openUpward = spaceBelow < dropdownHeight && spaceAbove > dropdownHeight;
  }

  // Calculate dropdown height based on visible items
  double calculateDropdownHeight() {
    const itemHeight = 34.0;
    const padding = 16.0;

    int visibleItemCount = countVisibleItems(filteredItems);
    return math.min(visibleItemCount * itemHeight + padding, _widget.dropdownMaxHeight);
  }

  // Count visible items including expanded children
  int countVisibleItems(List<TSelectItem> items) {
    int count = 0;
    for (final item in items) {
      count++;
      if (item.hasChildren && item.expanded) {
        count += countVisibleItems(item.children!);
      }
    }
    return count;
  }

  // Get container height for proper dropdown positioning
  double getContainerHeight() {
    final RenderBox? renderBox = selectKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 38;
  }

  // Show dropdown
  void showDropdown() {
    if (overlayEntry != null || _widget.disabled == true) return;

    searchQuery = '';
    filterItems('');
    _scrollPosition = 0.0; // Reset scroll position when opening

    calculatePosition();

    setState(() {
      isExpanded = true;
    });

    _widget.onExpanded?.call();
    createOverlay();
  }

  // Hide dropdown
  void hideDropdown() {
    if (overlayEntry == null) return;

    searchQuery = '';
    filterItems('');
    _scrollPosition = 0.0; // Reset scroll position when closing

    setState(() {
      isExpanded = false;
    });

    _widget.onCollapsed?.call();
    overlayEntry?.remove();
    overlayEntry = null;
  }

  // Rebuild dropdown with preserved scroll position
  void rebuildDropdown() {
    if (overlayEntry == null || !mounted) return;

    overlayEntry?.remove();
    overlayEntry = null;

    createOverlay();
  }

  // Handle scroll position changes
  void onScrollPositionChanged(double position) {
    _scrollPosition = position;
  }

  // Create overlay entry
  void createOverlay() {
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: hideDropdown,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: getDropdownWidth(),
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: openUpward ? Offset(0, -calculateDropdownHeight() - 8) : Offset(0, getContainerHeight() + 8), // Use actual container height
              child: TSelectDropdown(
                key: ValueKey('dropdown_${filteredItems.hashCode}_${DateTime.now().millisecondsSinceEpoch}'),
                items: filteredItems,
                maxHeight: _widget.dropdownMaxHeight,
                onItemTap: handleItemTap,
                footerMessage: _widget.footerMessage,
                multiple: isMultiple,
                scrollPosition: _scrollPosition,
                onScrollPositionChanged: onScrollPositionChanged,
              ),
            ),
          ),
        ],
      ),
    );

    Navigator.of(context, rootNavigator: true).overlay!.insert(overlayEntry!);
  }

  // Get dropdown width
  double getDropdownWidth() {
    final RenderBox? renderBox = selectKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 200;
  }

  // Toggle dropdown
  void toggleDropdown() {
    if (_widget.disabled == true) return;

    if (isExpanded) {
      hideDropdown();
    } else {
      showDropdown();
    }
  }

  TSelectItem<V> _convertToSelectItem(T item) {
    assert(V != Null, 'Select labeled "${_widget.label}": value type can not be Null.');

    switch (item) {
      // Already a TSelectItem
      case TSelectItem<V> i:
        return i;

      // Record support
      case TSelectRecord<V> record:
        return TSelectItem<V>.fromRecord(record);

      // String
      case String s when V == String:
        return TSelectItem<V>.simple(s, s as V, s);

      // int
      case int i when V == int:
        final text = i.toString();
        return TSelectItem<V>.simple(text, i as V, text);

      // double
      case double d when V == double:
        final text = d.toString();
        return TSelectItem<V>.simple(text, d as V, text);

      // bool
      case bool b when V == bool:
        final text = b.toString();
        return TSelectItem<V>.simple(text, b as V, text);

      // num
      case num n when V == num:
        final text = n.toString();
        return TSelectItem<V>.simple(text, n as V, text);

      // Default / custom object
      default:
        final text = _widget.itemText?.call(item);
        final value = _widget.itemValue != null ? _widget.itemValue!.call(item) : item;
        final key = _widget.itemKey?.call(item);
        final children = _widget.itemChildren?.call(item);

        assert(
          text != null,
          'Select labeled "${_widget.label}": For custom item "$item", `itemText` must not return null.',
        );

        assert(
          value is V,
          'Select labeled "${_widget.label}": `itemValue` result is not of type $V. Got: ${value.runtimeType} from item "$item".',
        );

        return TSelectItem<V>(
          text: text!,
          value: value as V,
          key: key,
          children: children?.map(_convertToSelectItem).toList(),
        );
    }
  }
}
