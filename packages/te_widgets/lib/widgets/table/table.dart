import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTable<T, K> extends StatefulWidget with TListMixin<T, K> {
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

  const TTable({
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
  });

  @override
  State<TTable<T, K>> createState() => _TTableState<T, K>();
}

class _TTableState<T, K> extends State<TTable<T, K>> with TListStateMixin<T, K, TTable<T, K>> {
  TTableTheme get wTheme => widget.theme ?? context.theme.tableTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldShowCardView = wTheme.forceCardStyle || constraints.maxWidth <= wTheme.mobileBreakpoint;
        return shouldShowCardView ? _buildCardView(colors, constraints) : _buildTableView(colors, constraints);
      },
    );
  }

  Widget _buildTableView(ColorScheme colors, BoxConstraints constraints) {
    final needsHorizontalScroll = _calculateTotalRequiredWidth() > constraints.maxWidth;

    final columnWidths = wTheme.getColumnWidths(
      widget.headers,
      listController.selectable,
      listController.expandable,
    );

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
          ],
        ),
        needsHorizontalScroll: wTheme.needsHorizontalScroll || needsHorizontalScroll,
        horizontalScrollWidth: wTheme.horizontalScrollWidth ?? (needsHorizontalScroll ? _calculateTotalRequiredWidth() : null),
      ),
      interaction: widget.interaction,
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
      interaction: widget.interaction,
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

  double _calculateTotalRequiredWidth() {
    double totalWidth = 0;

    // Add width for expand/select columns
    if (listController.expandable) totalWidth += 40;
    if (listController.selectable) totalWidth += 40;

    for (final header in widget.headers) {
      if (header.maxWidth != null && header.maxWidth != double.infinity) {
        totalWidth += header.maxWidth!;
      } else if (header.minWidth != null && header.minWidth! > 0) {
        totalWidth += header.minWidth!;
      } else {
        // For flex columns, assume a minimum reasonable width
        totalWidth += 100; // Default minimum width for flex columns
      }
    }

    // Add some padding for table margins/padding
    totalWidth += 32; // Account for horizontal padding

    return totalWidth;
  }
}
