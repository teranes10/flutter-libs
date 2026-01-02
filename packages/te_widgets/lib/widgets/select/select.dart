import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A function that extracts a value from an item.
///
/// Used to get the value to be stored when an item is selected.
typedef ItemValueAccessor<T, V> = V Function(T item);

/// A dropdown select field with search, pagination, and hierarchical support.
///
/// `TSelect` provides a powerful select component with:
/// - Single selection from a list of items
/// - Optional search/filtering
/// - Pagination for large datasets
/// - Server-side data loading
/// - Hierarchical/nested items
/// - Custom item rendering
/// - Validation support
///
/// ## Basic Usage
///
/// ```dart
/// TSelect<String, String, String>(
///   label: 'Country',
///   items: ['USA', 'Canada', 'Mexico'],
///   placeholder: 'Select a country',
///   onValueChanged: (value) => print('Selected: $value'),
/// )
/// ```
///
/// ## With Custom Objects
///
/// ```dart
/// class User {
///   final int id;
///   final String name;
///   User(this.id, this.name);
/// }
///
/// TSelect<User, int, int>(
///   label: 'User',
///   items: users,
///   itemText: (user) => user.name,
///   itemValue: (user) => user.id,
///   onValueChanged: (userId) => print('Selected user ID: $userId'),
/// )
/// ```
///
/// ## With Server-Side Loading
///
/// ```dart
/// TSelect<Product, int, int>(
///   label: 'Product',
///   itemsPerPage: 10,
///   itemText: (product) => product.name,
///   itemValue: (product) => product.id,
///   onLoad: (page, search) async {
///     final response = await api.getProducts(page, search);
///     return (response.items, response.hasMore);
///   },
/// )
/// ```
///
/// Type parameters:
/// - [T]: The type of items in the list
/// - [V]: The type of the selected value
/// - [K]: The type of the item key (for tracking selection)
///
/// See also:
/// - [TMultiSelect] for multiple selection
/// - [TListController] for managing list state
class TSelect<T, V, K> extends StatefulWidget
    with TInputFieldMixin, TFocusMixin, TTextFieldMixin, TInputValueMixin<V>, TInputValidationMixin<V>, TPopupMixin, TListMixin<T, K> {
  // Input Field Properties

  /// The label text displayed above the field.
  @override
  final String? label;

  /// An optional tag displayed next to the label.
  @override
  final String? tag;

  /// Helper text displayed below the field.
  @override
  final String? helperText;

  /// Placeholder text shown when no item is selected.
  @override
  final String? placeholder;

  /// Whether this field is required.
  @override
  final bool isRequired;

  /// Whether the field is disabled.
  @override
  final bool disabled;

  /// Whether the field should auto-focus.
  @override
  final bool autoFocus;

  /// Whether the field is read-only.
  ///
  /// Defaults to the opposite of [filterable].
  @override
  final bool readOnly;

  /// Whether to show a clear button when an item is selected.
  @override
  final bool clearable;

  /// Custom theme for the text field.
  @override
  final TTextFieldTheme? theme;

  /// Callback fired when the field is tapped.
  @override
  final VoidCallback? onTap;

  /// Custom focus node.
  @override
  final FocusNode? focusNode;

  /// Custom text editing controller.
  @override
  final TextEditingController? textController;

  /// The currently selected value.
  @override
  final V? value;

  /// A ValueNotifier for two-way binding.
  @override
  final ValueNotifier<V?>? valueNotifier;

  /// Callback fired when the selected value changes.
  @override
  final ValueChanged<V?>? onValueChanged;

  /// Validation rules for the selected value.
  @override
  final List<String? Function(V?)>? rules;

  /// Debounce duration for validation.
  @override
  final Duration? validationDebounce;

  // List Properties

  /// Custom theme for the dropdown list.
  final TListTheme? listTheme;

  /// The list of items to display.
  ///
  /// If null, items must be loaded via [onLoad].
  @override
  final List<T>? items;

  /// Number of items to display per page.
  ///
  /// Defaults to 7.
  @override
  final int? itemsPerPage;

  /// Initial search query.
  @override
  final String? search;

  /// Debounce delay for search in milliseconds.
  @override
  final int? searchDelay;

  /// Callback for loading items from a server.
  ///
  /// Returns a tuple of (items, hasMore).
  @override
  final TLoadListener<T>? onLoad;

  /// Function to extract a unique key from an item.
  @override
  final ItemKeyAccessor<T, K>? itemKey;

  /// Controller for managing list state.
  @override
  final TListController<T, K>? controller;

  // Popup Properties

  /// Callback fired when the dropdown is shown.
  @override
  final VoidCallback? onShow;

  /// Callback fired when the dropdown is hidden.
  @override
  final VoidCallback? onHide;

  // Select-Specific Properties

  /// Whether the select field is filterable/searchable.
  ///
  /// When true, users can type to filter items.
  /// Defaults to true.
  final bool filterable;

  /// Function to extract display text from an item.
  ///
  /// Defaults to calling `toString()` on the item.
  final ItemTextAccessor<T> itemText;

  /// Function to extract subtitle text from an item.
  final ItemTextAccessor<T>? itemSubText;

  /// Function to extract image URL from an item.
  final ItemTextAccessor<T>? itemImageUrl;

  /// Function to extract the value to store when an item is selected.
  ///
  /// If null, the entire item is used as the value.
  final ItemValueAccessor<T, V>? itemValue;

  /// Function to extract child items for hierarchical display.
  final ItemChildrenAccessor<T>? itemChildren;

  /// Custom theme for list item cards.
  final TListCardTheme? cardTheme;

  /// Creates a dropdown select field.
  const TSelect({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.placeholder,
    this.isRequired = false,
    this.disabled = false,
    this.autoFocus = false,
    this.clearable = false,
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
    this.itemsPerPage = 7,
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
  State<TSelect<T, V, K>> createState() => _TSelectState<T, V, K>();
}

class _TSelectState<T, V, K> extends State<TSelect<T, V, K>>
    with
        TInputFieldStateMixin<TSelect<T, V, K>>,
        TFocusStateMixin<TSelect<T, V, K>>,
        TTextFieldStateMixin<TSelect<T, V, K>>,
        TInputValueStateMixin<V, TSelect<T, V, K>>,
        TInputValidationStateMixin<V, TSelect<T, V, K>>,
        TPopupStateMixin<TSelect<T, V, K>>,
        TListStateMixin<T, K, TSelect<T, V, K>> {
  TListTheme get listTheme => widget.listTheme ?? context.theme.listTheme;

  @override
  double get contentMaxHeight {
    final itemsPerPage =
        listController.isServerSide ? listController.itemsPerPage : min(listController.itemsPerPage, listController.flatItems.length);
    return (itemsPerPage * listTheme.itemBaseHeight) + 20 + (shouldCenteredOverlay && widget.filterable ? 62 : 0);
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
      selectionMode: TSelectionMode.single,
      expansionMode: widget.itemChildren != null ? TExpansionMode.single : TExpansionMode.none,
    );
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
        ? Column(children: [
            if (widget.filterable)
              Padding(
                padding: EdgeInsets.only(left: 7.5, right: 7.5, top: 7.5, bottom: 12.5),
                child: TTextField(
                    placeholder: 'Search...',
                    theme: context.theme.textFieldTheme.copyWith(decorationType: TInputDecorationType.underline),
                    textController: textController,
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
        showClearButton: currentValue != null,
        onClear: () {
          listController.updateSelectionState(LinkedHashSet<K>());
          notifyValueChanged(null);
        },
        child: IgnorePointer(
          child: buildTextField(onValueChanged: widget.filterable && isPopupShowing ? listController.handleSearchChange : null),
        ),
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
  void onExternalValueChanged(V? value) {
    super.onExternalValueChanged(value);

    if (value == null) {
      if (listController.hasSelection) {
        listController.updateSelectionState(LinkedHashSet<K>());
      }
      return;
    }

    final selectedKey = widget.itemValue == null ? listController.itemKey(value as T) : value as K;
    if (widget.itemValue == null && selectedKey != null) {
      listController.itemsMap.putIfAbsent(selectedKey, () => value as T);
    }

    final selectedKeySet = LinkedHashSet<K>.from(selectedKey != null ? [selectedKey] : []);
    if (!selectedKeySet.equalsEach(listController.selectedKeys)) {
      listController.updateSelectionState(selectedKeySet);
    }
  }

  void _onItemSelected(TListItem<T, K> item) {
    if (item.hasChildren) {
      listController.toggleExpansionByKey(item.key);
    } else {
      listController.selectItemKey(item.key);
      notifyValueChanged(widget.itemValue?.call(item.data) ?? item.data as V);
      hidePopup();
    }
  }

  void _updateState() {
    if (isPopupShowing) {
      if (widget.filterable) {
        textController.text = listController.value.search;
        textController.selection = TextSelection.collapsed(offset: textController.text.length);
      }
    } else {
      final selected = listController.selectedItems.firstOrNull;
      if (selected != null) {
        textController.text = widget.itemText(selected);
        textController.selection = TextSelection.collapsed(offset: textController.text.length);
      } else {
        textController.text = '';
        textController.selection = TextSelection.collapsed(offset: textController.text.length);
      }
    }
  }
}
