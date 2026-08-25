part of 'crud_table.dart';

extension _TCrudTableSettingsExt<T, K, F extends TFormBase> on _TCrudTableState<T, K, F> {
  static final Map<String, ({
    bool? dense,
    int? viewMode,
    TTableExpansionMode? expansionMode,
    TTableExpansionMode? createMode,
    double? dialogWidth,
    double? sideOverlayWidth,
    double? createDialogWidth,
    double? createSideOverlayWidth,
    List<String>? headerOrder,
    Map<String, bool>? headerVisibility,
  })> _persistedRouteSettings = {};

  String? _findRouteName(BuildContext context) {
    final modalRouteName = ModalRoute.of(context)?.settings.name;
    if (modalRouteName != null && modalRouteName.isNotEmpty && modalRouteName != '/') {
      return modalRouteName;
    }

    try {
      final goState = GoRouterState.of(context);
      final loc = goState.matchedLocation.isNotEmpty ? goState.matchedLocation : goState.uri.toString();
      if (loc.isNotEmpty && loc != '/') return loc;
    } catch (_) {}

    if (modalRouteName != null && modalRouteName.isNotEmpty) {
      return modalRouteName;
    }

    return null;
  }

  String _resolveRouteStorageKey(BuildContext context) {
    if (widget.config.storageKey != null && widget.config.storageKey!.isNotEmpty) {
      return widget.config.storageKey!;
    }
    final itemType = T.toString();
    final routeName = _findRouteName(context);
    if (routeName != null && routeName.isNotEmpty) {
      return '${routeName}_$itemType';
    }
    return itemType;
  }

