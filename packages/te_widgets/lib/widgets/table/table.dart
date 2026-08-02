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

  // ---------------------------------------------------------------------------
  // Column-width memoisation
  // ---------------------------------------------------------------------------

  /// Cached total required width used to decide card vs table view.
  /// Keyed on [_cachedRequiredWidthForHeaders] + [_cachedRequiredWidthForConstraint]
  /// so it re-evaluates when headers or the available width changes.
  double? _cachedRequiredWidth;
  List<TTableHeader<T, K>>? _cachedRequiredWidthForHeaders;
  bool? _cachedRequiredWidthSelectable;
  bool? _cachedRequiredWidthExpandable;
  int? _cachedRequiredWidthMaxLevel;

  int _getMaxTreeLevel() {
    int maxLevel = 0;
    for (final item in listController.value.displayItems) {
      if (item.level > maxLevel) maxLevel = item.level;
    }
    return maxLevel;
  }

  double _getRequiredWidth() {
    final selectable = listController.selectable;
    final expandable = listController.expandable;
    final maxLevel = _getMaxTreeLevel();
    if (_cachedRequiredWidth != null &&
        _cachedRequiredWidthForHeaders == widget.headers &&
        _cachedRequiredWidthSelectable == selectable &&
        _cachedRequiredWidthExpandable == expandable &&
        _cachedRequiredWidthMaxLevel == maxLevel) {
      return _cachedRequiredWidth!;
    }
    final width = TTableTheme.calculateTotalRequiredWidth(widget.headers, selectable, expandable, maxTreeLevel: maxLevel);
    _cachedRequiredWidth = width;
    _cachedRequiredWidthForHeaders = widget.headers;
    _cachedRequiredWidthSelectable = selectable;
    _cachedRequiredWidthExpandable = expandable;
    _cachedRequiredWidthMaxLevel = maxLevel;
    return width;
  }

  /// Cached per-column widths used when rendering the table view.
  Map<int, TableColumnWidth>? _cachedColumnWidths;
  List<TTableHeader<T, K>>? _cachedColumnWidthsForHeaders;
  bool? _cachedColumnWidthsSelectable;
  bool? _cachedColumnWidthsExpandable;
  int? _cachedColumnWidthsMaxLevel;

  Map<int, TableColumnWidth> _getColumnWidths() {
    final selectable = listController.selectable;
    final expandable = listController.expandable;
    final maxLevel = _getMaxTreeLevel();
    if (_cachedColumnWidths != null &&
        _cachedColumnWidthsForHeaders == widget.headers &&
        _cachedColumnWidthsSelectable == selectable &&
        _cachedColumnWidthsExpandable == expandable &&
        _cachedColumnWidthsMaxLevel == maxLevel) {
      return _cachedColumnWidths!;
    }
    final widths = TTableTheme.calculateColumnWidths(widget.headers, selectable, expandable, maxTreeLevel: maxLevel);
    _cachedColumnWidths = widths;
    _cachedColumnWidthsForHeaders = widget.headers;
    _cachedColumnWidthsSelectable = selectable;
    _cachedColumnWidthsExpandable = expandable;
    _cachedColumnWidthsMaxLevel = maxLevel;
    return widths;
  }

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
    // Invalidate column-width caches when headers or controller identity changes.
    if (oldWidget.headers != widget.headers || oldWidget.controller != widget.controller) {
      _cachedRequiredWidth = null;
      _cachedColumnWidths = null;
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
        return shouldShowCardView ? _buildCardView(colors, constraints) : _buildTableView(colors, constraints);
      },
    );

    Widget scopedContent = TTableScope(
      controller: listController,
      dense: wTheme.dense ?? false,
      expansionMode: effectiveExpansionMode,
      onWillCollapse: widget.details?.onWillCollapse != null ? (dynamic key) => widget.details!.onWillCollapse!(key as K) : null,
      child: content,
    );

    // Wrap with TTableCellScope only when editable so that cell-activation
    // rebuilds are bounded to subscribing editable cells only.
    if (_activeCellNotifier != null) {
      scopedContent = TTableCellScope(
        notifier: _activeCellNotifier!,
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
    final columnWidths = _getColumnWidths();

    return _buildListScaffold(
      headerContent: (ctx) => Column(
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
    } else {
      if (widget.details?.onWillCollapse != null) {
        final allowed = await widget.details!.onWillCollapse!(key);
        if (!allowed) return;
      }
    }
    listController.toggleContentKey(key);
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

  TTableRowCard<T, K> _buildRowCard(Map<int, TableColumnWidth> columnWidths, BuildContext ctx, TListItem<T, K> item, int index) {
    return TTableRowCard<T, K>(
      index: index,
      item: item,
      headers: widget.headers,
      theme: wTheme.rowCardTheme,
      width: wTheme.cardWidth,
      columnWidths: columnWidths,
      expandable: listController.expandable,
      isExpanded: _isInlineExpanded(item),
      expansionMode: effectiveExpansionMode,
      expandSide: effectiveExpansionMode == TTableExpansionMode.side,
      onExpansionChanged: () => _handleExpansionTap(item.key, listController.value.expandedDetailKey != item.key),
      expandedContent: _resolveExpandedContent(ctx, item, index),
      selectable: listController.selectable,
      isSelected: listController.isSelected(item.key),
      onSelectionChanged: () => listController.toggleSelection(item.key),
      backgroundColor: widget.rowColorBuilder?.call(item, index),
    );
  }

  TTableMobileCard<T, K> _buildMobileCard(BuildContext ctx, TListItem<T, K> item, int index) {
    return TTableMobileCard<T, K>(
      index: index,
      item: item,
      headers: widget.headers,
      theme: wTheme.mobileCardTheme,
      width: wTheme.cardWidth,
      expandable: listController.expandable,
      isExpanded: _isInlineExpanded(item),
      expandSide: effectiveExpansionMode == TTableExpansionMode.side,
      onExpansionChanged: () => _handleExpansionTap(item.key, listController.value.expandedDetailKey != item.key),
      expandedContent: _resolveExpandedContent(ctx, item, index),
      selectable: listController.selectable,
      isSelected: listController.isSelected(item.key),
      onSelectionChanged: () => listController.toggleSelection(item.key),
      backgroundColor: widget.rowColorBuilder?.call(item, index),
    );
  }
}
