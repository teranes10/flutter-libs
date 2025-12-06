import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/tags-field/tags_field_mixin.dart';

/// A multi-select dropdown field with search and tags support.
///
/// `TMultiSelect` combines a list selection UI with a tag-based input field.
/// It supports:
/// - Multiple item selection
/// - Search/Filtering
/// - Displaying selected items as tags
/// - Async loading of items
/// - Custom item rendering
///
/// ## Basic Usage
///
/// ```dart
/// TMultiSelect<String, String, String>(
///   label: 'Select Fruits',
///   items: ['Apple', 'Banana', 'Orange'],
///   onValueChanged: (selected) => print(selected),
/// )
/// ```
///
/// ## With Custom Objects
///
/// ```dart
/// TMultiSelect<User, String, String>(
///   label: 'Assign Users',
///   items: users,
///   itemText: (user) => user.name,
///   itemValue: (user) => user.id,
///   onValueChanged: (ids) => updateUserAssignments(ids),
/// )
/// ```
///
/// Type parameters:
/// - [T]: The type of the item object
/// - [V]: The type of the value to return (e.g. ID)
/// - [K]: The type of the key used for uniqueness
class TMultiSelect<T, V, K> extends StatefulWidget
    with
        TInputFieldMixin,
        TFocusMixin,
        TTextFieldMixin,
        TTagsFieldMixin,
        TInputValueMixin<List<V>>,
        TInputValidationMixin<List<V>>,
        TPopupMixin,
        TListMixin<T, K> {
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
  final TTagsController? textController;
  @override
  final List<V>? value;
  @override
  final ValueNotifier<List<V>?>? valueNotifier;
  @override
  final ValueChanged<List<V>?>? onValueChanged;
  @override
  final List<String? Function(List<V>?)>? rules;
  @override
  final Duration? validationDebounce;

  //List
  final TListTheme? listTheme;
  @override
  final List<T>? items;
  @override
  final int? itemsPerPage;
  @override
  final String? search;
  @override
  final int? searchDelay;
  @override
  final TLoadListener<T>? onLoad;
  @override
  final ItemKeyAccessor<T, K>? itemKey;
  @override
  final TListController<T, K>? controller;

  // Popup
  @override
  final VoidCallback? onShow;
  @override
  final VoidCallback? onHide;

  //Tags
  @override
  bool get addTagOnEnter => false;
  @override
  bool get allowDuplicates => false;
  @override
  List<String> get delimiters => [];
  @override
  final ValueChanged<String>? onInputChanged;

  //Select
  /// Whether to show a search bar in the dropdown.
  final bool filterable;
  final ItemTextAccessor<T> itemText;
  final ItemTextAccessor<T>? itemSubText;
  final ItemTextAccessor<T>? itemImageUrl;
  final ItemValueAccessor<T, V>? itemValue;
  final ItemChildrenAccessor<T>? itemChildren;
  final TListCardTheme? cardTheme;

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
    // List
    this.listTheme,
    this.items,
    this.itemsPerPage = 6,
    this.search,
    this.searchDelay,
    this.onLoad,
    this.controller,
    // Popup
    this.onShow,
    this.onHide,
    // Select
    this.filterable = true,
    this.itemSubText,
    this.itemImageUrl,
    this.itemChildren,
    this.cardTheme,
    this.itemValue,
    ItemTextAccessor<T>? itemText,
    ItemKeyAccessor<T, K>? itemKey,
    bool? readOnly,
    this.onInputChanged,
  })  : readOnly = readOnly ?? !filterable,
        itemText = itemText ?? _defaultItemText,
        assert(
          !(itemKey != null && itemValue != null),
          'You cannot provide both `itemKey` and `itemValue`. '
          '`itemValue` will be used as key if provided.',
        ),
        itemKey = itemKey ?? (itemValue != null ? itemValue as ItemKeyAccessor<T, K> : null);

  static String _defaultItemText<T>(T item) {
    return item.toString();
  }

  @override
  State<TMultiSelect<T, V, K>> createState() => _TMultiSelectState<T, V, K>();
}

