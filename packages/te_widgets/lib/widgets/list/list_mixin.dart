import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

mixin TListMixin<T, K> {
  List<T>? get items;
  int? get itemsPerPage;
  String? get search;
  int? get searchDelay;
  TLoadListener<T>? get onLoad;
  ItemKeyAccessor<T, K>? get itemKey;
  TListController<T, K>? get controller;
}

mixin TListStateMixin<T, K, W extends StatefulWidget> on State<W> {
  TListMixin<T, K> get _widget {
    assert(widget is TListMixin<T, K>, 'Widget must implement TListMixin<$T>');
    return widget as TListMixin<T, K>;
  }

  late TListController<T, K> _listController;
  late int _providedItemsPerPage;
  bool _isControllerOwned = false;

  TListController<T, K> get listController => _listController;
  int get providedItemsPerPage => _providedItemsPerPage;
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

  void onListStateChanged() {}
}
