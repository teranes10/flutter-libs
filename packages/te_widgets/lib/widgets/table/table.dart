import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTable<T, K> extends StatefulWidget with TListMixin<T, K> {
  final List<TTableHeader<T>> headers;
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
  final Widget Function(T item, int index)? expandedBuilder;

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
  });

  @override
  State<TTable<T, K>> createState() => _TTableState<T, K>();
}

class _TTableState<T, K> extends State<TTable<T, K>> with TListStateMixin<T, K, TTable<T, K>> {
  TTableTheme get wTheme => widget.theme ?? context.theme.tableTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final requiredWidth = TTableTheme.calculateTotalRequiredWidth(widget.headers, listController.selectable, listController.expandable);

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldShowCardView = wTheme.forceCardStyle ?? constraints.maxWidth < requiredWidth;
        return shouldShowCardView ? _buildCardView(colors, constraints) : _buildTableView(colors, constraints);
      },
    );
  }

  Widget _buildTableView(ColorScheme colors, BoxConstraints constraints) {
    final columnWidths = TTableTheme.calculateColumnWidths(widget.headers, listController.selectable, listController.expandable);

    return TList<T, K>(
      theme: wTheme.copyWith(
        headerWidget: Column(
          children: [
            if (wTheme.headerWidget != null) wTheme.headerWidget!,
            TTableRowHeader<T, K>(
              theme: wTheme.headerTheme,
              headers: widget.headers,
              controller: listController,
              columnWidths: columnWidths,
            ),
            ValueListenableBuilder(
              valueListenable: listController,
              builder: (_, controller, __) {
                if (controller.loading) {
                  return SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      backgroundColor: colors.primaryContainer,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
      controller: listController,
      itemBuilder: (context, item, index, multiple) => TTableRowCard<T>(
        item: item.data,
        headers: widget.headers,
        theme: wTheme.rowCardTheme,
        width: wTheme.cardWidth,
        columnWidths: columnWidths,
        expandable: listController.expandable,
        isExpanded: item.isExpanded,
        onExpansionChanged: () => listController.toggleExpansion(item.data),
        expandedContent: widget.expandedBuilder?.call(item.data, index) ?? wTheme.buildDefaultExpandedContent(colors, item, index),
        selectable: listController.selectable,
        isSelected: item.isSelected,
        onSelectionChanged: () => listController.toggleSelection(item.data),
      ),
    );
  }

  Widget _buildCardView(ColorScheme colors, BoxConstraints constraints) {
    return TList<T, K>(
      theme: wTheme,
      controller: listController,
      itemBuilder: (context, item, index, multiple) => TTableMobileCard<T>(
        item: item.data,
        headers: widget.headers,
        theme: wTheme.mobileCardTheme,
        width: wTheme.cardWidth,
        expandable: listController.expandable,
        isExpanded: item.isExpanded,
        onExpansionChanged: () => listController.toggleExpansion(item.data),
        expandedContent: widget.expandedBuilder?.call(item.data, index) ?? wTheme.buildDefaultExpandedContent(colors, item, index),
        selectable: listController.selectable,
        isSelected: item.isSelected,
        onSelectionChanged: () => listController.toggleSelection(item.data),
      ),
    );
  }
}