class _TMultiSelectState<T, V, K> extends State<TMultiSelect<T, V, K>>
    with
        TInputFieldStateMixin<TMultiSelect<T, V, K>>,
        TFocusStateMixin<TMultiSelect<T, V, K>>,
        TTextFieldStateMixin<TMultiSelect<T, V, K>>,
        TTagsFieldStateMixin<TMultiSelect<T, V, K>>,
        TInputValueStateMixin<List<V>, TMultiSelect<T, V, K>>,
        TInputValidationStateMixin<List<V>, TMultiSelect<T, V, K>>,
        TPopupStateMixin<TMultiSelect<T, V, K>>,
        TListStateMixin<T, K, TMultiSelect<T, V, K>> {
  TListTheme get listTheme => widget.listTheme ?? context.theme.listTheme;

  @override
  TTagsFieldTheme get wTheme => widget.theme ?? context.theme.tagsFieldTheme;

  @override
  TTagsController buildTextController() {
    return TTagsController(
      tags: [],
      text: widget.search,
      allowDuplicates: false,
      delimiters: [],
    );
  }

  @override
  TListController<T, K> buildController() {
    return TListController<T, K>(
      items: widget.items ?? [],
      itemsPerPage: widget.itemsPerPage ?? 0,
      search: widget.search ?? '',
      searchDelay: widget.searchDelay,
      onLoad: widget.onLoad,
      itemKey: widget.itemKey,
      itemToString: widget.itemText,
      itemChildren: widget.itemChildren,
      selectionMode: TSelectionMode.multiple,
      expansionMode: widget.itemChildren != null ? TExpansionMode.single : TExpansionMode.none,
    );
  }

  @override
  double get contentMaxHeight {
    final itemsPerPage =
        listController.isServerSide ? listController.itemsPerPage : min(listController.itemsPerPage, listController.flatItems.length);

    return (itemsPerPage * listTheme.itemBaseHeight) + 12 + (listController.isServerSide ? 4 : 0) + (shouldCenteredOverlay ? 62 : 0);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    final list = TList<T, K>(
      controller: listController,
      theme: listTheme.copyWith(infiniteScroll: true),
      cardTheme: widget.cardTheme,
      itemTitle: widget.itemText,
      itemSubTitle: widget.itemSubText,
      itemImageUrl: widget.itemImageUrl,
      onTap: _onItemSelected,
    );

    return shouldCenteredOverlay
        ? Column(spacing: 7.5, children: [
            if (widget.filterable)
              Padding(
                padding: EdgeInsets.only(left: 7.5, right: 7.5, top: 7.5, bottom: 5),
                child: TTextField(
                    placeholder: 'Search...',
                    theme: context.theme.textFieldTheme.copyWith(decorationType: TInputDecorationType.underline),
                    value: listController.value.search,
                    onValueChanged: (text) => listController.handleSearchChange(text ?? '')),
              ),
            Expanded(child: list),
          ])
        : list;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return buildWithDropdownTarget(
      child: buildContainer(
        isMultiline: true,
        child: buildTagsField(onInputChanged: widget.filterable && isPopupShowing ? listController.handleSearchChange : null),
        postWidget: Icon(isPopupShowing ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: colors.onSurfaceVariant),
        onTap: () {
          if (widget.disabled) return;
          togglePopup(context);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (listController.isEmpty && !listController.isLoading) {
      listController.handleRefresh();
    }

    _updateState();
  }

  @override
  void showPopup(BuildContext context) {
    super.showPopup(context);
    _updateState();
  }

  @override
  void hidePopup() {
    super.hidePopup();
    _updateState();
  }

  @override
  void onListStateChanged() {
    super.onListStateChanged();
    _updateState();
  }

  @override
  void onExternalValueChanged(List<V>? value) {
    super.onExternalValueChanged(value);

    if (value == null || value.isEmpty) {
      if (listController.hasSelection) {
        listController.updateSelectionState(LinkedHashSet<K>());
      }
      return;
    }

    if (widget.itemValue == null && value.isNotEmpty) {
      for (T item in value.cast<T>()) {
        final key = listController.itemKey(item);
        listController.itemsMap.putIfAbsent(key, () => item);
      }
    }

    final selectedKeys = widget.itemValue == null ? value.map((x) => listController.itemKey(x as T)).toList() : (value as List<K>);
    final selectedKeySet = LinkedHashSet<K>.from(selectedKeys);
    if (!selectedKeySet.equalsEach(listController.selectedKeys)) {
      listController.updateSelectionState(selectedKeySet);
    }
  }

  void _onItemSelected(TListItem<T, K> item) {
    if (item.hasChildren) {
      listController.toggleExpansionByKey(item.key);
    } else {
      listController.toggleSelectionByKey(item.key);

      final selectedValues = listController.selectedItems.map((x) => widget.itemValue?.call(x) ?? item.data as V).toList();
      final selectedTexts = listController.selectedItems.map((x) => widget.itemText(x)).toList();

      tagsController.updateState(tags: selectedTexts);
      notifyValueChanged(selectedValues);
      focusNode.requestFocus();
    }
  }

  void _updateState() {
    if (isPopupShowing) {
      if (widget.filterable) {
        tagsController.updateState(text: listController.value.search);
      }
    } else {
      final selected = listController.selectedItems;
      if (selected.isNotEmpty) {
        tagsController.updateState(text: '', tags: selected.map((x) => widget.itemText(x)).toList());
      } else {
        tagsController.updateState(text: '', tags: []);
      }
    }
  }
}
