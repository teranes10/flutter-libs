part of 'crud_table.dart';

extension _TCrudTableSettingsExt<T, K, F extends TFormBase> on _TCrudTableState<T, K, F> {
  static final Map<
      String,
      ({
        bool? dense,
        int? viewMode,
        TTableExpansionMode? expansionMode,
        TTableExpansionMode? createMode,
        TKeyValueMode? cardKeyValueMode,
        double? dialogWidth,
        double? sideOverlayWidth,
        double? createDialogWidth,
        double? createSideOverlayWidth,
        List<String>? headerOrder,
        Map<String, bool>? headerVisibility,
        Map<String, double>? rowHeights,
      })> _persistedRouteSettings = {};

  String? _findRouteName(BuildContext context) {
    final modalRouteName = ModalRoute.of(context)?.settings.name;
    if (modalRouteName != null && modalRouteName.isNotEmpty && modalRouteName != '/') {
      return modalRouteName;
    }

    // GoRouterState.of loops forever when the route was pushed imperatively
    // (e.g. hierarchy child pages) because it is not a go_router Page.
    final route = ModalRoute.of(context);
    try {
      if (route != null && route.settings is! Page<Object?>) return modalRouteName;
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
      if (cached.cardKeyValueMode != null) _cardKeyValueMode = cached.cardKeyValueMode;
      if (cached.dialogWidth != null) _dialogWidth = cached.dialogWidth;
      if (cached.sideOverlayWidth != null) _sideOverlayWidth = cached.sideOverlayWidth;
      if (cached.createDialogWidth != null) _createDialogWidth = cached.createDialogWidth;
      if (cached.createSideOverlayWidth != null) _createSideOverlayWidth = cached.createSideOverlayWidth;
      if (cached.rowHeights != null) _rowHeights = Map<String, double>.of(cached.rowHeights!);
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
      final savedCardKvModeName = pageStorage.readState(context, identifier: 'tc_cardKvMode_$routeKey') as String?;
      final savedDialogWidth = pageStorage.readState(context, identifier: 'tc_dialogWidth_$routeKey') as double?;
      final savedSideOverlayWidth = pageStorage.readState(context, identifier: 'tc_sideOverlayWidth_$routeKey') as double?;
      final savedCreateDialogWidth = pageStorage.readState(context, identifier: 'tc_createDialogWidth_$routeKey') as double?;
      final savedCreateSideOverlayWidth = pageStorage.readState(context, identifier: 'tc_createSideOverlayWidth_$routeKey') as double?;
      final savedHeaderOrder = pageStorage.readState(context, identifier: 'tc_headerOrder_$routeKey') as List<String>?;
      final savedHeaderVisibilityMap =
          pageStorage.readState(context, identifier: 'tc_headerVisibility_$routeKey') as Map<dynamic, dynamic>?;

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
      if (savedCardKvModeName != null) {
        _cardKeyValueMode = TKeyValueMode.values.firstWhere((e) => e.name == savedCardKvModeName, orElse: () => cardKeyValueMode);
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
      final savedCardKvModeName = prefs.getString('${prefix}_cardKvMode');
      final savedDialogWidth = prefs.getDouble('${prefix}_dialogWidth');
      final savedSideOverlayWidth = prefs.getDouble('${prefix}_sideOverlayWidth');
      final savedCreateDialogWidth = prefs.getDouble('${prefix}_createDialogWidth');
      final savedCreateSideOverlayWidth = prefs.getDouble('${prefix}_createSideOverlayWidth');
      final savedHeaderOrderJson = prefs.getString('${prefix}_headerOrder');
      final savedHeaderVisibilityJson = prefs.getString('${prefix}_headerVisibility');
      final savedRowHeightsJson = prefs.getString('${prefix}_rowHeights');

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
      if (savedCardKvModeName != null) {
        final mode = TKeyValueMode.values.firstWhere((e) => e.name == savedCardKvModeName, orElse: () => cardKeyValueMode);
        if (mode != _cardKeyValueMode) {
          _cardKeyValueMode = mode;
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

      if (savedRowHeightsJson != null) {
        try {
          final saved = (jsonDecode(savedRowHeightsJson) as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble()));
          // Heights measured this session win over the stored ones.
          _rowHeights = {...saved, ..._rowHeights};
          changed = true;
        } catch (_) {}
      }

      final restoredActive = _decodeFilters(prefs.getString('${prefix}_filters_active'));
      final restoredArchive = _decodeFilters(prefs.getString('${prefix}_filters_archive'));
      if (restoredActive != null && restoredActive.isNotEmpty) _listController.handleAdvancedSearchChange(restoredActive);
      if (restoredArchive != null && restoredArchive.isNotEmpty) _archiveListController.handleAdvancedSearchChange(restoredArchive);

      if (changed) {
        _persistedRouteSettings[routeKey] = (
          dense: _dense,
          viewMode: _viewMode,
          expansionMode: _selectedExpansionMode,
          createMode: _selectedCreateMode,
          cardKeyValueMode: _cardKeyValueMode,
          dialogWidth: _dialogWidth,
          sideOverlayWidth: _sideOverlayWidth,
          createDialogWidth: _createDialogWidth,
          createSideOverlayWidth: _createSideOverlayWidth,
          headerOrder: _headerOrder,
          headerVisibility: _headerVisibility,
          rowHeights: _rowHeights,
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
      cardKeyValueMode: _cardKeyValueMode,
      dialogWidth: _dialogWidth,
      sideOverlayWidth: _sideOverlayWidth,
      createDialogWidth: _createDialogWidth,
      createSideOverlayWidth: _createSideOverlayWidth,
      headerOrder: _headerOrder,
      headerVisibility: _headerVisibility,
      rowHeights: _rowHeights,
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
      if (_cardKeyValueMode != null) {
        pageStorage.writeState(context, _cardKeyValueMode!.name, identifier: 'tc_cardKvMode_$routeKey');
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
      if (_cardKeyValueMode != null) {
        prefs.setString('${prefix}_cardKvMode', _cardKeyValueMode!.name);
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
      prefs.setString('${prefix}_rowHeights', jsonEncode(_rowHeights));
    });
  }

  Map<String, dynamic>? _decodeFilters(String? json) {
    if (json == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(json) as Map);
    } catch (_) {
      return null;
    }
  }

  /// Saves the advanced filters of both lists so they survive reloads.
  void _persistFilters() {
    if (!(widget.config.persistSettings ?? true)) return;
    final prefix = 'tc_cfg_${_resolveRouteStorageKey(context)}';
    final active = _listController.value.advancedSearch ?? const {};
    final archive = _archiveListController.value.advancedSearch ?? const {};
    SharedPreferences.getInstance().then((prefs) {
      for (final e in {'active': active, 'archive': archive}.entries) {
        final key = '${prefix}_filters_${e.key}';
        if (e.value.isEmpty) {
          prefs.remove(key);
        } else {
          try {
            prefs.setString(key, jsonEncode(e.value));
          } catch (_) {}
        }
      }
    });
  }

  /// Key of the remembered row height for a layout at a width; widths are bucketed to 100px.
  static String _rowHeightPrefix(bool isCardView, bool dense) => '${isCardView ? 'card' : 'row'}_${dense ? 'dense' : 'comfortable'}_';

  static int _widthBucket(double width) => (width / 100).round() * 100;

  /// The remembered measurement for the closest width recorded for this layout, so widths that behave alike
  /// (same column wrapping) share one answer without having to be measured individually.
  TItemHeightSample? _rowHeightHint(bool isCardView, bool dense, double width) {
    final prefix = _rowHeightPrefix(isCardView, dense);
    String? bestKey;
    int bestDistance = 1 << 30;
    final bucket = _widthBucket(width);
    for (final key in _rowHeights.keys) {
      if (!key.startsWith(prefix) || key.endsWith('_chrome')) continue;
      final recorded = int.tryParse(key.substring(prefix.length));
      if (recorded == null) continue;
      final distance = (recorded - bucket).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestKey = key;
      }
    }
    if (bestKey == null) return null;
    return (item: _rowHeights[bestKey]!, chrome: _rowHeights['${bestKey}_chrome'] ?? 0);
  }

  /// Folds a measurement into the running average of its layout and width bucket (always, even when a value is
  /// already stored, so the estimate keeps improving) and persists it.
  void _recordRowHeight(bool isCardView, bool dense, double width, double item, double chrome) {
    final key = '${_rowHeightPrefix(isCardView, dense)}${_widthBucket(width)}';
    final oldItem = _rowHeights[key];
    final oldChrome = _rowHeights['${key}_chrome'];
    final nextItem = oldItem == null ? item : (oldItem + item) / 2;
    final nextChrome = oldChrome == null ? chrome : (oldChrome + chrome) / 2;
    if (oldItem != null && oldChrome != null && (nextItem - oldItem).abs() < 0.5 && (nextChrome - oldChrome).abs() < 0.5) return;
    _rowHeights[key] = nextItem;
    _rowHeights['${key}_chrome'] = nextChrome;
    _persistRouteSettings();
  }
}