  void _restoreRouteSettings() {
    final routeKey = _resolveRouteStorageKey(context);

    // 1. Check in-memory session cache
    final cached = _persistedRouteSettings[routeKey];
    if (cached != null) {
      if (cached.dense != null) _dense = cached.dense!;
      if (cached.viewMode != null) _viewMode = cached.viewMode!;
      if (cached.expansionMode != null) _selectedExpansionMode = cached.expansionMode;
      if (cached.createMode != null) _selectedCreateMode = cached.createMode;
      if (cached.dialogWidth != null) _dialogWidth = cached.dialogWidth;
      if (cached.sideOverlayWidth != null) _sideOverlayWidth = cached.sideOverlayWidth;
      if (cached.createDialogWidth != null) _createDialogWidth = cached.createDialogWidth;
      if (cached.createSideOverlayWidth != null) _createSideOverlayWidth = cached.createSideOverlayWidth;
      if (cached.headerOrder != null && cached.headerVisibility != null) {
        _reconcileHeaders(cached.headerOrder!, cached.headerVisibility!);
      }
      return;
    }

    // 2. Check PageStorage
    final pageStorage = PageStorage.maybeOf(context);
    if (pageStorage != null) {
      final savedDense = pageStorage.readState(context, identifier: 'tc_dense_$routeKey') as bool?;
      final savedViewMode = pageStorage.readState(context, identifier: 'tc_viewMode_$routeKey') as int?;
      final savedExpModeName = pageStorage.readState(context, identifier: 'tc_expMode_$routeKey') as String?;
      final savedCreateModeName = pageStorage.readState(context, identifier: 'tc_createMode_$routeKey') as String?;
      final savedDialogWidth = pageStorage.readState(context, identifier: 'tc_dialogWidth_$routeKey') as double?;
      final savedSideOverlayWidth = pageStorage.readState(context, identifier: 'tc_sideOverlayWidth_$routeKey') as double?;
      final savedCreateDialogWidth = pageStorage.readState(context, identifier: 'tc_createDialogWidth_$routeKey') as double?;
      final savedCreateSideOverlayWidth = pageStorage.readState(context, identifier: 'tc_createSideOverlayWidth_$routeKey') as double?;
      final savedHeaderOrder = pageStorage.readState(context, identifier: 'tc_headerOrder_$routeKey') as List<String>?;
      final savedHeaderVisibilityMap = pageStorage.readState(context, identifier: 'tc_headerVisibility_$routeKey') as Map<dynamic, dynamic>?;

      if (savedDense != null) _dense = savedDense;
      if (savedViewMode != null) _viewMode = savedViewMode;
      if (savedExpModeName != null) {
        _selectedExpansionMode =
            TTableExpansionMode.values.firstWhere((e) => e.name == savedExpModeName, orElse: () => effectiveExpansionMode);
      }
      if (savedCreateModeName != null) {
        _selectedCreateMode =
            TTableExpansionMode.values.firstWhere((e) => e.name == savedCreateModeName, orElse: () => effectiveCreateMode);
      }
      if (savedDialogWidth != null) _dialogWidth = savedDialogWidth;
      if (savedSideOverlayWidth != null) _sideOverlayWidth = savedSideOverlayWidth;
      if (savedCreateDialogWidth != null) _createDialogWidth = savedCreateDialogWidth;
      if (savedCreateSideOverlayWidth != null) _createSideOverlayWidth = savedCreateSideOverlayWidth;
      if (savedHeaderOrder != null && savedHeaderVisibilityMap != null) {
        _reconcileHeaders(savedHeaderOrder, Map<String, bool>.from(savedHeaderVisibilityMap));
      }
    }

    // 3. Load long-term disk state asynchronously from SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      final prefix = 'tc_cfg_$routeKey';
      final savedDense = prefs.getBool('${prefix}_dense');
      final savedViewMode = prefs.getInt('${prefix}_viewMode');
      final savedExpModeName = prefs.getString('${prefix}_expMode');
      final savedCreateModeName = prefs.getString('${prefix}_createMode');
      final savedDialogWidth = prefs.getDouble('${prefix}_dialogWidth');
      final savedSideOverlayWidth = prefs.getDouble('${prefix}_sideOverlayWidth');
      final savedCreateDialogWidth = prefs.getDouble('${prefix}_createDialogWidth');
      final savedCreateSideOverlayWidth = prefs.getDouble('${prefix}_createSideOverlayWidth');
      final savedHeaderOrderJson = prefs.getString('${prefix}_headerOrder');
      final savedHeaderVisibilityJson = prefs.getString('${prefix}_headerVisibility');

      bool changed = false;
      if (savedDense != null && savedDense != _dense) {
        _dense = savedDense;
        changed = true;
      }
      if (savedViewMode != null && savedViewMode != _viewMode) {
        _viewMode = savedViewMode;
        changed = true;
      }
      if (savedExpModeName != null) {
        final mode = TTableExpansionMode.values.firstWhere((e) => e.name == savedExpModeName, orElse: () => effectiveExpansionMode);
        if (mode != _selectedExpansionMode) {
          _selectedExpansionMode = mode;
          changed = true;
        }
      }
      if (savedCreateModeName != null) {
        final mode = TTableExpansionMode.values.firstWhere((e) => e.name == savedCreateModeName, orElse: () => effectiveCreateMode);
        if (mode != _selectedCreateMode) {
          _selectedCreateMode = mode;
          changed = true;
        }
      }
      if (savedDialogWidth != null && savedDialogWidth != _dialogWidth) {
        _dialogWidth = savedDialogWidth;
        changed = true;
      }
      if (savedSideOverlayWidth != null && savedSideOverlayWidth != _sideOverlayWidth) {
        _sideOverlayWidth = savedSideOverlayWidth;
        changed = true;
      }
      if (savedCreateDialogWidth != null && savedCreateDialogWidth != _createDialogWidth) {
        _createDialogWidth = savedCreateDialogWidth;
        changed = true;
      }
      if (savedCreateSideOverlayWidth != null && savedCreateSideOverlayWidth != _createSideOverlayWidth) {
        _createSideOverlayWidth = savedCreateSideOverlayWidth;
        changed = true;
      }
      if (savedHeaderOrderJson != null && savedHeaderVisibilityJson != null) {
        try {
          final savedHeaderOrder = List<String>.from(jsonDecode(savedHeaderOrderJson));
          final savedHeaderVisibility = Map<String, bool>.from(jsonDecode(savedHeaderVisibilityJson));
          _reconcileHeaders(savedHeaderOrder, savedHeaderVisibility);
          changed = true;
        } catch (_) {}
      }

      if (changed) {
        _persistedRouteSettings[routeKey] = (
          dense: _dense,
          viewMode: _viewMode,
          expansionMode: _selectedExpansionMode,
          createMode: _selectedCreateMode,
          dialogWidth: _dialogWidth,
          sideOverlayWidth: _sideOverlayWidth,
          createDialogWidth: _createDialogWidth,
          createSideOverlayWidth: _createSideOverlayWidth,
          headerOrder: _headerOrder,
          headerVisibility: _headerVisibility,
        );
        // ignore: invalid_use_of_protected_member
        setState(() {});
      }
    });
  }

  void _persistRouteSettings() {
    if (!(widget.config.persistSettings ?? true)) return;
    final routeKey = _resolveRouteStorageKey(context);

    _persistedRouteSettings[routeKey] = (
      dense: _dense,
      viewMode: _viewMode,
      expansionMode: _selectedExpansionMode,
      createMode: _selectedCreateMode,
      dialogWidth: _dialogWidth,
      sideOverlayWidth: _sideOverlayWidth,
      createDialogWidth: _createDialogWidth,
      createSideOverlayWidth: _createSideOverlayWidth,
      headerOrder: _headerOrder,
      headerVisibility: _headerVisibility,
    );

    final pageStorage = PageStorage.maybeOf(context);
    if (pageStorage != null) {
      pageStorage.writeState(context, _dense, identifier: 'tc_dense_$routeKey');
      pageStorage.writeState(context, _viewMode, identifier: 'tc_viewMode_$routeKey');
      if (_selectedExpansionMode != null) {
        pageStorage.writeState(context, _selectedExpansionMode!.name, identifier: 'tc_expMode_$routeKey');
      }
      if (_selectedCreateMode != null) {
        pageStorage.writeState(context, _selectedCreateMode!.name, identifier: 'tc_createMode_$routeKey');
      }
      if (_dialogWidth != null) {
        pageStorage.writeState(context, _dialogWidth, identifier: 'tc_dialogWidth_$routeKey');
      }
      if (_sideOverlayWidth != null) {
        pageStorage.writeState(context, _sideOverlayWidth, identifier: 'tc_sideOverlayWidth_$routeKey');
      }
      if (_createDialogWidth != null) {
        pageStorage.writeState(context, _createDialogWidth, identifier: 'tc_createDialogWidth_$routeKey');
      }
      if (_createSideOverlayWidth != null) {
        pageStorage.writeState(context, _createSideOverlayWidth, identifier: 'tc_createSideOverlayWidth_$routeKey');
      }
      pageStorage.writeState(context, _headerOrder, identifier: 'tc_headerOrder_$routeKey');
      pageStorage.writeState(context, _headerVisibility, identifier: 'tc_headerVisibility_$routeKey');
    }

    // 3. Save long-term disk state asynchronously to SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      final prefix = 'tc_cfg_$routeKey';
      prefs.setBool('${prefix}_dense', _dense);
      prefs.setInt('${prefix}_viewMode', _viewMode);
      if (_selectedExpansionMode != null) {
        prefs.setString('${prefix}_expMode', _selectedExpansionMode!.name);
      }
      if (_selectedCreateMode != null) {
        prefs.setString('${prefix}_createMode', _selectedCreateMode!.name);
      }
      if (_dialogWidth != null) {
        prefs.setDouble('${prefix}_dialogWidth', _dialogWidth!);
      }
      if (_sideOverlayWidth != null) {
        prefs.setDouble('${prefix}_sideOverlayWidth', _sideOverlayWidth!);
      }
      if (_createDialogWidth != null) {
        prefs.setDouble('${prefix}_createDialogWidth', _createDialogWidth!);
      }
      if (_createSideOverlayWidth != null) {
        prefs.setDouble('${prefix}_createSideOverlayWidth', _createSideOverlayWidth!);
      }
      prefs.setString('${prefix}_headerOrder', jsonEncode(_headerOrder));
      prefs.setString('${prefix}_headerVisibility', jsonEncode(_headerVisibility));
    });
  }
}
