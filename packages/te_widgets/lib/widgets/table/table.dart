import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

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

  // Expandable configuration
  /// Builder for expanded content of a row.
  final TListExpandedBuilder<T, K>? expandedBuilder;

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
    //Expandable
    this.expandedBuilder,
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
  TTableTheme get wTheme {
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
            borderRadius: const BorderRadius.all(Radius.circular(4))),
      );
    }

    return theme;
  }

  late final ValueNotifier<String?>? _activeCellNotifier;

  @override
  void initState() {
    super.initState();
    _activeCellNotifier = widget.editable ? ValueNotifier<String?>(null) : null;
  }

  @override
  void dispose() {
    _activeCellNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final requiredWidth = TTableTheme.calculateTotalRequiredWidth(widget.headers, listController.selectable, listController.expandable);

    return TTableScope(
      controller: listController,
      activeCellNotifier: _activeCellNotifier,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldShowCardView = wTheme.forceCardStyle == true || wTheme.grid != null || constraints.maxWidth < requiredWidth;
          return shouldShowCardView ? _buildCardView(colors, constraints) : _buildTableView(colors, constraints);
        },
      ),
    );
  }

  Widget _buildTableView(ColorScheme colors, BoxConstraints constraints) {
    final columnWidths = TTableTheme.calculateColumnWidths(widget.headers, listController.selectable, listController.expandable);

    return TList<T, K>(
      theme: wTheme.copyWith(
        headerBuilder: (ctx) => Column(
          children: [
            if (wTheme.headerBuilder != null) wTheme.headerBuilder!(ctx),
            TTableRowHeader<T, K>(
              theme: wTheme.headerTheme,
              headers: widget.headers,
              controller: listController,
              columnWidths: columnWidths,
            ),
          ],
        ),
      ),
      beforeItemsBuilder: widget.beforeItemsBuilder,
      controller: listController,
      itemBuilder: (ctx, item, index) {
        final row = _buildRowCard(columnWidths, ctx, item, index);
        return widget.rowBuilder?.call(ctx, item, index, row) ?? row;
      },
    );
  }

  Widget _buildCardView(ColorScheme colors, BoxConstraints constraints) {
    return TList<T, K>(
      theme: wTheme,
      controller: listController,
      beforeItemsBuilder: widget.beforeItemsBuilder,
      itemBuilder: (ctx, item, index) {
        final row = _buildMobileCard(ctx, item, index);
        return widget.rowBuilder?.call(ctx, item, index, row) ?? row;
      },
    );
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
      isExpanded: item.isExpanded,
      onExpansionChanged: () => listController.toggleExpansionByKey(item.key),
      expandedContent: widget.expandedBuilder?.call(ctx, item, index) ?? wTheme.buildDefaultExpandedContent(ctx.colors, item.data, index),
      selectable: listController.selectable,
      isSelected: item.isSelected,
      onSelectionChanged: () => listController.toggleSelectionByKey(item.key),
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
      isExpanded: item.isExpanded,
      onExpansionChanged: () => listController.toggleExpansionByKey(item.key),
      expandedContent: widget.expandedBuilder?.call(ctx, item, index) ?? wTheme.buildDefaultExpandedContent(ctx.colors, item.data, index),
      selectable: listController.selectable,
      isSelected: item.isSelected,
      onSelectionChanged: () => listController.toggleSelectionByKey(item.key),
      backgroundColor: widget.rowColorBuilder?.call(item, index),
    );
  }
}
