import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A data table component with pagination, sorting, and expandable rows.
///
/// `TDataTable` provides a full-featured table widget with:
/// - Column headers with sorting
/// - Pagination with page size selection
/// - Server-side data loading
/// - Expandable rows for detailed views
/// - Responsive layout (mobile/desktop)
/// - Infinite scroll on mobile
/// - Sticky headers and footers
///
/// ## Basic Usage
///
/// ```dart
/// TDataTable<User, int>(
///   headers: [
///     TTableHeader(
///       text: 'Name',
///       value: (user) => user.name,
///       sortable: true,
///     ),
///     TTableHeader(
///       text: 'Email',
///       value: (user) => user.email,
///     ),
///     TTableHeader(
///       text: 'Status',
///       value: (user) => user.status,
///     ),
///   ],
///   items: users,
///   itemsPerPage: 10,
/// )
/// ```
///
/// ## With Server-Side Loading
///
/// ```dart
/// TDataTable<Product, int>(
///   headers: productHeaders,
///   itemsPerPage: 25,
///   onLoad: (page, search) async {
///     final response = await api.getProducts(page, search);
///     return (response.items, response.hasMore);
///   },
/// )
/// ```
///
/// ## With Expandable Rows
///
/// ```dart
/// TDataTable<Order, int>(
///   headers: orderHeaders,
///   items: orders,
///   expandedBuilder: (context, item, index) {
///     return OrderDetailsWidget(order: item.data);
///   },
/// )
/// ```
///
/// Type parameters:
/// - [T]: The type of items in the table
/// - [K]: The type of the item key
///
/// See also:
/// - [TTableHeader] for column configuration
/// - [TListController] for programmatic control
/// - [TList] for list-based data display
class TDataTable<T, K> extends StatefulWidget with TListMixin<T, K> {
  /// The column headers for the table.
  final List<TTableHeader<T, K>> headers;

  /// Custom theme for the table.
  final TTableTheme? theme;

  //List

  /// The list of items to display.
  @override
  final List<T>? items;

  /// Number of items to display per page.
  @override
  final int? itemsPerPage;

  /// Initial search query.
  @override
  final String? search;

  /// Debounce delay for search in milliseconds.
  @override
  final int? searchDelay;

  /// Callback for loading items from a server.
  @override
  final TLoadListener<T>? onLoad;

  /// Function to extract a unique key from an item.
  @override
  final ItemKeyAccessor<T, K>? itemKey;

  /// Controller for managing table state.
  @override
  final TListController<T, K>? controller;

  // Expandable configuration

  /// Builder for expanded row content.
  ///
  /// When provided, rows can be expanded to show additional details.
  final TListExpandedBuilder<T, K>? expandedBuilder;

  /// Number of pagination buttons to show.
  ///
  /// Defaults to 7.
  final int paginationTotalVisible;

  /// Available options for items per page selection.
  ///
  /// Defaults to [5, 10, 15, 25, 50].
  final List<int> itemsPerPageOptions;

  // Theme overrides

  /// Grid layout mode.
  final TGridMode? grid;

  /// Delegate for controlling grid layout.
  final TGridDelegateBuilder? gridDelegate;

  /// Whether the table should shrink-wrap its content.
  final bool? shrinkWrap;

  /// Custom header builder.
  final TListHeaderBuilder? headerBuilder;

  /// Custom footer builder.
  final TListFooterBuilder? footerBuilder;

  /// Whether to enable infinite scroll.
  final bool? infiniteScroll;

  /// Whether the header should be sticky.
  final bool? headerSticky;

  /// Whether the footer should be sticky.
  final bool? footerSticky;

  /// Custom builder for the row.
  ///
  /// If provided, this builder is called for each row and can be used to
  /// wrap or replace the default row card.
  final Widget Function(BuildContext ctx, TListItem<T, K> item, int index, Widget row)? rowBuilder;

  /// Builder for content before the list items.
  final WidgetBuilder? beforeItemsBuilder;

  /// Custom builder for the row background color.
  final Color? Function(TListItem<T, K> item, int index)? rowColorBuilder;

