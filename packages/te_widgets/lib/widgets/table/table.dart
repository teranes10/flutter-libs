import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

part 'table_details.dart';

/// A rich data table with responsive layout.
///
/// `TTable` displays tabular data with:
/// - Responsive design (switches to cards on mobile)
/// - Sortable, filterable columns
/// - Pagination
/// - Selection (single/multiple)
/// - Expandable rows
/// - Editable cells
/// - Async loading
///
/// ## Basic Usage
///
/// ```dart
/// TTable<User, String>(
///   headers: [
///     TTableHeader(text: 'Name', map: (user) => user.name),
///     TTableHeader(text: 'Email', map: (user) => user.email),
///   ],
///   items: users,
/// )
/// ```
///
/// ## Advanced Usage
///
/// ```dart
/// TTable<User, String>(
///   headers: [
///     TTableHeader.image('Avatar', (user) => user.avatarUrl),
///     TTableHeader(text: 'Name', map: (user) => user.name),
///     TTableHeader.actions((user) => [
///       TButton.icon(icon: Icons.edit, onPressed: () => edit(user)),
///     ]),
///   ],
///   controller: listController,
///   customTheme: myTableTheme,
/// )
/// ```
///
/// See also:
/// - [TTableHeader] for column definitions
/// - [TListController] for state management
class TTable<T, K> extends StatefulWidget with TListMixin<T, K> {
  /// Defines the columns of the table.
  final List<TTableHeader<T, K>> headers;

  /// Custom theme for the table.
  final TTableTheme? theme;

  //List
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
  @override
  final TControllerReadyListener<T, K>? onControllerReady;

  /// Detailed configuration for expansion and item info.
  final TTableDetails<T, K>? details;

  /// Whether specific cells are editable.
  final bool editable;

  /// Whether tapping on a row expands its details.
  /// If not specified, defaults to [details.expandOnRowTap] (which defaults to true).
  final bool? expandOnRowTap;

  /// Alias for [expandOnRowTap].
  final bool? rowTapDetails;

  /// Alias for [expandOnRowTap].
  final bool? onRowTapDetails;

  /// Whether text within the table and its details views is selectable. Defaults to true.
  final bool selectableText;

  // Theme overrides

  /// Grid layout mode.
  final TGridMode? grid;

  /// Delegate for controlling grid layout.
  final TGridDelegateBuilder? gridDelegate;

  /// Whether the table should shrink-wrap its content.
  final bool? shrinkWrap;

  /// Custom header widget.
  final TListHeaderBuilder? headerBuilder;

  /// Custom footer widget.
  final TListFooterBuilder? footerBuilder;

  /// Whether to enable infinite scroll.
  final bool? infiniteScroll;

  /// Whether the header should be sticky.
  final bool? headerSticky;

  /// Whether the footer should be sticky.
  final bool? footerSticky;

  /// Whether to use dense layout (less padding).
  final bool? dense;

  /// Custom builder for the row.
  ///
  /// If provided, this builder is called for each row and can be used to
  /// wrap or replace the default row card.
  final Widget Function(BuildContext ctx, TListItem<T, K> item, int index, Widget row)? rowBuilder;

  /// Builder for content before the list items.
  final WidgetBuilder? beforeItemsBuilder;

  /// Custom builder for the row background color.
  final Color? Function(TListItem<T, K> item, int index)? rowColorBuilder;

  /// Custom builder to retrieve a validation error for a given row and column.
  final String? Function(T data, String column)? cellErrorBuilder;

  /// Optional static map of cell errors.
  final Map<String, String>? cellErrors;

  /// Optional notifier for dynamic cell errors.
  final ValueNotifier<Map<String, String>>? cellErrorsNotifier;

