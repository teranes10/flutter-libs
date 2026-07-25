import 'dart:collection';
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

  /// The info text (optional).
  @override
  final String? info;

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
  /// For server-side loading ([onLoad]), defaults to 7.
  /// For local [items], this is ignored — all items are loaded at once;
  /// use [visibleItemsCount] to control how many rows are visible before scrolling.
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

  /// Preferred display mode of the popup.
  @override
  final TPopupMode? popupMode;

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

  /// Whether to load items lazily when the dropdown is first opened.
  final bool lazy;

  /// The number of items to show as visible in the dropdown before scrolling.
  ///
  /// For local [items] (no [onLoad]), this controls the dropdown height:
  /// all items are always rendered but only [visibleItemsCount] rows are
  /// visible before the user needs to scroll. Defaults to 7.
  ///
  /// For server-side loading ([onLoad]), this also controls the dropdown height,
  /// while [itemsPerPage] controls how many items are fetched per request.
  final int? visibleItemsCount;

  /// Creates a dropdown select field.
  const TSelect({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.placeholder,
    this.info,
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
    this.itemsPerPage,
    this.search,
    this.searchDelay,
    this.onLoad,
    this.controller,
    // Popup
    this.onShow,
    this.onHide,
    this.popupMode,
    // Select
    this.filterable = true,
    this.itemSubText,
    this.itemImageUrl,
    this.itemChildren,
    this.cardTheme,
    this.itemValue,
    this.lazy = false,
    this.visibleItemsCount,
    ItemTextAccessor<T>? itemText,
    ItemKeyAccessor<T, K>? itemKey,
    bool? readOnly,
  })  : readOnly = readOnly ?? !filterable,
        itemText = itemText ?? _defaultItemText,
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
  final Map<int, double> _itemHeights = {};

  @override
  double get contentMaxHeight {
    // visibleItemsCount caps the visible rows in the dropdown.
    // For local items, we never show an infinite-scroll footer, so hasMore is irrelevant for height.
    final limit = widget.visibleItemsCount ?? widget.itemsPerPage ?? 7;
    final totalItems = listController.flatItems.length;
    final count =
        (listController.isEmpty && listController.isFetching) ? 3 : (totalItems == 0 ? 1 : (totalItems < limit ? totalItems : limit));

    double heightSum = 0;
    int itemsMeasured = 0;

    for (int i = 0; i < count; i++) {
      if (_itemHeights.containsKey(i)) {
        heightSum += _itemHeights[i]!;
        itemsMeasured++;
      }
    }

    if (itemsMeasured < count) {
      final average = itemsMeasured > 0 ? (heightSum / itemsMeasured) : 45.0;
      heightSum += average * (count - itemsMeasured);
    }

    // Only add infinite-scroll footer height for server-side lists.
    final hasMore = !_isLocalItems && listController.value.hasMoreItems;
    final hasFooter = widget.listTheme?.footerBuilder != null || listTheme.footerBuilder != null;
    final extraPadding =
        16.0 + 16.0 + (hasMore ? 40.0 : 0.0) + (hasFooter ? 48.0 : 0.0) + (shouldCenteredOverlay && widget.filterable ? 62.0 : 0.0);
    return heightSum + extraPadding;
  }

  /// Whether local items (no [onLoad]) are being used.
  bool get _isLocalItems => widget.onLoad == null;

  @override
  TListController<T, K> buildController() {
    // For local items, load everything at once — no chunked pagination (-1).
    // For server-side, respect itemsPerPage (default 7).
    final effectiveItemsPerPage = _isLocalItems ? -1 : (widget.itemsPerPage ?? 7);

    return TListController<T, K>(
      items: widget.items ?? [],
      itemsPerPage: effectiveItemsPerPage,
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
    // Infinite scroll only makes sense for server-side loading.
    // For local items, all items are already loaded — no scroll-to-load needed.
    final list = TList<T, K>(
      controller: listController,
      theme: listTheme.copyWith(
        infiniteScroll: !_isLocalItems,
        emptyStateBuilder: listTheme.emptyStateBuilder ??
            (context) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Text('No items found', style: TextStyle(fontSize: 14, color: context.colors.onSurfaceVariant)),
                  ),
                ),
      ),
      itemBuilder: (ctx, item, index) {
        TListCard toListCard(TListItem<T, K> item) {
          return TListCard(
            title: widget.itemText(item.data),
            subTitle: widget.itemSubText?.call(item.data),
            imageUrl: widget.itemImageUrl?.call(item.data),
            isSelected: item.isSelected,
            isExpanded: item.isExpanded,
            level: item.level,
            theme: widget.cardTheme,
            multiple: false,
            onTap: () => _onItemSelected(item),
            children: item.children?.map((child) => toListCard(child)).toList(),
          );
        }

        return TMeasureSize(
          onMeasure: (height) {
            if (_itemHeights[index] != height) {
              setState(() {
                _itemHeights[index] = height;
              });
            }
          },
          child: toListCard(item),
        );
      },
    );

    final showFilter = shouldCenteredOverlay || effectivePopupMode == TPopupMode.page;

    final content = showFilter
        ? Column(children: [
            if (widget.filterable)
              Padding(
                padding: EdgeInsets.only(left: 7.5, right: 7.5, top: 7.5, bottom: 12.5),
                child: TTextField<String?>(
                    labelPosition: TLabelPosition.aboveField,
                    size: TInputSize.sm,
                    placeholder: effectivePopupMode == TPopupMode.page ? 'Search...' : widget.label,
                    decorationType: TInputDecorationType.underline,
                    textController: textController,
                    onValueChanged: (text) => listController.handleSearchChange(text ?? '')),
              ),
            Expanded(child: list),
          ])
        : list;

    return Padding(padding: EdgeInsets.fromLTRB(6, 16, 6, 16), child: content);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return buildWithDropdownTarget(
      child: buildTextField(
        onValueChanged: widget.filterable && isPopupShowing ? listController.handleSearchChange : null,
        hasValue: currentValue != null,
        beforePostWidget:
            Icon(isPopupShowing ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: colors.onSurfaceVariant),
        onClear: () {
          listController.updateSelectionState(LinkedHashSet<K>());
          notifyValueChanged(null);
        },
        onTap: () {
          if (widget.disabled) return;
          togglePopup(context);
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isPageMode = widget.popupMode == TPopupMode.page || (widget.popupMode == null && MediaQuery.of(context).isMobile);
    // Only bump itemsPerPage for server-side lists in page mode.
    // Local lists always display all items regardless of mode.
    if (isPageMode && !_isLocalItems && widget.itemsPerPage == null && listController.itemsPerPage != 20) {
      listController.updateState(who: 'didChangeDependencies_page_mode', itemsPerPage: 20);
    }
  }

  @override
  void initState() {
    super.initState();

    if (!widget.lazy && listController.isEmpty && !listController.isFetching) {
      listController.handleRefresh();
    }

    _updateState();
  }

  @override
  void showPopup(BuildContext context) {
    if (widget.lazy && listController.isEmpty && !listController.isFetching) {
      listController.handleRefresh();
    }
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
    _itemHeights.clear();
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
    if (!_isLocalItems && widget.itemValue == null && selectedKey != null) {
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
