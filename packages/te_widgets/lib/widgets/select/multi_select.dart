import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/mixins/focus_mixin.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/mixins/input_validation_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/select/select_mixin.dart';
import 'package:te_widgets/widgets/tags-field/tags_field.dart';

class TMultiSelect<T, V> extends StatefulWidget
    with TInputFieldMixin, TInputValueMixin<List<V>>, TFocusMixin, TInputValidationMixin<List<V>>, TSelectMixin<T, V> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool? isRequired, disabled;
  @override
  final TInputSize? size;
  @override
  final TInputColor? color;
  @override
  final BoxDecoration? boxDecoration;
  @override
  final Widget? preWidget, postWidget;
  @override
  final List<String? Function(List<V>?)>? rules;
  @override
  final List<String>? errors;
  @override
  final Duration? validationDebounce;
  @override
  final bool? skipValidation;
  @override
  final List<V>? value;
  @override
  final ValueNotifier<List<V>>? valueNotifier;
  @override
  final ValueChanged<List<V>>? onValueChanged;
  @override
  final FocusNode? focusNode;

  @override
  final List<T> items;
  @override
  final bool multiLevel, filterable;
  @override
  final double dropdownMaxHeight;
  @override
  final String? footerMessage;
  @override
  final VoidCallback? onExpanded;
  @override
  final VoidCallback? onCollapsed;

  @override
  final ItemTextAccessor<T>? itemText;
  @override
  final ItemValueAccessor<T, V>? itemValue;
  @override
  final ItemKeyAccessor<T>? itemKey;
  @override
  final ItemChildrenAccessor<T>? itemChildren;

  const TMultiSelect({
    super.key,
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
    this.rules,
    this.errors,
    this.validationDebounce,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.focusNode,
    required this.items,
    this.multiLevel = false,
    this.filterable = true,
    this.dropdownMaxHeight = 200,
    this.footerMessage,
    this.onExpanded,
    this.onCollapsed,
    this.skipValidation,
    this.itemText,
    this.itemValue,
    this.itemKey,
    this.itemChildren,
  });

  @override
  State<TMultiSelect<T, V>> createState() => _TMultiSelectState<T, V>();
}

class _TMultiSelectState<T, V> extends State<TMultiSelect<T, V>>
    with
        TInputValueStateMixin<List<V>, TMultiSelect<T, V>>,
        TFocusStateMixin<TMultiSelect<T, V>>,
        TInputValidationStateMixin<List<V>, TMultiSelect<T, V>>,
        TSelectStateMixin<T, V, TMultiSelect<T, V>> {
  late TextEditingController _controller;

  @override
  bool get isMultiple => true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    // Initialize common functionality
    initializeCommon();
  }

  @override
  void didUpdateWidget(TMultiSelect<T, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    didUpdateItems(oldWidget.items);

    if (widget.value != oldWidget.value) {
      updateSelectedStates();

      if (isExpanded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && overlayEntry != null) {
            rebuildDropdown();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    disposeCommon();
    _controller.dispose();
    super.dispose();
  }

  @override
  void onFocusChanged(bool hasFocus) {
    super.onFocusChanged(hasFocus);

    if (hasFocus && widget.filterable) {
      _showDropdownWithSearch();
    }
  }

  @override
  void updateSelectedStates() {
    final selectedValues = widget.value ?? <V>[];
    for (final item in internalItems) {
      item.selected = selectedValues.contains(item.value);
      if (item.hasChildren) {
        updateChildrenSelection(item, selectedValues);
      }
    }
    autoExpandParentsWithSelectedChildren();
  }

  @override
  void onItemTapped(TSelectItem<V> item) {
    setState(() {
      item.selected = !item.selected;
      final selectedItems = TSelectItemCollector.getSelectedItems(internalItems);
      final selectedValues = selectedItems.map((item) => item.value as V).toList();
      notifyValueChanged(selectedValues);
    });

    // Keep dropdown open and rebuild to show updated selections
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && overlayEntry != null) {
        rebuildDropdown();
      }
    });
  }

  void _showDropdownWithSearch() {
    _controller.clear();
    focusNode.requestFocus();
    showDropdown();
  }

  @override
  void hideDropdown() {
    if (overlayEntry == null) return;

    _controller.clear();
    super.hideDropdown();
  }

  List<String> _getSelectedTags() {
    final selectedItems = TSelectItemCollector.getSelectedItems(internalItems);
    return selectedItems.map((item) => item.text).toList();
  }

  void _onTagRemoved(String tag) {
    final selectedItems = TSelectItemCollector.getSelectedItems(internalItems);
    final itemToRemove = selectedItems.firstWhere(
      (item) => item.text == tag,
      orElse: () => selectedItems.first, // fallback, shouldn't happen
    );

    setState(() {
      itemToRemove.selected = false;
      final remainingSelectedItems = TSelectItemCollector.getSelectedItems(internalItems);
      final selectedValues = remainingSelectedItems.map((item) => item.value as V).toList();
      notifyValueChanged(selectedValues);
    });

    // Rebuild dropdown if it's open
    if (isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && overlayEntry != null) {
          rebuildDropdown();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: GestureDetector(
        key: selectKey,
        onTap: toggleDropdown,
        child: TTagsField(
          skipValidation: true,
          focusNode: focusNode,
          label: widget.label,
          tag: widget.tag,
          placeholder: widget.placeholder,
          helperText: widget.helperText,
          message: widget.message,
          isRequired: widget.isRequired,
          disabled: widget.disabled == true,
          readOnly: !widget.filterable,
          size: widget.size,
          color: widget.color,
          controller: _controller,
          inputValue: isExpanded && widget.filterable ? searchQuery : '',
          value: _getSelectedTags(),
          postWidget: widget.postWidget ??
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: Colors.grey.shade500,
              ),
          onInputChanged: widget.filterable && isExpanded ? onSearchChanged : null,
          onTagRemoved: _onTagRemoved,
          boxDecoration: widget.boxDecoration ?? BoxDecoration(color: widget.disabled == true ? AppColors.grey.shade50 : Colors.white),
        ),
      ),
    );
  }
}
