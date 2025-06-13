import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/mixins/focus_mixin.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/mixins/input_validation_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/select/select_mixin.dart';
import 'package:te_widgets/widgets/text-field/text_field.dart';

class TSelect<T, V> extends StatefulWidget with TInputFieldMixin, TInputValueMixin<V>, TFocusMixin, TInputValidationMixin<V>, TSelectMixin<T, V> {
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
  final List<String? Function(V?)>? rules;
  @override
  final List<String>? errors;
  @override
  final Duration? validationDebounce;
  @override
  final bool? skipValidation;
  @override
  final V? value;
  @override
  final ValueNotifier<V>? valueNotifier;
  @override
  final ValueChanged<V>? onValueChanged;
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

  const TSelect({
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
  State<TSelect<T, V>> createState() => _TSelectState<T, V>();
}

class _TSelectState<T, V> extends State<TSelect<T, V>>
    with
        TInputValueStateMixin<V, TSelect<T, V>>,
        TFocusStateMixin<TSelect<T, V>>,
        TInputValidationStateMixin<V, TSelect<T, V>>,
        TSelectStateMixin<T, V, TSelect<T, V>> {
  late TextEditingController _controller;
  String _displayTextBeforeExpansion = '';

  @override
  bool get isMultiple => false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    // Initialize common functionality
    initializeCommon();
    _updateDisplayText();
  }

  @override
  void didUpdateWidget(TSelect<T, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    didUpdateItems(oldWidget.items);

    if (widget.value != oldWidget.value) {
      updateSelectedStates();
      _updateDisplayText();

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
    for (final item in internalItems) {
      item.selected = item.value == widget.value;
      if (item.hasChildren) {
        updateChildrenSelection(item, widget.value != null ? [widget.value!] : []);
      }
    }
    autoExpandParentsWithSelectedChildren();
  }

  @override
  void onItemTapped(TSelectItem<V> item) {
    setState(() {
      // Clear all selections
      TSelectItemCollector.clearAllSelections(internalItems);

      // Select the tapped item
      item.selected = true;
      notifyValueChanged(item.value);
      _updateDisplayText();
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    });

    hideDropdown();
  }

  void _updateDisplayText() {
    final selectedItem = _getSelectedItem();
    _controller.text = selectedItem?.text ?? '';
  }

  TSelectItem<V>? _getSelectedItem() {
    final selectedItems = TSelectItemCollector.getSelectedItems(internalItems);
    return selectedItems.isNotEmpty ? selectedItems.first : null;
  }

  void _showDropdownWithSearch() {
    _displayTextBeforeExpansion = _controller.text;
    _controller.clear();
    focusNode.requestFocus();
    showDropdown();
  }

  @override
  void hideDropdown() {
    if (overlayEntry == null) return;

    _controller.text = _displayTextBeforeExpansion;
    super.hideDropdown();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: TTextField(
        key: selectKey,
        onTap: widget.filterable ? null : toggleDropdown,
        skipValidation: true,
        focusNode: focusNode,
        label: widget.label,
        tag: widget.tag,
        placeholder: widget.placeholder,
        helperText: widget.helperText,
        message: widget.message,
        isRequired: widget.isRequired,
        readOnly: !widget.filterable,
        disabled: widget.disabled == true,
        size: widget.size,
        color: widget.color,
        controller: _controller,
        value: isExpanded && widget.filterable ? searchQuery : _controller.text,
        preWidget: widget.preWidget,
        postWidget:
            widget.postWidget ?? Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: AppColors.grey.shade500),
        onValueChanged: widget.filterable && isExpanded ? onSearchChanged : null,
        boxDecoration: widget.boxDecoration ?? BoxDecoration(color: widget.disabled == true ? AppColors.grey.shade50 : Colors.white),
      ),
    );
  }
}
