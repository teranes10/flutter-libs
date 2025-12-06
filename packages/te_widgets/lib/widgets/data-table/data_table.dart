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
  final Widget Function(BuildContext ctx, TListItem<T, K> item, int index)? expandedBuilder;

  /// Number of pagination buttons to show.
  ///
  /// Defaults to 7.
  final int paginationTotalVisible;

  /// Available options for items per page selection.
  ///
  /// Defaults to [5, 10, 15, 25, 50].
  final List<int> itemsPerPageOptions;

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
  });

  @override
  State<TDataTable<T, K>> createState() => _TDataTableState<T, K>();
}

class _TDataTableState<T, K> extends State<TDataTable<T, K>> with TListStateMixin<T, K, TDataTable<T, K>> {
  TWidgetThemeExtension get theme => context.theme;
  TTableTheme get wTheme => widget.theme ?? context.theme.tableTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = context.isMobile;

    return LayoutBuilder(builder: (_, constraints) {
      final canSticky = wTheme.shrinkWrap ? false : constraints.maxWidth > 600 && constraints.maxHeight > 750;
      final infiniteScroll = wTheme.infiniteScroll ?? isMobile;

      return TTable<T, K>(
        headers: widget.headers,
        theme: wTheme.copyWith(
          infiniteScroll: infiniteScroll,
          headerSticky: wTheme.headerSticky ?? canSticky,
          footerSticky: wTheme.footerSticky ?? canSticky,
          footerBuilder: (ctx) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!infiniteScroll) _buildToolbar(colors, constraints.maxWidth),
              if (wTheme.footerBuilder != null) wTheme.footerBuilder!(ctx),
            ],
          ),
        ),
        controller: listController,
        expandedBuilder: widget.expandedBuilder,
      );
    });
  }

  Widget _buildToolbar(ColorScheme colors, double maxWidth) {
    final paginationBarWidth = (40.0 * (listController.totalPages.clamp(0, widget.paginationTotalVisible) + 4)) +
        ((listController.totalPages.toString().length - 1) * 6 * 7);
    final paginationInfoWidth = listController.paginationInfo.length * 7.5;
    final totalWidth = paginationBarWidth + paginationInfoWidth + 80 + 20;
    final needWrap = maxWidth < totalWidth;

    return Container(
      padding: EdgeInsets.only(top: 15),
      width: double.infinity,
      child: needWrap
          ? Column(
              spacing: 15,
              children: [
                _buildPaginationBar(listController.page, listController.totalPages),
                _buildPaginationInfo(colors, listController.paginationInfo),
                _buildItemsPerPage(),
              ],
            )
          : Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 12,
              spacing: 12,
              children: [
                _buildPaginationBar(listController.page, listController.totalPages),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 15,
                  children: [_buildPaginationInfo(colors, listController.paginationInfo), _buildItemsPerPage()],
                ),
              ],
            ),
    );
  }

  Widget _buildPaginationBar(page, totalPages) {
    return TPagination(
      currentPage: page,
      totalPages: totalPages,
      totalVisible: widget.paginationTotalVisible,
      onPageChanged: listController.handlePageChange,
    );
  }

  Widget _buildItemsPerPage() {
    return SizedBox(
      width: 100,
      child: TSelect<int, int, int>(
        theme: theme.textFieldTheme.copyWith(size: TInputSize.sm),
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
    return Text(info, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: colors.onSurface));
  }
}
