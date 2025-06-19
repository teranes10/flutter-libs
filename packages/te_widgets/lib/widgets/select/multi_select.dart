import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/mixins/pagination/pagination_config.dart';
import 'package:te_widgets/mixins/pagination/pagination_mixin.dart';
import 'package:te_widgets/mixins/popup_mixin.dart';
import 'package:te_widgets/mixins/focus_mixin.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/mixins/input_validation_mixin.dart';
import 'package:te_widgets/mixins/input_value_mixin.dart';
import 'package:te_widgets/widgets/select/select_configs.dart';
import 'package:te_widgets/widgets/select/select_mixin.dart';
import 'package:te_widgets/widgets/tags-field/tags_field.dart';

class TMultiSelect<T, V> extends StatefulWidget
    with
        TInputFieldMixin,
        TInputValueMixin<List<V>>,
        TFocusMixin,
        TInputValidationMixin<List<V>>,
        TPopupMixin,
        TPaginationMixin<T>,
        TSelectMixin<T, V> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool isRequired, disabled;
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
  final VoidCallback? onTap;

  @override
  final List<T> items;
  @override
  final bool multiLevel, filterable;

  @override
  final String? footerMessage;
  @override
  final VoidCallback? onShow;
  @override
  final VoidCallback? onHide;

  @override
  final ItemTextAccessor<T>? itemText;
  @override
  final ItemValueAccessor<T, V>? itemValue;
  @override
  final ItemKeyAccessor<T>? itemKey;
  @override
  final ItemChildrenAccessor<T>? itemChildren;

  @override
  final IconData? selectedIcon;

  @override
  final int itemsPerPage;
  @override
  final List<int> itemsPerPageOptions;
  @override
  final bool loading;
  @override
  final TLoadListener<T>? onLoad;
  @override
  final String? search;
  @override
  final int searchDelay;
  @override
  final String Function(T)? itemToString;
  @override
  final TPaginationController? controller;

  const TMultiSelect({
    super.key,
    this.label,
    this.tag,
    this.placeholder,
    this.helperText,
    this.message,
    this.isRequired = false,
    this.disabled = false,
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
    this.items = const [],
    this.multiLevel = false,
    this.filterable = true,
    this.footerMessage,
    this.onShow,
    this.onHide,
    this.skipValidation,
    this.itemText,
    this.itemValue,
    this.itemKey,
    this.itemChildren,
    this.selectedIcon,
    this.onTap,
    // Server-side pagination
    this.onLoad,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [],
    this.loading = false,
    this.search,
    this.searchDelay = 300,
    this.itemToString,
    this.controller,
  });

  @override
  State<TMultiSelect<T, V>> createState() => _TMultiSelectState<T, V>();
}

class _TMultiSelectState<T, V> extends State<TMultiSelect<T, V>>
    with
        TInputValueStateMixin<List<V>, TMultiSelect<T, V>>,
        TFocusStateMixin<TMultiSelect<T, V>>,
        TInputValidationStateMixin<List<V>, TMultiSelect<T, V>>,
        TPopupStateMixin<TMultiSelect<T, V>>,
        TPaginationStateMixin<T, TMultiSelect<T, V>>,
        TSelectStateMixin<T, V, TMultiSelect<T, V>> {
  late TextEditingController _controller;

  @override
  bool get isMultiple => true;
  @override
  bool get persistent => true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didUpdateWidget(TMultiSelect<T, V> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      updateSelectedStates();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void updateSelectedStates() {
    stateNotifier.updateSelectedStates(widget.value != null ? widget.value! : []);
  }

  @override
  void onItemTapped(TSelectItem<V> item) {
    final selectedItems = stateNotifier.getSelectedItems();
    final selectedValues = selectedItems.map((item) => item.value).toList();
    notifyValueChanged(selectedValues);
    focusNode.requestFocus();
  }

  @override
  void onFocusChanged(bool hasFocus) {
    super.onFocusChanged(hasFocus);
    if (hasFocus && !isPopupShowing) {
      showPopup();
    }
  }

  @override
  void showPopup() {
    _controller.clear();
    super.showPopup();
  }

  @override
  void hidePopup() {
    super.hidePopup();
    _controller.clear();

    // Reset search based on pagination type
    if (serverSideRendering) {
      // Reset search for server-side rendering
      super.onSearchChanged('');
    } else {
      // Reset search for client-side filtering
      stateNotifier.onLocalSearchChanged('');
    }
  }

  List<String> _getSelectedTags() {
    final selectedItems = stateNotifier.getSelectedItems();
    return selectedItems.map((item) => item.text).toList();
  }

  void _onTagRemoved(String tag) {
    final selectedItems = stateNotifier.getSelectedItems();
    final itemToRemove = selectedItems.firstWhere(
      (item) => item.text == tag,
      orElse: () => selectedItems.first,
    );

    itemToRemove.selected = false;
    final remainingSelectedItems = stateNotifier.getSelectedItems();
    final selectedValues = remainingSelectedItems.map((item) => item.value).toList();
    notifyValueChanged(selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return buildWithDropdownTarget(
      child: TTagsField(
        onTap: !widget.filterable ? togglePopup : null,
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
        inputValue: isPopupShowing && widget.filterable ? stateNotifier.searchQuery : '',
        value: _getSelectedTags(),
        postWidget: widget.postWidget ??
            Icon(
              isPopupShowing ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.grey.shade500,
            ),
        onInputChanged: widget.filterable && isPopupShowing ? onSearchChanged : null,
        onTagRemoved: _onTagRemoved,
        boxDecoration: widget.boxDecoration ?? BoxDecoration(color: widget.disabled == true ? AppColors.grey.shade50 : Colors.white),
      ),
    );
  }
}