  /// Creates a data table.
  const TTable({
    super.key,
    required this.headers,
    this.theme,
    //List
    this.items,
    this.itemsPerPage,
    this.search,
    this.searchDelay,
    this.onLoad,
    this.itemKey,
    this.controller,
    this.onControllerReady,
    //Details
    this.details,
    this.editable = false,
    this.cellErrorBuilder,
    this.cellErrors,
    this.cellErrorsNotifier,
    this.expandOnRowTap,
    this.rowTapDetails,
    this.onRowTapDetails,
    this.selectableText = true,
    // Theme overrides
    this.grid,
    this.gridDelegate,
    this.shrinkWrap,
    this.headerBuilder,
    this.footerBuilder,
    this.infiniteScroll,
    this.headerSticky,
    this.footerSticky,
    this.dense,
    this.rowBuilder,
    this.rowColorBuilder,
    this.beforeItemsBuilder,
  }) : assert(
          theme == null ||
              (grid == null &&
                  gridDelegate == null &&
                  shrinkWrap == null &&
                  headerBuilder == null &&
                  footerBuilder == null &&
                  infiniteScroll == null &&
                  headerSticky == null &&
                  footerSticky == null &&
                  dense == null),
          'Cannot provide both theme and individual theme properties.',
        );

  @override
  State<TTable<T, K>> createState() => _TTableState<T, K>();
}

class _TTableState<T, K> extends State<TTable<T, K>> with TListStateMixin<T, K, TTable<T, K>> {
  TTableTheme? _cachedTheme;
  TTable<T, K>? _cachedThemeForWidget;

  TTableTheme get wTheme {
    if (_cachedTheme != null && _cachedThemeForWidget == widget) {
      return _cachedTheme!;
    }
    final resolved = _resolveTheme();
    _cachedTheme = resolved;
    _cachedThemeForWidget = widget;
    return resolved;
  }

  List<TTableHeader<T, K>> get _effectiveHeaders {
    final order = listController.headerOrder;
    final visibility = listController.headerVisibility;
    if (order.isEmpty) {
      return widget.headers.where((h) => visibility[h.text] ?? true).toList();
    }

    final orderedVisibleHeaders = <TTableHeader<T, K>>[];
    for (final text in order) {
      if (visibility[text] ?? true) {
        final index = widget.headers.indexWhere((h) => h.text == text);
        if (index != -1) {
          orderedVisibleHeaders.add(widget.headers[index]);
        }
      }
    }
    // Also include any headers that are not in headerOrder (e.g. actions column)
    for (final h in widget.headers) {
      if (!order.contains(h.text)) {
        if (visibility[h.text] ?? true) {
          orderedVisibleHeaders.add(h);
        }
      }
    }
    return orderedVisibleHeaders;
  }

