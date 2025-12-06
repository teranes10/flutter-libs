import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Mixin for widgets that implement list behavior.
///
/// This mixin defines the interface for list-based widgets,
/// requiring properties for items, pagination, and data loading.
mixin TListMixin<T, K> {
  /// The list of items to display.
  List<T>? get items;

  /// The number of items to display per page.
  int? get itemsPerPage;

  /// The current search query.
  String? get search;

  /// Debounce delay for search in milliseconds.
  int? get searchDelay;

  /// Callback for loading items from a server.
  TLoadListener<T>? get onLoad;

  /// Function to extract a unique key from an item.
  ItemKeyAccessor<T, K>? get itemKey;

  /// The controller managing the list state.
  TListController<T, K>? get controller;
}

/// State mixin for widgets using [TListController].
///
/// Handles initialization and lifecycle of the list controller,
/// including disposal and verification of configuration.
mixin TListStateMixin<T, K, W extends StatefulWidget> on State<W> {
  TListMixin<T, K> get _widget {
    assert(widget is TListMixin<T, K>, 'Widget must implement TListMixin<$T>');
    return widget as TListMixin<T, K>;
  }

  late TListController<T, K> _listController;
  late int _providedItemsPerPage;
  bool _isControllerOwned = false;

  /// The active list controller.
  TListController<T, K> get listController => _listController;

  /// The initial items per page provided by the widget.
  int get providedItemsPerPage => _providedItemsPerPage;

  /// Whether the controller was provided externally.
  bool get hasExternalController => !_isControllerOwned;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _providedItemsPerPage = _listController.itemsPerPage;
  }

  void _initializeController() {
    if (_widget.controller != null) {
      validateExternalController();
      _listController = _widget.controller!;
      _isControllerOwned = false;
    } else {
      _listController = buildController();
      _isControllerOwned = true;
    }

    _listController.addListener(onListStateChanged);
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldMixin = oldWidget as TListMixin<T, K>;

    if (oldMixin.controller != _widget.controller) {
      if (_isControllerOwned) {
        _listController.dispose();
      }

      _initializeController();
      _providedItemsPerPage = _listController.itemsPerPage;
    }

    if (oldMixin.search != _widget.search) {
      final newSearch = _widget.search ?? '';
      if (_listController.value.search != newSearch) {
        _listController.handleSearchChange(newSearch);
      }
    }

    if (oldMixin.itemsPerPage != _widget.itemsPerPage) {
      final newItemPerPage = _widget.itemsPerPage ?? 0;
      if (_listController.itemsPerPage != newItemPerPage) {
        _listController.handleItemsPerPageChange(newItemPerPage);
      }
    }

    if ((oldMixin.items != null && _widget.items != null) && !oldMixin.items!.equalsEach(_widget.items!)) {
      _listController.updateItems(_widget.items ?? []);
    }
  }

  @override
  void dispose() {
    _listController.removeListener(onListStateChanged);
    if (_isControllerOwned) {
      _listController.dispose();
    }
    super.dispose();
  }

  /// Builds a new controller instance based on widget properties.
  TListController<T, K> buildController() {
    return TListController<T, K>(
      items: _widget.items ?? [],
      itemsPerPage: _widget.itemsPerPage ?? 0,
      search: _widget.search ?? '',
      searchDelay: _widget.searchDelay,
      onLoad: _widget.onLoad,
      itemKey: _widget.itemKey,
    );
  }

  /// Validates that no conflicting properties are provided when using an external controller.
  void validateExternalController() {
    final hasConfig = _widget.items != null ||
        _widget.itemsPerPage != null ||
        _widget.search != null ||
        _widget.searchDelay != null ||
        _widget.onLoad != null ||
        _widget.itemKey != null;

    if (hasConfig) {
      throw FlutterError.fromParts([
        ErrorSummary('TList configuration conflict'),
        ErrorDescription(
          'Cannot provide both a controller and individual configuration properties.',
        ),
        ErrorHint(
          'When using a controller, it must be the single source of truth. '
          'Remove items, itemsPerPage, search, searchDelay, onLoad or itemKey parameters.',
        ),
      ]);
    }
  }

  /// Callback fired when the list state changes.
  void onListStateChanged() {}
}
