import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/mixins/focus_mixin.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/mixins/input_validation_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/select/select_mixin.dart';
import 'package:te_widgets/widgets/text-field/text_field.dart';

class TSelect<V> extends StatefulWidget with TInputFieldMixin, TInputValueMixin<V>, TFocusMixin, TInputValidationMixin<V> {
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

  final List<TSelectItem<V>> items;
  final bool multiLevel, filterable;
  final double dropdownMaxHeight;
  final String? footerMessage;
  final VoidCallback? onExpanded;
  final VoidCallback? onCollapsed;

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
    this.filterable = false,
    this.dropdownMaxHeight = 200,
    this.footerMessage,
    this.onExpanded,
    this.onCollapsed,
    this.skipValidation,
  });

  @override
  State<TSelect<V>> createState() => _TSelectState<V>();
}

class _TSelectState<V> extends State<TSelect<V>>
    with
        TInputValueStateMixin<V, TSelect<V>>,
        TFocusStateMixin<TSelect<V>>,
        TInputValidationStateMixin<V, TSelect<V>>,
        TSelectCommonMixin<TSelect<V>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _displayTextBeforeExpansion = '';

  // Implement mixin getters
  @override
  List<TSelectItem<V>> get items => widget.items;

  @override
  bool get filterable => widget.filterable;

  @override
  bool get multiLevel => widget.multiLevel;

  @override
  double get dropdownMaxHeight => widget.dropdownMaxHeight;

  @override
  String? get footerMessage => widget.footerMessage;

  @override
  bool get isDisabled => widget.disabled == true;

  @override
  VoidCallback? get onExpanded => widget.onExpanded;

  @override
  VoidCallback? get onCollapsed => widget.onCollapsed;

  @override
  bool get isMultiple => false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    // Initialize common functionality
    initializeCommon();
    _updateDisplayText();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.filterable) {
        _showDropdownWithSearch();
      }
    });
  }

  @override
  void didUpdateWidget(TSelect<V> oldWidget) {
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
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void updateSelectedStates() {
    for (final item in internalItems) {
      item.selected = item.value == widget.value;
      if (item is TMultiLevelSelectItem<V> && item.hasChildren) {
        updateChildrenSelection(item, widget.value != null ? [widget.value!] : []);
      }
    }
    autoExpandParentsWithSelectedChildren();
  }

  @override
  void onItemTapped(TSelectItem item) {
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
    return selectedItems.isNotEmpty ? selectedItems.first as TSelectItem<V> : null;
  }

  void _showDropdownWithSearch() {
    _displayTextBeforeExpansion = _controller.text;
    _controller.clear();
    _focusNode.requestFocus();
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
      child: GestureDetector(
        key: selectKey,
        onTap: toggleDropdown,
        child: TTextField(
          skipValidation: true,
          focusNode: _focusNode,
          label: widget.label,
          tag: widget.tag,
          placeholder: widget.placeholder,
          helperText: widget.helperText,
          message: widget.message,
          isRequired: widget.isRequired,
          disabled: widget.disabled == true || !widget.filterable,
          size: widget.size,
          color: widget.color,
          controller: _controller,
          value: isExpanded && widget.filterable ? searchQuery : _controller.text,
          postWidget: widget.postWidget ??
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.grey.shade500,
              ),
          onValueChanged: widget.filterable && isExpanded ? onSearchChanged : null,
          boxDecoration: widget.boxDecoration ?? BoxDecoration(color: widget.disabled == true ? AppColors.grey.shade50 : Colors.white),
        ),
      ),
    );
  }
}