  /// Creates a data table component.
  const TDataTable({
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
    //DataTable
    this.paginationTotalVisible = 7,
    this.itemsPerPageOptions = const [5, 10, 15, 25, 50],
    this.beforeItemsBuilder,
    // Theme overrides
    this.grid,
    this.gridDelegate,
    this.shrinkWrap,
    this.headerBuilder,
    this.footerBuilder,
    this.infiniteScroll,
    this.headerSticky,
    this.footerSticky,
    this.rowBuilder,
    this.rowColorBuilder,
  }) : assert(
          theme == null ||
              (grid == null &&
                  gridDelegate == null &&
                  shrinkWrap == null &&
                  headerBuilder == null &&
                  footerBuilder == null &&
                  infiniteScroll == null &&
                  headerSticky == null &&
                  footerSticky == null),
          'Cannot provide both theme and individual theme properties.',
        );

  @override
  State<TDataTable<T, K>> createState() => _TDataTableState<T, K>();
}

class _TDataTableState<T, K> extends State<TDataTable<T, K>> with TListStateMixin<T, K, TDataTable<T, K>> {
  TWidgetThemeExtension get theme => context.theme;

  TTableTheme get wTheme {
    if (widget.theme != null) return widget.theme!;

    return context.theme.tableTheme.copyWith(
      grid: widget.grid,
      gridDelegate: widget.gridDelegate,
      shrinkWrap: widget.shrinkWrap,
      headerBuilder: widget.headerBuilder,
      footerBuilder: widget.footerBuilder,
      infiniteScroll: widget.infiniteScroll,
      headerSticky: widget.headerSticky,
      footerSticky: widget.footerSticky,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(builder: (_, constraints) {
      final infiniteScroll = wTheme.infiniteScroll ?? constraints.isMobile;

      return TTable<T, K>(
        theme: wTheme.copyWith(
          infiniteScroll: infiniteScroll,
          headerSticky: wTheme.headerSticky ?? wTheme.shrinkWrap != true,
          footerSticky: wTheme.footerSticky ?? wTheme.shrinkWrap != true,
          footerBuilder: (ctx) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!infiniteScroll) _buildToolbar(colors, constraints),
              if (wTheme.footerBuilder != null) wTheme.footerBuilder!(ctx),
            ],
          ),
        ),
        headers: widget.headers,
        controller: listController,
        expandedBuilder: widget.expandedBuilder,
        beforeItemsBuilder: widget.beforeItemsBuilder,
        rowBuilder: widget.rowBuilder,
        rowColorBuilder: widget.rowColorBuilder,
      );
    });
  }

  Widget _buildToolbar(ColorScheme colors, BoxConstraints constraints) {
    if (listController.isEmpty) return SizedBox.shrink();
    final isMobile = constraints.isMobile;

    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: TAlignedRow(
          mainAxisAlignment: MainAxisAlignment.center,
          left: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPaginationInfo(colors, 'Items per page'),
                _buildItemsPerPage(80),
              ],
            )
          ],
          right: [
            _buildPaginationInfo(colors, listController.paginationInfo).center(when: isMobile),
            _buildPaginationBar(listController.page, listController.totalPages),
          ],
        ));
  }

  Widget _buildPaginationBar(int page, int totalPages) {
    if (listController.isCursorPagination) return _buildCursorNavigationButtons();

    return TPagination(
      currentPage: page,
      totalPages: totalPages,
      totalVisible: widget.paginationTotalVisible,
      onPageChanged: listController.handlePageChange,
    );
  }

  Widget _buildCursorNavigationButtons() {
    return SizedBox(
      width: 100,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          TButton(
            type: TButtonType.icon,
            size: TButtonSize.md.copyWith(icon: 22),
            icon: Icons.chevron_left,
            onTap: listController.canGoToPreviousPage ? () => listController.goToPreviousPage() : null,
          ),
          TButton(
            type: TButtonType.icon,
            size: TButtonSize.md.copyWith(icon: 22),
            icon: Icons.chevron_right,
            onTap: listController.canGoToNextPage ? () => listController.goToNextPage() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsPerPage(double width) {
    return SizedBox(
      width: width,
      child: TSelect<int, int, int>(
        theme: theme.textFieldTheme.copyWith(size: TInputSize.xs),
        cardTheme: theme.listCardTheme.copyWith(showSelectionIndicator: false),
        listTheme: theme.listTheme.copyWith(
          animationBuilder: TListAnimationBuilders.fadeIn,
          animationDuration: Duration(milliseconds: 400),
        ),
        filterable: false,
        value: listController.computedItemsPerPage,
        items: listController.computeItemsPerPageOptions(widget.itemsPerPageOptions),
        onValueChanged: (value) {
          listController.handleItemsPerPageChange(value!);
        },
      ),
    );
  }

  Widget _buildPaginationInfo(ColorScheme colors, String info) {
    return Text(
      info,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: colors.onSurface),
    );
  }
}
