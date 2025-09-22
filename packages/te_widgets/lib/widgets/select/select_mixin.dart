import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

mixin TSelectMixin<T, V> on TInputFieldMixin, TPopupMixin, TPaginationMixin<T> {
  bool get multiLevel;
  bool get filterable;
  String? get footerMessage;

  ItemTextAccessor<T>? get itemText;
  ItemValueAccessor<T, V>? get itemValue;
  ItemKeyAccessor<T>? get itemKey;
  ItemChildrenAccessor<T>? get itemChildren;
  IconData? get selectedIcon;
}

mixin TSelectStateMixin<T, V, W extends StatefulWidget> on State<W>, TPopupStateMixin<W>, TPaginationStateMixin<T, W> {
  TSelectMixin<T, V> get _selectWidget => widget as TSelectMixin<T, V>;

  late TSelectStateNotifier<T, V> stateNotifier;

  bool get isMultiple;

  @override
  void initState() {
    super.initState();
    stateNotifier = TSelectStateNotifier<T, V>(
      isMultiple: isMultiple,
      itemText: _selectWidget.itemText,
      itemValue: _selectWidget.itemValue,
      itemKey: _selectWidget.itemKey,
      itemChildren: _selectWidget.itemChildren,
      label: _selectWidget.label,
    );

    // Listen to pagination changes and update select items
    itemsNotifier.addListener(_onPaginatedItemsChanged);
    loadingNotifier.addListener(_onLoadingStateChanged);

    // Initialize with current items
    _updateSelectItems();
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldSelectWidget = oldWidget as TSelectMixin<T, V>;
    if (_selectWidget.items != oldSelectWidget.items) {
      _updateSelectItems();
    }
  }

  @override
  void dispose() {
    itemsNotifier.removeListener(_onPaginatedItemsChanged);
    loadingNotifier.removeListener(_onLoadingStateChanged);
    stateNotifier.dispose();
    super.dispose();
  }

  void _onPaginatedItemsChanged() {
    _updateSelectItems();
  }

  void _onLoadingStateChanged() {
    // Force rebuild when loading state changes
    if (mounted) {
      setState(() {});
    }
  }

  void _updateSelectItems() {
    if (serverSideRendering) {
      // For server-side rendering, use paginated items
      stateNotifier.updateDisplayItems(paginatedItems);
    } else {
      // For client-side, use all items
      stateNotifier.updateItems(_selectWidget.items ?? []);
    }

    updateSelectedStates();
  }

  @override
  double get contentMaxHeight {
    const double itemHeight = 50.0;
    const double padding = 12.0;
    double estimatedHeight = (itemHeight * 5) + padding;
    return estimatedHeight;
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return TSelectDropdown<T, V>(
      stateNotifier: stateNotifier,
      footerMessage: _selectWidget.footerMessage,
      multiple: isMultiple,
      selectedIcon: _selectWidget.selectedIcon,
      onItemTapped: onItemTapped,
      // Pass pagination state to dropdown
      showLoadingIndicator: serverSideRendering,
      loading: loading,
      onScrollEnd: serverSideRendering ? onScrollEnd : null,
      maxHeight: 200,
    );
  }

  @override
  void onSearchChanged(String query) {
    if (serverSideRendering) {
      // Use pagination mixin's search functionality for server-side
      super.onSearchChanged(query);
    } else {
      // Use select notifier's local filtering for client-side
      stateNotifier.onLocalSearchChanged(query);
    }
  }

  @override
  void showPopup(BuildContext context) {
    super.showPopup(context);

    // If server-side rendering and no items loaded yet, trigger initial load
    if (serverSideRendering && paginatedItems.isEmpty && !loading) {
      refresh();
    }
  }

  @override
  void refresh() {
    super.refresh();
    // Update select items after refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateSelectItems();
      }
    });
  }

  void updateSelectedStates();
  void onItemTapped(TSelectItem<V> item);
}