  bool _headersEquals(List<TTableHeader<T, K>> a, List<TTableHeader<T, K>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].text != b[i].text) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Column-width memoisation
  // ---------------------------------------------------------------------------

  /// Cached column measurements — the expensive step (text layout over a
  /// data sample). Only recomputed when headers, selection/expansion mode,
  /// tree depth, or the underlying data actually change. Turning this into
  /// either the required-width threshold or final per-column pixel widths
  /// for a given width is then pure arithmetic — see
  /// [TTableColumnMeasurements.resolve] — so resizing doesn't re-measure text.
  TTableColumnMeasurements? _cachedMeasurements;
  List<TTableHeader<T, K>>? _cachedMeasurementsForHeaders;
  bool? _cachedMeasurementsSelectable;
  bool? _cachedMeasurementsExpandable;
  int? _cachedMeasurementsMaxLevel;
  bool? _cachedMeasurementsIsHierarchical;
  List<TListItem<T, K>>? _cachedMeasurementsForItems;

  int _getMaxTreeLevel() {
    int maxLevel = 0;
    for (final item in listController.value.displayItems) {
      if (item.level > maxLevel) maxLevel = item.level;
    }
    return maxLevel;
  }

  bool _itemsEquals(List<TListItem<T, K>>? a, List<TListItem<T, K>>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    final sampleCount = math.min(a.length, 50);
    for (int i = 0; i < sampleCount; i++) {
      if (a[i].key != b[i].key || a[i].data != b[i].data) return false;
    }
    return true;
  }

  TTableColumnMeasurements _getMeasurements() {
    final headers = _effectiveHeaders;
    final selectable = listController.selectable;
    final expandable = listController.expandable;
    final maxLevel = _getMaxTreeLevel();
    final isHierarchical = listController.isHierarchical;
    final displayItems = listController.value.displayItems;

    if (_cachedMeasurements != null &&
        _cachedMeasurementsForHeaders != null &&
        _headersEquals(_cachedMeasurementsForHeaders!, headers) &&
        _cachedMeasurementsSelectable == selectable &&
        _cachedMeasurementsExpandable == expandable &&
        _cachedMeasurementsMaxLevel == maxLevel &&
        _cachedMeasurementsIsHierarchical == isHierarchical &&
        _itemsEquals(_cachedMeasurementsForItems, displayItems)) {
      return _cachedMeasurements!;
    }

    final sampleItems = displayItems.take(50).map((e) => e.data).toList();
    final measurements = TTableTheme.measureColumns<T, K>(
      headers,
      selectable,
      expandable,
      maxTreeLevel: maxLevel,
      isHierarchical: isHierarchical,
      sampleItems: sampleItems,
      headerTextStyle: wTheme.headerTheme.textStyle,
      contentTextStyle: wTheme.rowCardTheme.contentTextStyle,
    );

    _cachedMeasurements = measurements;
    _cachedMeasurementsForHeaders = headers;
    _cachedMeasurementsSelectable = selectable;
    _cachedMeasurementsExpandable = expandable;
    _cachedMeasurementsMaxLevel = maxLevel;
    _cachedMeasurementsIsHierarchical = isHierarchical;
    _cachedMeasurementsForItems = List<TListItem<T, K>>.of(displayItems);
    return measurements;
  }

  double _getRequiredWidth() => _getMeasurements().requiredWidth;

  Map<int, TableColumnWidth> _getColumnWidths(double availableWidth) => _getMeasurements().resolve(availableWidth);

  TTableTheme _resolveTheme() {
    TTableTheme theme = widget.theme ?? context.theme.tableTheme;

    theme = theme.copyWith(
      grid: widget.grid,
      gridDelegate: widget.gridDelegate,
      shrinkWrap: widget.shrinkWrap,
      headerBuilder: widget.headerBuilder,
      footerBuilder: widget.footerBuilder,
      infiniteScroll: widget.infiniteScroll,
      headerSticky: widget.headerSticky,
      footerSticky: widget.footerSticky,
      dense: widget.dense,
    );

    if (theme.dense == true) {
      theme = theme.copyWith(
        headerTheme: theme.headerTheme.copyWith(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4)),
        rowCardTheme: theme.rowCardTheme.copyWith(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          margin: const EdgeInsets.symmetric(vertical: 1),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        mobileCardTheme: theme.mobileCardTheme.copyWith(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.only(bottom: 2),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          vSpacing: 4,
          hSpacing: 8,
          gap: 2,
        ),
      );
    }
    return theme;
  }

  late final ValueNotifier<String?>? _activeCellNotifier;

  @override
  TListController<T, K> buildController() {
    final hasBuilder = widget.details?.builder != null || widget.details?.createBuilder != null;
    return TListController<T, K>(
      items: widget.items ?? [],
      itemsPerPage: widget.itemsPerPage ?? 0,
      search: widget.search ?? '',
      searchDelay: widget.searchDelay,
      onLoad: widget.onLoad,
      itemKey: widget.itemKey,
      expansionMode: hasBuilder ? TExpansionMode.single : TExpansionMode.none,
      autoExpandFirst: widget.details?.autoExpandFirst ?? false,
      autoSelectFirst: widget.details?.autoSelectFirst ?? false,
    );
  }

  @override
  void initState() {
    super.initState();
    _activeCellNotifier = widget.editable ? ValueNotifier<String?>(null) : null;
    _validateExpansionMode();
  }

  @override
  void didUpdateWidget(covariant TTable<T, K> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cachedTheme = null;
    if (oldWidget.headers != widget.headers || oldWidget.controller != widget.controller) {
      _cachedMeasurements = null;
    }
    // items/search/itemsPerPage sync is handled automatically by TListStateMixin.didUpdateWidget.
    // Handle table-details-specific updates (expansion mode changes, overlay dismissal).
    _handleDetailsDidUpdateWidget(oldWidget);
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _activeCellNotifier?.dispose();
    super.dispose();
  }

  _ActiveDetailTarget<K>? _currentTarget;

  @override
  void onListStateChanged() {
    super.onListStateChanged();
    _syncDetailFlow();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    _cachedTheme = null;
    final colors = context.colors;

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        if (effectiveExpansionMode == TTableExpansionMode.side) {
          final hasBuilder = widget.details?.builder != null || widget.details?.createBuilder != null;
          if ((listController.value.activeKey != null || listController.value.isCreatingItem || listController.value.isEditingItem) &&
              hasBuilder) {
            return _buildSideLayout(colors, constraints);
          }
        }

        // Only compute requiredWidth here (inside LayoutBuilder) so we have
        // access to constraints.maxWidth for cache invalidation.
        final requiredWidth = _getRequiredWidth();
        final shouldShowCardView = wTheme.forceCardStyle == true || wTheme.grid != null || constraints.maxWidth < requiredWidth;
        final view = shouldShowCardView ? _buildCardView(colors, constraints) : _buildTableView(colors, constraints);
        return TTableScope(
          controller: listController,
          theme: wTheme,
          dense: wTheme.dense ?? false,
          isCardView: shouldShowCardView,
          expansionMode: effectiveExpansionMode,
          onWillCollapse: widget.details?.onWillCollapse != null ? (dynamic key) => widget.details!.onWillCollapse!(key as K) : null,
          child: view,
        );
      },
    );

    Widget scopedContent = TTableScope(
      controller: listController,
      theme: wTheme,
      dense: wTheme.dense ?? false,
      isCardView: false,
      expansionMode: effectiveExpansionMode,
      onWillCollapse: widget.details?.onWillCollapse != null ? (dynamic key) => widget.details!.onWillCollapse!(key as K) : null,
      child: content,
    );

    // Wrap with TTableCellScope only when editable or when cell errors are present
    // so that cell-activation and cell-error rebuilds are bounded to subscribing cells only.
    if (_activeCellNotifier != null || widget.cellErrorBuilder != null || widget.cellErrors != null || widget.cellErrorsNotifier != null) {
      scopedContent = TTableCellScope(
        activeCellNotifier: _activeCellNotifier ?? ValueNotifier<String?>(null),
        cellErrorBuilder: widget.cellErrorBuilder != null ? (dynamic data, String col) => widget.cellErrorBuilder!(data as T, col) : null,
        cellErrors: widget.cellErrors,
        errorsNotifier: widget.cellErrorsNotifier,
        child: scopedContent,
      );
    }

    if (widget.selectableText) {
      scopedContent = SelectionArea(
        child: scopedContent,
      );
    }

    return scopedContent;
  }

  Widget _buildListScaffold({
    required Widget Function(BuildContext ctx) headerContent,
    required Widget Function(BuildContext ctx, TListItem<T, K> item, int index) itemBuilder,
  }) {
    return TList<T, K>(
      theme: wTheme.copyWith(
        headerBuilder: (ctx) => _wrapWithFocusDimmer(ctx, headerContent(ctx)),
        footerBuilder: wTheme.footerBuilder == null ? null : (ctx) => _wrapWithFocusDimmer(ctx, wTheme.footerBuilder!(ctx)),
      ),
      beforeItemsBuilder: _buildCreateFormBeforeItems,
      controller: listController,
      itemBuilder: (ctx, item, index) {
        final row = itemBuilder(ctx, item, index);
        Widget finalRow = widget.rowBuilder?.call(ctx, item, index, row) ?? row;
        if (useExpansionFocus || shouldDimOthers) {
          finalRow = _buildFocusRowWrapper(item.key, finalRow, _isInlineExpanded(item));
        }
        return finalRow;
      },
    );
  }

  Widget _buildTableView(ColorScheme colors, BoxConstraints constraints) {
    final columnWidths = _getColumnWidths(constraints.maxWidth);

    return _buildListScaffold(
      headerContent: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wTheme.headerBuilder != null) wTheme.headerBuilder!(ctx),
          TTableRowHeader<T, K>(theme: wTheme.headerTheme, headers: widget.headers, controller: listController, columnWidths: columnWidths),
        ],
      ),
      itemBuilder: (ctx, item, index) => _buildRowCard(columnWidths, ctx, item, index),
    );
  }

  Widget _buildCardView(ColorScheme colors, BoxConstraints constraints) {
    return _buildListScaffold(
      headerContent: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [if (wTheme.headerBuilder != null) wTheme.headerBuilder!(ctx)],
      ),
      itemBuilder: (ctx, item, index) => _buildMobileCard(ctx, item, index),
    );
  }

  Widget _buildCreateFormBeforeItems(BuildContext ctx) {
    final isCreating = listController.value.isCreatingItem;
    final hasCreateBuilder = widget.details?.createBuilder != null;
    if (isCreating && effectiveExpansionMode == TTableExpansionMode.bottom && hasCreateBuilder) {
      final content = widget.details!.createBuilder!(ctx, null, null);
      final wrappedContent = getLayoutWrapper(ctx, widget.details!, true, false, null, content);

      Widget finalContent = wrappedContent;
      if (useExpansionFocus || shouldDimOthers) {
        finalContent = TScrollTop(
          key: const ValueKey('focus_create_form'),
          child: wrappedContent,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.beforeItemsBuilder != null) widget.beforeItemsBuilder!(ctx),
          finalContent,
          const SizedBox(height: 12),
        ],
      );
    }
    return widget.beforeItemsBuilder?.call(ctx) ?? const SizedBox.shrink();
  }

  bool get shouldDimOthers =>
      (useExpansionFocus && listController.value.expandedDetailKey != null) ||
      (effectiveExpansionMode == TTableExpansionMode.bottom && listController.value.isCreatingItem);

  Widget _wrapWithFocusDimmer(BuildContext context, Widget child) {
    if (!useExpansionFocus && !shouldDimOthers) return child;
    return ListenableBuilder(
      listenable: listController,
      builder: (ctx, childWidget) {
        return TScrollTop.activeOrOpacity(
          child: childWidget!,
          active: false,
          anyActive: shouldDimOthers,
          opacity: widget.details?.dimmedOpacity ?? 0.4,
        );
      },
      child: child,
    );
  }

  Widget _buildFocusRowWrapper(dynamic key, Widget child, bool active) {
    return ListenableBuilder(
      listenable: listController,
      builder: (ctx, rowChild) {
        return TScrollTop.activeOrOpacity(
          child: rowChild!,
          active: active,
          anyActive: shouldDimOthers,
          opacity: widget.details?.dimmedOpacity ?? 0.4,
          key: ValueKey('focus_$key'),
        );
      },
      child: child,
    );
  }

  Future<void> _handleExpansionTap(K key, bool expanding) async {
    if (expanding) {
      if (widget.details?.onWillExpand != null) {
        final allowed = await widget.details!.onWillExpand!(key);
        if (!allowed) return;
      }

      listController.expandDetail(key);
    } else {
      if (widget.details?.onWillCollapse != null) {
        final allowed = await widget.details!.onWillCollapse!(key);
        if (!allowed) return;
      }

      listController.collapseDetail();
    }
  }

  /// True if [item] should render its expanded/edit content inline (bottom mode),
  /// covering both plain expansion and an active edit-in-place.
  bool _isInlineExpanded(TListItem<T, K> item) {
    final target = _computeDesiredTarget();
    final isEditingThisInline = target?.kind == _DetailKind.edit && target?.mode == TTableExpansionMode.bottom && target?.key == item.key;
    final isExpandedContent = listController.value.expandedDetailKey == item.key;
    return isExpandedContent || isEditingThisInline;
  }

  Widget? _resolveExpandedContent(BuildContext ctx, TListItem<T, K> item, int index) {
    final target = _computeDesiredTarget();
    final mode = widget.details?.mode ?? TTableExpansionMode.bottom;
    final details = widget.details;

    final isEditingThisInline = target?.kind == _DetailKind.edit && target?.mode == TTableExpansionMode.bottom && target?.key == item.key;
    if (isEditingThisInline) {
      final content = details?.createBuilder?.call(ctx, item, index);
      if (content == null || details == null) return null;
      return TTableDetailsScope(
        mode: TTableExpansionMode.bottom,
        isEditing: true,
        child: getLayoutWrapper(ctx, details, false, true, item.data, content),
      );
    }
    if (listController.value.expandedDetailKey == item.key && mode == TTableExpansionMode.bottom) {
      final content = details?.builder?.call(ctx, item, index) ?? wTheme.buildDefaultExpandedContent(ctx.colors, item.data, index);
      if (details == null) {
        return TTableDetailsScope(
          mode: TTableExpansionMode.bottom,
          child: content,
        );
      }
      return TTableDetailsScope(
        mode: TTableExpansionMode.bottom,
        child: getLayoutWrapper(ctx, details, false, false, item.data, content),
      );
    }
    return null;
  }

  bool get _expandOnRowTap =>
      widget.expandOnRowTap ??
      widget.rowTapDetails ??
      widget.onRowTapDetails ??
      widget.details?.expandOnRowTap ??
      widget.details?.rowTapDetails ??
      true;

  TTableRowCard<T, K> _buildRowCard(Map<int, TableColumnWidth> columnWidths, BuildContext ctx, TListItem<T, K> item, int index) {
    final onRowTap = (listController.expandable && _expandOnRowTap)
        ? () => _handleExpansionTap(item.key, listController.value.expandedDetailKey != item.key)
        : null;

    return TTableRowCard<T, K>(
      index: index,
      item: item,
      headers: _effectiveHeaders,
      theme: wTheme.rowCardTheme,
      width: wTheme.cardWidth,
      columnWidths: columnWidths,
      expandable: listController.expandable,
      isExpanded: listController.isExpanded(item.key),
      isDetailExpanded: _isInlineExpanded(item),
      expansionMode: effectiveExpansionMode,
      expandSide: effectiveExpansionMode == TTableExpansionMode.side,
      onExpansionChanged: () => _handleExpansionTap(item.key, listController.value.expandedDetailKey != item.key),
      expandedContent: _resolveExpandedContent(ctx, item, index),
      selectable: listController.selectable,
      isSelected: listController.isSelected(item.key),
      onSelectionChanged: () => listController.toggleSelection(item.key),
      onTap: onRowTap,
      expandIcon: widget.details?.expandIcon,
      collapseIcon: widget.details?.collapseIcon,
      backgroundColor: widget.rowColorBuilder?.call(item, index),
    );
  }

  TTableMobileCard<T, K> _buildMobileCard(BuildContext ctx, TListItem<T, K> item, int index) {
    final onRowTap = (listController.expandable && _expandOnRowTap)
        ? () => _handleExpansionTap(item.key, listController.value.expandedDetailKey != item.key)
        : null;

    return TTableMobileCard<T, K>(
      index: index,
      item: item,
      headers: _effectiveHeaders,
      theme: wTheme.mobileCardTheme,
      width: wTheme.cardWidth,
      expandable: listController.expandable,
      isExpanded: listController.isExpanded(item.key),
      isDetailExpanded: _isInlineExpanded(item),
      expansionMode: effectiveExpansionMode,
      expandSide: effectiveExpansionMode == TTableExpansionMode.side,
      onExpansionChanged: () => _handleExpansionTap(item.key, listController.value.expandedDetailKey != item.key),
      expandedContent: _resolveExpandedContent(ctx, item, index),
      selectable: listController.selectable,
      isSelected: listController.isSelected(item.key),
      onSelectionChanged: () => listController.toggleSelection(item.key),
      onTap: onRowTap,
      expandIcon: widget.details?.expandIcon,
      collapseIcon: widget.details?.collapseIcon,
      backgroundColor: widget.rowColorBuilder?.call(item, index),
    );
  }
}
