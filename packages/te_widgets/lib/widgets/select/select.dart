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
import 'package:te_widgets/widgets/text-field/text_field.dart';

class TSelect<T, V> extends StatefulWidget
    with TInputFieldMixin, TInputValueMixin<V>, TFocusMixin, TInputValidationMixin<V>, TPopupMixin, TPaginationMixin<T>, TSelectMixin<T, V> {
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
  final VoidCallback? onTap;

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
    this.items,
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
    this.selectedIcon = Icons.check,
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
  State<TSelect<T, V>> createState() => _TSelectState<T, V>();
}

class _TSelectState<T, V> extends State<TSelect<T, V>>
    with
        TInputValueStateMixin<V, TSelect<T, V>>,
        TFocusStateMixin<TSelect<T, V>>,
        TInputValidationStateMixin<V, TSelect<T, V>>,
        TPopupStateMixin<TSelect<T, V>>,
        TPaginationStateMixin<T, TSelect<T, V>>,
        TSelectStateMixin<T, V, TSelect<T, V>> {
  late TextEditingController _controller;
  String _displayTextBeforeExpansion = '';

  @override
  bool get isMultiple => false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateDisplayText();
  }

  @override
  void didUpdateWidget(TSelect<T, V> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      updateSelectedStates();
      _updateDisplayText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void updateSelectedStates() {
    stateNotifier.updateSelectedStates(widget.value != null ? [widget.value!] : []);
  }

  @override
  void onItemTapped(TSelectItem<V> item) {
    if (item.hasChildren) {
      return;
    }

    notifyValueChanged(item.value);
    _updateDisplayText();
    hidePopup();
  }

  void _updateDisplayText() {
    final selectedItem = _getSelectedItem();
    _controller.text = selectedItem?.text ?? '';
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  TSelectItem<V>? _getSelectedItem() {
    final selectedItems = stateNotifier.getSelectedItems();
    return selectedItems.isNotEmpty ? selectedItems.first : null;
  }

  @override
  void onFocusChanged(bool hasFocus) {
    super.onFocusChanged(hasFocus);

    if (hasFocus) {
      showPopup();
    } else {
      hidePopup();
    }
  }

  @override
  void showPopup() {
    _displayTextBeforeExpansion = _controller.text;
    if (widget.filterable) {
      _controller.clear();
    }
    super.showPopup();
  }

  @override
  void hidePopup() {
    super.hidePopup();
    _controller.text = _displayTextBeforeExpansion;

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
    return buildWithDropdownTarget(
      child: TTextField(
        onTap: !widget.filterable ? togglePopup : null,
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
        value: isPopupShowing && widget.filterable ? (stateNotifier.searchQuery) : _controller.text,
        preWidget: widget.preWidget,
        postWidget:
            widget.postWidget ?? Icon(isPopupShowing ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: AppColors.grey.shade500),
        onValueChanged: widget.filterable && isPopupShowing ? onSearchChanged : null,
        boxDecoration: widget.boxDecoration ?? BoxDecoration(color: widget.disabled == true ? AppColors.grey.shade50 : Colors.white),
      ),
    );
  }
}
