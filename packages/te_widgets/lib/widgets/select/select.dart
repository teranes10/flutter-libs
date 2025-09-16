import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TSelect<T, V> extends StatefulWidget
    with
        TInputFieldMixin,
        TFocusMixin,
        TTextFieldMixin,
        TInputValueMixin<V>,
        TInputValidationMixin<V>,
        TPopupMixin,
        TPaginationMixin<T>,
        TSelectMixin<T, V> {
  @override
  final String? label, tag, helperText, placeholder;
  @override
  final bool isRequired, disabled, autoFocus, readOnly;
  @override
  final TTextFieldTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final TextEditingController? textController;
  @override
  final V? value;
  @override
  final ValueNotifier<V>? valueNotifier;
  @override
  final ValueChanged<V>? onValueChanged;
  @override
  final List<String? Function(V?)>? rules;
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

  const TSelect({
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
    this.selectedIcon = Icons.check,
    // Server-side pagination
    this.onLoad,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [],
    this.loading = false,
    this.search,
    this.searchDelay = 2500,
    this.itemToString,
    this.controller,
    bool? readOnly,
  }) : readOnly = readOnly ?? !filterable;

  @override
  State<TSelect<T, V>> createState() => _TSelectState<T, V>();
}

class _TSelectState<T, V> extends State<TSelect<T, V>>
    with
        TInputFieldStateMixin<TSelect<T, V>>,
        TFocusStateMixin<TSelect<T, V>>,
        TTextFieldStateMixin<TSelect<T, V>>,
        TPopupStateMixin<TSelect<T, V>>,
        TPaginationStateMixin<T, TSelect<T, V>>,
        TSelectStateMixin<T, V, TSelect<T, V>>,
        TInputValueStateMixin<V, TSelect<T, V>>,
        TInputValidationStateMixin<V, TSelect<T, V>> {
  @override
  bool get isMultiple => false;

  @override
  void onExternalValueChanged(V? value) {
    super.onExternalValueChanged(value);
    updateSelectedStates();
  }

  @override
  void updateSelectedStates() {
    final value = currentValue;
    stateNotifier.updateSelectedStates(value != null ? [value] : []);
    if (!isPopupShowing) {
      _updateDisplayText();
    }
  }

  @override
  void onItemTapped(TSelectItem<V> item) {
    if (item.hasChildren) {
      return;
    }

    notifyValueChanged(item.value);
    hidePopup();
    _updateDisplayText();
  }

  void _updateDisplayText() {
    final selectedItem = _getSelectedItem();
    controller.text = selectedItem?.text ?? '';
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
  }

  TSelectItem<V>? _getSelectedItem() {
    final selectedItems = stateNotifier.getSelectedItems();
    return selectedItems.isNotEmpty ? selectedItems.first : null;
  }

  @override
  void onFocusChanged(bool hasFocus) {
    super.onFocusChanged(hasFocus);

    if (hasFocus && !isPopupShowing) {
      showPopup(context);
    }
  }

  @override
  void showPopup(BuildContext context) {
    if (widget.filterable) {
      controller.clear();
    }
    super.showPopup(context);
  }

  @override
  void hidePopup() {
    super.hidePopup();
    _updateDisplayText();

    // Reset search based on pagination type
    if (serverSideRendering) {
      // Reset search for server-side rendering
      super.onSearchChanged('');
    } else {
      // Reset search for client-side filtering
      stateNotifier.onLocalSearchChanged('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return buildWithDropdownTarget(
        child: buildContainer(
      child: IgnorePointer(child: buildTextField(onValueChanged: widget.filterable && isPopupShowing ? onSearchChanged : null)),
      postWidget: Icon(isPopupShowing ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: colors.onSurfaceVariant),
      onTap: () {
        if (!widget.filterable) return;

        togglePopup(context);
      },
    ));
  }
}
