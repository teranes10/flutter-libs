import 'dart:collection';
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
  final String? label, tag, helperText, placeholder, info;
  @override
  final bool isRequired, disabled, autoFocus, readOnly;
  @override
  final bool clearable;
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

  /// Number of items to display per page.
  ///
  /// For server-side loading ([onLoad]), defaults to 6.
  /// For local [items], this is ignored — all items are loaded at once;
  /// use [visibleItemsCount] to control how many rows are visible before scrolling.
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
  @override
  final TPopupMode? popupMode;

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
  final bool lazy;

  /// The number of items to show as visible in the dropdown before scrolling.
  ///
  /// For local [items] (no [onLoad]), this controls the dropdown height:
  /// all items are always rendered but only [visibleItemsCount] rows are
  /// visible before the user needs to scroll. Defaults to 6.
  ///
  /// For server-side loading ([onLoad]), this also controls the dropdown height,
  /// while [itemsPerPage] controls how many items are fetched per request.
  final int? visibleItemsCount;

  const TMultiSelect({
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
    this.onInputChanged,
  })  : readOnly = readOnly ?? !filterable,
        itemText = itemText ?? _defaultItemText,
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
  final Map<int, double> _itemHeights = {};

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

  /// Whether local items (no [onLoad]) are being used.
  bool get _isLocalItems => widget.onLoad == null;

  @override
  TListController<T, K> buildController() {
    // For local items, load everything at once — no chunked pagination (-1).
    // For server-side, respect itemsPerPage (default 6).
    final effectiveItemsPerPage = _isLocalItems ? -1 : (widget.itemsPerPage ?? 6);

    return TListController<T, K>(
      items: widget.items ?? [],
      itemsPerPage: effectiveItemsPerPage,
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
    // visibleItemsCount caps the visible rows in the dropdown.
    // For local items, we never show an infinite-scroll footer.
    final limit = widget.visibleItemsCount ?? widget.itemsPerPage ?? 6;
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
    final extraPadding = 16.0 +
        16.0 +
        (hasMore ? 40.0 : 0.0) +
        (hasFooter ? 48.0 : 0.0) +
        (listController.isServerSide ? 4.0 : 0.0) +
        (shouldCenteredOverlay ? 62.0 : 0.0);
    return heightSum + extraPadding;
  }

  @override
  Widget getContentWidget(BuildContext context) {
    // Infinite scroll only makes sense for server-side loading.
    // For local items, all items are already loaded — no scroll-to-load needed.
    final list = TList<T, K>(
      controller: listController,
      theme: listTheme.copyWith(
        animationBuilder: TListAnimationBuilders.slideInDown,
        animationDuration: Duration(milliseconds: 150),
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
            multiple: true,
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
        ? LayoutBuilder(
            builder: (context, constraints) {
              final hasBoundedHeight = constraints.hasBoundedHeight;
              return Column(
                spacing: 7.5,
                mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (widget.filterable)
                    Padding(
                      padding: const EdgeInsets.only(left: 7.5, right: 7.5, top: 7.5, bottom: 5),
                      child: TTextField(
                          placeholder: 'Search...',
                          decorationType: TInputDecorationType.underline,
                          value: listController.value.search,
                          onValueChanged: (text) => listController.handleSearchChange(text ?? '')),
                    ),
                  if (hasBoundedHeight) Expanded(child: list) else list,
                ],
              );
            },
          )
        : list;

    return Padding(padding: const EdgeInsets.fromLTRB(6, 16, 6, 16), child: content);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    onTap() {
      if (widget.disabled) return;
      togglePopup(context);
    }

    return buildWithDropdownTarget(
      child: buildContainer(
        expands: true,
        hasValue: listController.hasSelection,
        onClear: () {
          listController.updateSelectionState(LinkedHashSet<K>());
          tagsController.updateState(tags: []);
          notifyValueChanged([]);
        },
        child: buildTagsField(onInputChanged: widget.filterable && isPopupShowing ? listController.handleSearchChange : null, onTap: onTap),
        beforePostWidget:
            Icon(isPopupShowing ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: colors.onSurfaceVariant),
        onTap: onTap,
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
  void onExternalValueChanged(List<V>? value) {
    super.onExternalValueChanged(value);

    if (value == null || value.isEmpty) {
      if (listController.hasSelection) {
        listController.updateSelectionState(LinkedHashSet<K>());
      }
      return;
    }

    if (!_isLocalItems && widget.itemValue == null && value.isNotEmpty) {
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
