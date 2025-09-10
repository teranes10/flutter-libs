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

    // Expandable
    this.expandable = false,
    this.singleExpand = true,
    this.expandedBuilder,

    // Selectable
    this.selectable = false,
    this.singleSelect = false,
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
  });

  @override
  State<TDataTable<T>> createState() => _TDataTableState<T>();
}

class _TDataTableState<T> extends State<TDataTable<T>> with TPaginationStateMixin<T, TDataTable<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return LayoutBuilder(builder: (context, constraints) {
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
                  backgroundColor: theme.primaryContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.onPrimaryContainer),
                ),
              );
            },
          ),

          // Table with reactive items
          ValueListenableBuilder<List<T>>(
            valueListenable: itemsNotifier,
            builder: (context, items, child) {
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
              );
            },
          ),

          // Toolbar with pagination and controls
          ValueListenableBuilder<List<T>>(
            valueListenable: itemsNotifier,
            builder: (context, items, child) {
              if (totalItems == 0) return const SizedBox.shrink();
              return Column(
                children: [
                  const SizedBox(height: 24),
                  _buildToolbar(theme, constraints),
                ],
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildToolbar(ColorScheme theme, BoxConstraints constraints) {
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
                _buildPaginationInfo(theme),
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
                  children: [_buildPaginationInfo(theme), _buildItemsPerPage()],
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
        size: TInputSize.sm,
        selectedIcon: null,
        value: computedItemsPerPage,
        items: computedItemsPerPageOptions,
        onValueChanged: (value) {
          onItemsPerPageChanged(value);
        },
      ),
    );
  }

  Widget _buildPaginationInfo(ColorScheme theme) {
    return Text(paginationInfo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: theme.onSurface));
  }
}
