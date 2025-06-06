import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/select/select_dropdown.dart';
import 'package:te_widgets/widgets/text-field/text_field.dart';
import 'package:te_widgets/widgets/text-field/text_field_mixin.dart';
import 'package:te_widgets/widgets/text-field/validation_mixin.dart';

class TSelect<V> extends StatefulWidget with TTextFieldMixin, TValidationMixin<V> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool? required, disabled;
  @override
  final TTextFieldSize? size;
  @override
  final TTextFieldColor? color;
  @override
  final BoxDecoration? boxDecoration;
  @override
  final List<String Function(V?)>? rules;

  final List<TSelectItem<V>> items;
  final List<V>? selectedValues;
  final V? selectedValue;
  final bool multiple, multiLevel, filterable;
  final double dropdownMaxHeight;
  final String? footerMessage;
  final ValueChanged<List<V>>? onMultipleChanged;
  final ValueChanged<V?>? onSingleChanged;
  final VoidCallback? onExpanded;
  final VoidCallback? onCollapsed;

  const TSelect({
    super.key,
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.required,
    this.disabled,
    this.size,
    this.color,
    this.boxDecoration,
    this.rules,
    required this.items,
    this.selectedValues,
    this.selectedValue,
    this.multiple = false,
    this.multiLevel = false,
    this.filterable = true,
    this.dropdownMaxHeight = 200.0,
    this.footerMessage,
    this.onMultipleChanged,
    this.onSingleChanged,
    this.onExpanded,
    this.onCollapsed,
  });

  @override
  State<TSelect<V>> createState() => _TSelectState<V>();
}

