import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/select/select_dropdown.dart';

/// Common functionality for TSelect and TMultiSelect widgets
mixin TSelectCommonMixin<T extends StatefulWidget> on State<T> {
  // Common properties - to be overridden by implementing classes
  List<TSelectItem> get items;
  bool get filterable;
  bool get multiLevel;
  double get dropdownMaxHeight;
  String? get footerMessage;
  bool get isDisabled;
  VoidCallback? get onExpanded;
  VoidCallback? get onCollapsed;

  // Abstract methods to be implemented by subclasses
  void onItemTapped(TSelectItem item);
  bool get isMultiple;

  // Common state
  late List<TSelectItem> internalItems;
  List<TSelectItem> filteredItems = [];
  bool isExpanded = false;
  String searchQuery = '';
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;
  Timer? debounce;
  bool openUpward = false;
  final GlobalKey selectKey = GlobalKey();

  // Initialize common functionality
  void initializeCommon() {
    internalItems = List.from(items);
    updateSelectedStates();
    filteredItems = List.from(internalItems);
  }

  // Clean up common resources
  void disposeCommon() {
    hideDropdown();
    debounce?.cancel();
  }

  // Update widget when items change
  void didUpdateItems(List<TSelectItem> oldItems) {
    if (items != oldItems) {
      internalItems = List.from(items);
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
  bool itemMatchesQuery(TSelectItem item, String query) {
    if (item.text.toLowerCase().contains(query)) {
      return true;
    }

    if (item is TMultiLevelSelectItem && item.hasChildren) {
      return item.items!.any((child) => itemMatchesQuery(child, query));
    }

    return false;
  }

  // Handle item tap with common logic
  void handleItemTap(TSelectItem item) {
    if (item is TMultiLevelSelectItem && item.hasChildren) {
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
    if (!multiLevel) return;

    void expandIfHasSelectedChildren(List<TSelectItem> items) {
      for (final item in items) {
        if (item is TMultiLevelSelectItem && item.hasChildren) {
          bool hasSelectedChild = hasSelectedChildRecursive(item);
          if (hasSelectedChild) {
            item.expanded = true;
          }
          expandIfHasSelectedChildren(item.items!);
        }
      }
    }

    expandIfHasSelectedChildren(internalItems);
  }

  // Check if parent has selected children recursively
  bool hasSelectedChildRecursive(TMultiLevelSelectItem parent) {
    if (!parent.hasChildren) return false;

    for (final child in parent.items!) {
      if (child.selected) return true;
      if (child.hasChildren) {
        if (hasSelectedChildRecursive(child)) return true;
      }
    }
    return false;
  }

  // Update children selection state
  void updateChildrenSelection(TMultiLevelSelectItem parent, List selectedValues) {
    if (!parent.hasChildren) return;

    for (final child in parent.items!) {
      child.selected = selectedValues.contains(child.value);
      if (child.hasChildren) {
        updateChildrenSelection(child, selectedValues);
      }
    }
  }

  // Clear children selection
  void clearChildrenSelection(TMultiLevelSelectItem parent) {
    if (!parent.hasChildren) return;

    for (final child in parent.items!) {
      child.selected = false;
      if (child.hasChildren) {
        clearChildrenSelection(child);
      }
    }
  }

  // Calculate dropdown position
  void calculatePosition() {
    final RenderBox? renderBox = selectKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    final spaceBelow = screenHeight - (position.dy + size.height);
    final spaceAbove = position.dy;

    final dropdownHeight = math.min(dropdownMaxHeight, calculateDropdownHeight());

    openUpward = spaceBelow < dropdownHeight && spaceAbove > dropdownHeight;
  }

  // Calculate dropdown height based on visible items
  double calculateDropdownHeight() {
    const itemHeight = 34.0;
    const padding = 16.0;

    int visibleItemCount = countVisibleItems(filteredItems);
    return math.min(visibleItemCount * itemHeight + padding, dropdownMaxHeight);
  }

  // Count visible items including expanded children
  int countVisibleItems(List<TSelectItem> items) {
    int count = 0;
    for (final item in items) {
      count++;
      if (item is TMultiLevelSelectItem && item.hasChildren && item.expanded) {
        count += countVisibleItems(item.items!);
      }
    }
    return count;
  }

  // Show dropdown
  void showDropdown() {
    if (overlayEntry != null || isDisabled) return;

    searchQuery = '';
    filterItems('');

    calculatePosition();

    setState(() {
      isExpanded = true;
    });

    onExpanded?.call();
    createOverlay();
  }

  // Hide dropdown
  void hideDropdown() {
    if (overlayEntry == null) return;

    searchQuery = '';
    filterItems('');

    setState(() {
      isExpanded = false;
    });

    onCollapsed?.call();
    overlayEntry?.remove();
    overlayEntry = null;
  }

  // Rebuild dropdown
  void rebuildDropdown() {
    if (overlayEntry == null || !mounted) return;

    overlayEntry?.remove();
    overlayEntry = null;

    createOverlay();
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
              offset: openUpward ? Offset(0, -calculateDropdownHeight() - 8) : Offset(0, 38 + 8 + 8 + 8),
              child: TSelectDropdown(
                key: ValueKey('dropdown_${filteredItems.hashCode}_${DateTime.now().millisecondsSinceEpoch}'),
                items: filteredItems,
                maxHeight: dropdownMaxHeight,
                onItemTap: handleItemTap,
                footerMessage: footerMessage,
                multiple: isMultiple,
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
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 200;
  }

  // Toggle dropdown
  void toggleDropdown() {
    if (isDisabled) return;

    if (isExpanded) {
      hideDropdown();
    } else {
      showDropdown();
    }
  }
}

/// Helper class to collect selected items
class TSelectItemCollector {
  static List<TSelectItem> getSelectedItems(List<TSelectItem> items) {
    List<TSelectItem> selected = [];

    void collectSelected(List<TSelectItem> items) {
      for (final item in items) {
        if (item.selected) {
          selected.add(item);
        }
        if (item is TMultiLevelSelectItem && item.hasChildren) {
          collectSelected(item.items!);
        }
      }
    }

    collectSelected(items);
    return selected;
  }

  static void clearAllSelections(List<TSelectItem> items) {
    for (final item in items) {
      item.selected = false;
      if (item is TMultiLevelSelectItem && item.hasChildren) {
        clearAllSelections(item.items!);
      }
    }
  }
}

/// Configuration class for select widgets
class TSelectConfig {
  final String? label;
  final String? tag;
  final String? placeholder;
  final String? helperText;
  final String? message;
  final bool? isRequired;
  final bool? disabled;
  final TInputSize? size;
  final TInputColor? color;
  final BoxDecoration? boxDecoration;
  final Widget? preWidget;
  final Widget? postWidget;
  final FocusNode? focusNode;
  final bool multiLevel;
  final bool filterable;
  final double dropdownMaxHeight;
  final String? footerMessage;
  final VoidCallback? onExpanded;
  final VoidCallback? onCollapsed;

  const TSelectConfig({
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.isRequired,
    this.disabled,
    this.size,
    this.color,
    this.boxDecoration,
    this.preWidget,
    this.postWidget,
    this.focusNode,
    this.multiLevel = false,
    this.filterable = false,
    this.dropdownMaxHeight = 200,
    this.footerMessage,
    this.onExpanded,
    this.onCollapsed,
  });
}
