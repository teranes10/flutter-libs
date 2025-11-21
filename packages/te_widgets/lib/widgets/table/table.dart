import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTable<T, K> extends StatefulWidget with TListMixin<T, K> {
  final List<TTableHeader<T, K>> headers;
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
  final Widget Function(BuildContext ctx, TListItem<T, K> item, int index)? expandedBuilder;
  final bool editable;

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
  });

  @override
  State<TTable<T, K>> createState() => _TTableState<T, K>();
}

class _TTableState<T, K> extends State<TTable<T, K>> with TListStateMixin<T, K, TTable<T, K>> {
  TTableTheme get wTheme => widget.theme ?? context.theme.tableTheme;
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

    return TTableScope<T, K>(
      controller: listController,
      activeCellNotifier: _activeCellNotifier,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldShowCardView = wTheme.forceCardStyle ?? constraints.maxWidth < requiredWidth;
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
            if (listController.isLoading)
              SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  backgroundColor: colors.primaryContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              )
            else
              SizedBox.shrink()
          ],
        ),
      ),
      controller: listController,
      itemBuilder: (ctx, item, index) => _buildRowCard(columnWidths, ctx, item, index),
    );
  }

  Widget _buildCardView(ColorScheme colors, BoxConstraints constraints) {
    return TList<T, K>(
      theme: wTheme.copyWith(
        headerBuilder: (ctx) => Column(
          children: [
            if (wTheme.headerBuilder != null) wTheme.headerBuilder!(ctx),
            if (listController.isLoading)
              SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  backgroundColor: colors.primaryContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              )
            else
              SizedBox.shrink()
          ],
        ),
      ),
      controller: listController,
      itemBuilder: (ctx, item, index) => _buildMobileCard(ctx, item, index),
    );
  }

  _buildRowCard(Map<int, TableColumnWidth> columnWidths, BuildContext ctx, TListItem<T, K> item, int index) {
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
    );
  }

  _buildMobileCard(BuildContext ctx, TListItem<T, K> item, int index) {
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
    );
  }
}