class _TSelectState<V> extends State<TSelect<V>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late List<TSelectItem<V>> _items;
  List<TSelectItem<V>> _filteredItems = [];
  bool _isExpanded = false;
  String _searchQuery = '';
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounce;

  bool _openUpward = false;
  final GlobalKey _selectKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _items = List.from(widget.items);
    _updateSelectedStates();
    _filteredItems = List.from(_items);
    _updateDisplayText();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.filterable) {
        _showDropdown();
      }
    });
  }

  @override
  void didUpdateWidget(TSelect<V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _items = List.from(widget.items);
      _updateSelectedStates();
      _filterItems(_searchQuery);
    }
    if (widget.selectedValue != oldWidget.selectedValue || widget.selectedValues != oldWidget.selectedValues) {
      _updateSelectedStates();
      _updateDisplayText();

      if (_isExpanded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _overlayEntry != null) {
            _rebuildDropdown();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _hideDropdown();
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterItems(value);
    });
  }

  void _updateSelectedStates() {
    if (widget.multiple) {
      final selectedValues = widget.selectedValues ?? [];
      for (final item in _items) {
        item.selected = selectedValues.contains(item.value);
        if (item is TMultiLevelSelectItem<V> && item.hasChildren) {
          _updateChildrenSelection(item, selectedValues);
        }
      }
    } else {
      for (final item in _items) {
        item.selected = item.value == widget.selectedValue;
        if (item is TMultiLevelSelectItem<V> && item.hasChildren) {
          _updateChildrenSelection(item, widget.selectedValue != null ? [widget.selectedValue!] : []);
        }
      }
    }

    _autoExpandParentsWithSelectedChildren();
  }

  void _autoExpandParentsWithSelectedChildren() {
    void expandIfHasSelectedChildren(List<TSelectItem<V>> items) {
      for (final item in items) {
        if (item is TMultiLevelSelectItem<V> && item.hasChildren) {
          bool hasSelectedChild = _hasSelectedChildRecursive(item);
          if (hasSelectedChild) {
            item.expanded = true;
          }

          expandIfHasSelectedChildren(item.items!);
        }
      }
    }

    expandIfHasSelectedChildren(_items);
  }

  bool _hasSelectedChildRecursive(TMultiLevelSelectItem<V> parent) {
    if (!parent.hasChildren) return false;

    for (final child in parent.items!) {
      if (child.selected) return true;
      if (child.hasChildren) {
        if (_hasSelectedChildRecursive(child)) return true;
      }
    }
    return false;
  }

  void _updateChildrenSelection(TMultiLevelSelectItem<V> parent, List<V> selectedValues) {
    if (!parent.hasChildren) return;

    for (final child in parent.items!) {
      child.selected = selectedValues.contains(child.value);
      if (child.hasChildren) {
        _updateChildrenSelection(child, selectedValues);
      }
    }
  }

  void _updateDisplayText() {
    if (widget.multiple) {
      _controller.text = '';
    } else {
      final selectedItem = _getSelectedItems().isNotEmpty ? _getSelectedItems().first : null;
      _controller.text = selectedItem?.text ?? '';
    }
  }

  List<TSelectItem<V>> _getSelectedItems() {
    List<TSelectItem<V>> selected = [];

    void collectSelected(List<TSelectItem<V>> items) {
      for (final item in items) {
        if (item.selected) {
          selected.add(item);
        }
        if (item is TMultiLevelSelectItem<V> && item.hasChildren) {
          collectSelected(item.items!);
        }
      }
    }

    collectSelected(_items);
    return selected;
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredItems = List.from(_items);
      } else {
        _filteredItems = _items.where((item) {
          return _itemMatchesQuery(item, query.toLowerCase());
        }).toList();
      }
    });

    if (_isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _overlayEntry != null) {
          _rebuildDropdown();
        }
      });
    }
  }

  bool _itemMatchesQuery(TSelectItem<V> item, String query) {
    if (item.text.toLowerCase().contains(query)) {
      return true;
    }

    if (item is TMultiLevelSelectItem<V> && item.hasChildren) {
      return item.items!.any((child) => _itemMatchesQuery(child, query));
    }

    return false;
  }

  void _onItemTap(TSelectItem<V> item) {
    if (item is TMultiLevelSelectItem<V> && item.hasChildren) {
      setState(() {
        item.expanded = !item.expanded;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _overlayEntry != null) {
          _rebuildDropdown();
        }
      });
      return;
    }

    setState(() {
      if (widget.multiple) {
        item.selected = !item.selected;
        widget.onMultipleChanged?.call(_getSelectedItems().map((item) => item.value).toList());
      } else {
        for (final item in _items) {
          item.selected = false;
          if (item is TMultiLevelSelectItem<V> && item.hasChildren) {
            _clearChildrenSelection(item);
          }
        }

        item.selected = true;
        widget.onSingleChanged?.call(item.value);
        _hideDropdown();
      }

      _updateDisplayText();
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    });

    if (widget.multiple) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _overlayEntry != null) {
          _rebuildDropdown();
        }
      });
    }
  }

  void _clearChildrenSelection(TMultiLevelSelectItem<V> parent) {
    if (!parent.hasChildren) return;

    for (final child in parent.items!) {
      child.selected = false;
      if (child.hasChildren) {
        _clearChildrenSelection(child);
      }
    }
  }

  void _calculatePosition() {
    final RenderBox? renderBox = _selectKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    final spaceBelow = screenHeight - (position.dy + size.height);
    final spaceAbove = position.dy;

    final dropdownHeight = math.min(widget.dropdownMaxHeight, _calculateDropdownHeight());

    _openUpward = spaceBelow < dropdownHeight && spaceAbove > dropdownHeight;
  }

  double _calculateDropdownHeight() {
    const itemHeight = 34.0;
    const padding = 16.0;

    int visibleItemCount = _countVisibleItems(_filteredItems);
    return math.min(visibleItemCount * itemHeight + padding, widget.dropdownMaxHeight);
  }

  int _countVisibleItems(List<TSelectItem<V>> items) {
    int count = 0;
    for (final item in items) {
      count++;
      if (item is TMultiLevelSelectItem<V> && item.hasChildren && item.expanded) {
        count += _countVisibleItems(item.items!);
      }
    }
    return count;
  }

  String _displayTextBeforeExpansion = '';
  void _showDropdown() {
    if (_overlayEntry != null || widget.disabled == true) return;

    _displayTextBeforeExpansion = _controller.text;
    _controller.clear();
    _searchQuery = '';
    _filterItems('');
    _focusNode.requestFocus();

    _calculatePosition();

    setState(() {
      _isExpanded = true;
    });

    widget.onExpanded?.call();

    _createOverlay();
  }

  void _rebuildDropdown() {
    if (_overlayEntry == null || !mounted) return;

    _overlayEntry?.remove();
    _overlayEntry = null;

    _createOverlay();
  }

  void _createOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _hideDropdown,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: _getDropdownWidth(),
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: _openUpward ? Offset(0, -_calculateDropdownHeight() - 8) : Offset(0, 38 + 8 + 8 + 8),
              child: TSelectDropdown<V>(
                key: ValueKey('dropdown_${_filteredItems.hashCode}_${DateTime.now().millisecondsSinceEpoch}'),
                items: _filteredItems,
                maxHeight: widget.dropdownMaxHeight,
                onItemTap: (item) {
                  _onItemTap(item);
                },
                footerMessage: widget.footerMessage,
                multiple: widget.multiple,
              ),
            ),
          ),
        ],
      ),
    );

    Navigator.of(context, rootNavigator: true).overlay!.insert(_overlayEntry!);
  }

  void _hideDropdown() {
    if (_overlayEntry == null) return;

    _controller.text = _displayTextBeforeExpansion;
    _searchQuery = '';
    _filterItems('');

    setState(() {
      _isExpanded = false;
    });

    widget.onCollapsed?.call();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getDropdownWidth() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 200;
  }

  List<String> _getSelectedTags() {
    if (!widget.multiple) return [];
    return _getSelectedItems().map((item) => item.text).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _selectKey,
        onTap: widget.disabled == true
            ? null
            : () {
                if (_isExpanded) {
                  _hideDropdown();
                } else {
                  _showDropdown();
                }
              },
        child: TTextField(
          focusNode: _focusNode,
          label: widget.label,
          tag: widget.tag,
          placeholder: widget.placeholder,
          helperText: widget.helperText,
          message: widget.message,
          required: widget.required,
          //disabled: widget.disabled == true || !_isExpanded,
          size: widget.size,
          color: widget.color,
          controller: _controller,
          value: _isExpanded ? _searchQuery : _controller.text,
          tags: widget.multiple ? _getSelectedTags() : null,
          postWidget: Icon(
            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 16,
            color: Colors.grey.shade500,
          ),
          onChanged: widget.filterable && _isExpanded ? _onSearchChanged : null,
          boxDecoration: BoxDecoration(color: widget.disabled == true ? AppColors.grey.shade50 : Colors.white),
        ),
      ),
    );
  }
}
