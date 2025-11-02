import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TDataTable<T, K> extends StatefulWidget with TListMixin<T, K> {
  final List<TTableHeader<T>> headers;
  final TTableTheme? theme;
  final TListInteraction<T>? interaction;

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
  final Widget Function(T item, int index)? expandedBuilder;

  final int paginationTotalVisible;
  final List<int> itemsPerPageOptions;

  const TDataTable({
    super.key,
    required this.headers,
    this.theme,
    this.interaction,
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
    return Column(
      children: [
        Expanded(
          child: TTable<T, K>(
            headers: widget.headers,
            theme: wTheme.copyWith(
              infiniteScroll: false,
              footerSticky: true,
              footerWidget: LayoutBuilder(
                builder: (_, constraints) => ValueListenableBuilder(
                  valueListenable: listController,
                  builder: (ctx, state, _) => _buildToolbar(colors, constraints),
                ),
              ),
            ),
            interaction: widget.interaction,
            controller: listController,
            expandedBuilder: widget.expandedBuilder,
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(ColorScheme colors, BoxConstraints constraints) {
    final paginationBarWidth = (40.0 * (listController.totalPages.clamp(0, widget.paginationTotalVisible) + 4)) +
        ((listController.totalPages.toString().length - 1) * 6 * 7);
    final paginationInfoWidth = listController.paginationInfo.length * 7.5;
    final totalWidth = paginationBarWidth + paginationInfoWidth + 80 + 20;
    final needWrap = constraints.maxWidth < totalWidth;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: needWrap
          ? Column(
              spacing: 15,
              children: [
                _buildPaginationBar(listController.page, listController.totalPages),
                _buildPaginationInfo(colors, listController.paginationInfo),
                _buildItemsPerPage(listController.itemsPerPage, listController.totalItems),
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
                  children: [
                    _buildPaginationInfo(colors, listController.paginationInfo),
                    _buildItemsPerPage(listController.itemsPerPage, listController.totalItems)
                  ],
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

  Widget _buildItemsPerPage(int itemsPerPage, int total) {
    final itemsPerPageOptions = <int>{itemsPerPage, ...widget.itemsPerPageOptions}.where((x) => x <= total && x > 0).toList()..sort();
    return SizedBox(
      width: 100,
      child: TSelect<int, int, int>(
        theme: theme.textFieldTheme.copyWith(size: TInputSize.sm),
        cardTheme: theme.listCardTheme.copyWith(showSelectionIndicator: false),
        filterable: false,
        value: itemsPerPage,
        items: itemsPerPageOptions,
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
