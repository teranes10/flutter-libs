import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/tags-field/tags_field_theme.dart';

class TMultiSelect<T, V> extends StatefulWidget
    with
        TInputFieldMixin,
        TFocusMixin,
        TTextFieldMixin,
        TInputValueMixin<List<V>>,
        TInputValidationMixin<List<V>>,
        TPopupMixin,
        TPaginationMixin<T>,
        TSelectMixin<T, V> {
  @override
  final String? label, tag, helperText, placeholder;
  @override
  final bool isRequired, disabled, autoFocus, readOnly;
  @override
  final TTagsFieldTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final TextEditingController? textController;
  @override
  final List<V>? value;
  @override
  final ValueNotifier<List<V>>? valueNotifier;
  @override
  final ValueChanged<List<V>>? onValueChanged;
  @override
  final List<String? Function(List<V>?)>? rules;
  @override
  final Duration? validationDebounce;

  @override
  final List<T>? items;
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
    this.helperText,
    this.placeholder,
    this.isRequired = false,
    this.disabled = false,
    this.autoFocus = false,
    this.theme,
    this.onTap,
    this.focusNode,
    this.textController,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.rules,
    this.validationDebounce,
    this.items,
    this.multiLevel = false,
    this.filterable = true,
    this.footerMessage,
    this.onShow,
    this.onHide,
    this.itemText,
    this.itemValue,
    this.itemKey,
    this.itemChildren,
    this.selectedIcon,

    // Server-side pagination
    this.onLoad,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [],
    this.loading = false,
    this.search,
    this.searchDelay = 300,
    this.itemToString,
    this.controller,
    bool? readOnly,
  }) : readOnly = readOnly ?? !filterable;
  @override
  State<TMultiSelect<T, V>> createState() => _TMultiSelectState<T, V>();
}

class _TMultiSelectState<T, V> extends State<TMultiSelect<T, V>>
    with
        TInputFieldStateMixin<TMultiSelect<T, V>>,
        TFocusStateMixin<TMultiSelect<T, V>>,
        TTextFieldStateMixin<TMultiSelect<T, V>>,
        TPopupStateMixin<TMultiSelect<T, V>>,
        TPaginationStateMixin<T, TMultiSelect<T, V>>,
        TSelectStateMixin<T, V, TMultiSelect<T, V>>,
        TInputValueStateMixin<List<V>, TMultiSelect<T, V>>,
        TInputValidationStateMixin<List<V>, TMultiSelect<T, V>> {
  @override
  TTagsFieldTheme get wTheme => widget.theme ?? theme.tagsFieldTheme;
  @override
  bool get isMultiple => true;
  @override
  bool get persistent => true;

  @override
  void onExternalValueChanged(List<V>? value) {
    super.onExternalValueChanged(value);
    updateSelectedStates();
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
  void showPopup(BuildContext context) {
    controller.clear();
    super.showPopup(context);
  }

  @override
  void hidePopup() {
    super.hidePopup();
    controller.clear();

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
    final colors = context.colors;

    return buildWithDropdownTarget(
      child: buildContainer(
        isMultiline: true,
        onTap: () => {togglePopup(context)},
        postWidget: Icon(isPopupShowing ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: colors.onSurfaceVariant),
        child: wTheme.buildTagsField(
          colors,
          tags: _getSelectedTags(),
          onRemove: _onTagRemoved,
          child: Focus(
            child: IgnorePointer(
              child: buildTextField(
                textInputAction: TextInputAction.unspecified,
                onValueChanged: widget.filterable && isPopupShowing ? onSearchChanged : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
