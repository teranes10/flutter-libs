import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/mixins/focus_mixin.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/mixins/input_validation_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/select/select_mixin.dart';
import 'package:te_widgets/widgets/tags-field/tags_field.dart';

class TMultiSelect<V> extends StatefulWidget with TInputFieldMixin, TInputValueMixin<List<V>>, TFocusMixin, TInputValidationMixin<List<V>> {
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

  final List<TSelectItem<V>> items;
  final bool multiLevel, filterable;
  final double dropdownMaxHeight;
  final String? footerMessage;
  final VoidCallback? onExpanded;
  final VoidCallback? onCollapsed;

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
    this.filterable = false,
    this.dropdownMaxHeight = 200,
    this.footerMessage,
    this.onExpanded,
    this.onCollapsed,
    this.skipValidation,
  });

  @override
  State<TMultiSelect<V>> createState() => _TMultiSelectState<V>();
}

class _TMultiSelectState<V> extends State<TMultiSelect<V>>
    with
        TInputValueStateMixin<List<V>, TMultiSelect<V>>,
        TFocusStateMixin<TMultiSelect<V>>,
        TInputValidationStateMixin<List<V>, TMultiSelect<V>>,
        TSelectCommonMixin<TMultiSelect<V>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

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
  bool get isMultiple => true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    // Initialize common functionality
    initializeCommon();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.filterable) {
        _showDropdownWithSearch();
      }
    });
  }

  @override
  void didUpdateWidget(TMultiSelect<V> oldWidget) {
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
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void updateSelectedStates() {
    final selectedValues = widget.value ?? <V>[];
    for (final item in internalItems) {
      item.selected = selectedValues.contains(item.value);
      if (item is TMultiLevelSelectItem<V> && item.hasChildren) {
        updateChildrenSelection(item, selectedValues);
      }
    }
    autoExpandParentsWithSelectedChildren();
  }

  @override
  void onItemTapped(TSelectItem item) {
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
    _focusNode.requestFocus();
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
