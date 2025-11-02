import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableTheme extends TListTheme {
  final double mobileBreakpoint;
  final double? cardWidth;
  final bool forceCardStyle;
  final TTableRowHeaderTheme headerTheme;
  final TTableMobileCardTheme mobileCardTheme;
  final TTableRowCardTheme rowCardTheme;

  const TTableTheme({
    super.animationBuilder = TListAnimationBuilders.staggered,
    super.animationDuration = const Duration(milliseconds: 800),
    super.shrinkWrap = false,
    super.physics,
    super.padding,
    // Empty state
    super.emptyStateBuilder,
    super.emptyStateMessage = 'No items found',
    super.emptyStateIcon = Icons.inbox_outlined,
    // Error state
    super.errorStateBuilder,
    super.errorStateMessage = 'An error occurred',
    // Loading state
    super.loadingBuilder,
    // Header
    super.headerWidget,
    super.headerSticky = true,
    // Footer
    super.footerWidget,
    super.footerSticky = false,
    // Horizontal scroll
    super.needsHorizontalScroll = false,
    super.horizontalScrollWidth,
    // Infinite scroll
    super.infiniteScroll = true,
    super.itemBaseHeight = 50,
    super.loadingMessage = 'Loading...',
    super.noMoreItemsMessage = 'No more items to display.',
    // Separators
    super.separatorBuilder,
    super.showSeparators = false,
    // Spacing
    super.itemSpacing = 0,
    // Table
    this.mobileBreakpoint = 768,
    this.cardWidth,
    this.forceCardStyle = false,
    this.headerTheme = const TTableRowHeaderTheme(),
    this.mobileCardTheme = const TTableMobileCardTheme(),
    this.rowCardTheme = const TTableRowCardTheme(),
  });

  @override
  TTableTheme copyWith({
    TListAnimationBuilder? animationBuilder,
    Duration? animationDuration,
    bool? shrinkWrap,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    // Empty state
    Widget Function(BuildContext context)? emptyStateBuilder,
    String? emptyStateMessage,
    IconData? emptyStateIcon,
    // Error state
    Widget Function(BuildContext context, TListError error)? errorStateBuilder,
    String? errorStateMessage,
    // Loading state
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context)? loadingOverlayBuilder,
    // Header
    Widget? headerWidget,
    bool? headerSticky,
    // Footer
    Widget? footerWidget,
    bool? footerSticky,
    // Horizontal scroll
    bool? needsHorizontalScroll,
    double? horizontalScrollWidth,
    // Infinite scroll
    bool? infiniteScroll,
    double? itemBaseHeight,
    String? loadingMessage,
    String? noMoreItemsMessage,
    // Separators
    Widget Function(BuildContext context, int index)? separatorBuilder,
    bool? showSeparators,
    // Spacing
    double? itemSpacing,
    // Table
    double? mobileBreakpoint,
    double? cardWidth,
    bool? forceCardStyle,
    TTableRowHeaderTheme? headerTheme,
    TTableMobileCardTheme? mobileCardTheme,
    TTableRowCardTheme? rowCardTheme,
  }) {
    return TTableTheme(
      animationBuilder: animationBuilder ?? this.animationBuilder,
      animationDuration: animationDuration ?? this.animationDuration,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      physics: physics ?? this.physics,
      padding: padding ?? this.padding,
      emptyStateBuilder: emptyStateBuilder ?? this.emptyStateBuilder,
      emptyStateMessage: emptyStateMessage ?? this.emptyStateMessage,
      emptyStateIcon: emptyStateIcon ?? this.emptyStateIcon,
      errorStateBuilder: errorStateBuilder ?? this.errorStateBuilder,
      errorStateMessage: errorStateMessage ?? this.errorStateMessage,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      headerWidget: headerWidget ?? this.headerWidget,
      headerSticky: headerSticky ?? this.headerSticky,
      footerWidget: footerWidget ?? this.footerWidget,
      footerSticky: footerSticky ?? this.footerSticky,
      needsHorizontalScroll: needsHorizontalScroll ?? this.needsHorizontalScroll,
      horizontalScrollWidth: horizontalScrollWidth ?? this.horizontalScrollWidth,
      infiniteScroll: infiniteScroll ?? this.infiniteScroll,
      itemBaseHeight: itemBaseHeight ?? this.itemBaseHeight,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      noMoreItemsMessage: noMoreItemsMessage ?? this.noMoreItemsMessage,
      separatorBuilder: separatorBuilder ?? this.separatorBuilder,
      showSeparators: showSeparators ?? this.showSeparators,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      mobileBreakpoint: mobileBreakpoint ?? this.mobileBreakpoint,
      cardWidth: cardWidth ?? this.cardWidth,
      forceCardStyle: forceCardStyle ?? this.forceCardStyle,
      headerTheme: headerTheme ?? this.headerTheme,
      mobileCardTheme: mobileCardTheme ?? this.mobileCardTheme,
      rowCardTheme: rowCardTheme ?? this.rowCardTheme,
    );
  }

  Map<int, TableColumnWidth> getColumnWidths<T>(List<TTableHeader<T>> headers, bool selectable, bool expandable) {
    Map<int, TableColumnWidth> columnWidths = {};
    int columnIndex = 0;

    if (selectable) {
      columnWidths[columnIndex] = const FixedColumnWidth(40);
      columnIndex++;
    }

    if (expandable) {
      columnWidths[columnIndex] = const FixedColumnWidth(40);
      columnIndex++;
    }

    for (int i = 0; i < headers.length; i++) {
      final header = headers[i];

      if (header.maxWidth != null && header.maxWidth != double.infinity) {
        columnWidths[columnIndex] = FixedColumnWidth(header.maxWidth!);
      } else if (header.minWidth != null && header.minWidth! > 0) {
        columnWidths[columnIndex] = FixedColumnWidth(header.minWidth!);
      } else {
        columnWidths[columnIndex] = FlexColumnWidth(header.flex?.toDouble() ?? 1.0);
      }
      columnIndex++;
    }

    return columnWidths;
  }

  Widget buildDefaultExpandedContent<T>(ColorScheme colors, T item, int index) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceDim,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Expanded content for item $index\nProvide expandedBuilder for custom content',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
