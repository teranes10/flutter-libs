import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TDataTable<T> extends StatefulWidget with TPaginationMixin<T> {
  final List<TTableHeader<T>> headers;
  final TTableDecoration decoration;
  final TTableController<T>? tableController;
  final TTableInteractionConfig interactionConfig;

  // Expandable configuration
  final bool expandable;
  final bool singleExpand;
  final Widget Function(T item, int index, bool isExpanded)? expandedBuilder;

  // Selectable configuration
  final bool selectable;
  final bool singleSelect;

  final bool infiniteScroll;

  @override
  final List<T>? items;
  @override
  final int itemsPerPage;
  @override
  final List<int> itemsPerPageOptions;
  @override
  final bool loading;
  @override
  final TLoadListener<T>? onLoad;
  @override
  final String? search;
  @override
  final int searchDelay;
  @override
  final String Function(T)? itemToString;
  @override
  final ValueNotifier<String>? searchNotifier;
  @override
  final TPaginationController? controller;

  const TDataTable({
    super.key,
    required this.headers,
    this.decoration = const TTableDecoration(),
    this.tableController,
    this.interactionConfig = const TTableInteractionConfig(),
    this.items,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [5, 10, 15, 25, 50],
    this.searchDelay = 2500,
    this.loading = false,
    this.search,
    this.onLoad,
    this.itemToString,
    this.searchNotifier,
    this.controller,

    // Expandable
    this.expandable = false,
    this.singleExpand = true,
    this.expandedBuilder,

    // Selectable
    this.selectable = false,
    this.singleSelect = false,

    // Infinite scroll
    this.infiniteScroll = false,
  });

  @override
  State<TDataTable<T>> createState() => _TDataTableState<T>();
}

class _TDataTableState<T> extends State<TDataTable<T>> with TPaginationStateMixin<T, TDataTable<T>> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(builder: (context, constraints) {
      bool infiniteScroll = widget.infiniteScroll;
      if (constraints.maxWidth < 768) {
        infiniteScroll = true;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Loading indicator
          ValueListenableBuilder<bool>(
            valueListenable: loadingNotifier,
            builder: (context, isLoading, child) {
              if (!isLoading) return const SizedBox.shrink();
              return SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  backgroundColor: colors.primaryContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimaryContainer),
                ),
              );
            },
          ),

          // Table with reactive items
          infiniteScroll ? _buildInfiniteScrollTable(constraints) : _buildRegularTable(),

          // Toolbar with pagination and controls (hidden for infinite scroll)
          if (!infiniteScroll)
            ValueListenableBuilder<List<T>>(
              valueListenable: itemsNotifier,
              builder: (context, items, child) {
                if (totalItems == 0) return const SizedBox.shrink();
                return Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildToolbar(colors, constraints),
                  ],
                );
              },
            ),
        ],
      );
    });
  }

  Widget _buildRegularTable() {
    return ValueListenableBuilder<List<T>>(
      valueListenable: itemsNotifier,
      builder: (context, items, child) {
        return Expanded(child: _buildTable(items));
      },
    );
  }

  double estimateHeight(int itemsPerPage) {
    return 48 + (70.0 * itemsPerPage) + (12.0 * (itemsPerPage - 1));
  }

  Widget _buildInfiniteScrollTable(BoxConstraints constraints) {
    return ValueListenableBuilder<List<T>>(
      valueListenable: itemsNotifier,
      builder: (context, items, child) {
        return Container(
          constraints: BoxConstraints(maxHeight: estimateHeight(widget.itemsPerPage).clamp(0, constraints.maxHeight - 10)),
          child: Column(
            children: [
              Expanded(
                  child: _buildTable(items, onScrollEnd: () {
                if (hasMoreItems) {
                  onScrollEnd();
                }
              })),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(List<T> items, {VoidCallback? onScrollEnd}) {
    return TTable<T>(
      headers: widget.headers,
      items: items,
      decoration: widget.decoration,
      loading: loading,
      controller: widget.tableController,
      interactionConfig: widget.interactionConfig,
      expandable: widget.expandable,
      singleExpand: widget.singleExpand,
      expandedBuilder: widget.expandedBuilder,
      selectable: widget.selectable,
      singleSelect: widget.singleSelect,
      onScrollEnd: onScrollEnd,
    );
  }

  Widget _buildToolbar(ColorScheme colors, BoxConstraints constraints) {
    final paginationBarWidth =
        (40.0 * (totalPages.clamp(0, widget.decoration.paginationTotalVisible) + 4)) + ((totalPages.toString().length - 1) * 6 * 7);
    final paginationInfoWidth = paginationInfo.length * 7.5;
    final totalWidth = paginationBarWidth + paginationInfoWidth + 80 + 20;
    final needWrap = constraints.maxWidth < totalWidth;

    return SizedBox(
      width: double.infinity,
      child: needWrap
          ? Column(
              spacing: 15,
              children: [
                _buildPaginationBar(),
                _buildPaginationInfo(colors),
                _buildItemsPerPage(),
              ],
            )
          : Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 12,
              spacing: 12,
              children: [
                _buildPaginationBar(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 15,
                  children: [_buildPaginationInfo(colors), _buildItemsPerPage()],
                ),
              ],
            ),
    );
  }

  Widget _buildPaginationBar() {
    return TPagination(
      currentPage: currentPage,
      totalPages: totalPages,
      totalVisible: widget.decoration.paginationTotalVisible,
      onPageChanged: onPageChanged,
    );
  }

  Widget _buildItemsPerPage() {
    return SizedBox(
      width: 80,
      child: TSelect(
        theme: TTextFieldTheme(size: TInputSize.sm),
        selectedIcon: null,
        value: computedItemsPerPage,
        items: computedItemsPerPageOptions,
        onValueChanged: (value) {
          onItemsPerPageChanged(value);
        },
      ),
    );
  }

  Widget _buildPaginationInfo(ColorScheme colors) {
    return Text(paginationInfo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: colors.onSurface));
  }
}
