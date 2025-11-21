import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableTheme extends TListTheme {
  final double? cardWidth;
  final bool? forceCardStyle;
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
    super.headerBuilder,
    super.headerSticky,
    // Footer
    super.footerBuilder,
    super.footerSticky,
    // Horizontal scroll
    super.needsHorizontalScroll = false,
    super.horizontalScrollWidth,
    // Infinite scroll
    super.infiniteScroll,
    super.itemBaseHeight = 50,
    super.loadingMessage = 'Loading...',
    super.noMoreItemsMessage = 'No more items to display.',
    // Separators
    super.separatorBuilder,
    super.showSeparators = false,
    // Spacing
    super.itemSpacing = 0,
    // Table
    this.cardWidth,
    this.forceCardStyle,
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
    EdgeInsets? padding,
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
    Widget Function(BuildContext context)? headerBuilder,
    bool? headerSticky,
    // Footer
    Widget Function(BuildContext context)? footerBuilder,
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
      headerBuilder: headerBuilder ?? this.headerBuilder,
      headerSticky: headerSticky ?? this.headerSticky,
      footerBuilder: footerBuilder ?? this.footerBuilder,
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
      cardWidth: cardWidth ?? this.cardWidth,
      forceCardStyle: forceCardStyle ?? this.forceCardStyle,
      headerTheme: headerTheme ?? this.headerTheme,
      mobileCardTheme: mobileCardTheme ?? this.mobileCardTheme,
      rowCardTheme: rowCardTheme ?? this.rowCardTheme,
    );
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

  static Map<int, TableColumnWidth> calculateColumnWidths<T, K>(List<TTableHeader<T, K>> headers, bool selectable, bool expandable) {
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

  static double calculateTotalRequiredWidth<T, K>(List<TTableHeader<T, K>> headers, bool selectable, bool expandable) {
    double totalWidth = 0;

    // Add width for expand/select columns
    if (expandable) totalWidth += 40;
    if (selectable) totalWidth += 40;

    for (final header in headers) {
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

  @override
  buildLoadingIndicator(BuildContext context) {
    return SizedBox.shrink();
  }
}
