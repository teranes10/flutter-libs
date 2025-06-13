import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/table/table_card.dart';
import 'package:te_widgets/widgets/table/table_configs.dart';

class TTable<T> extends StatefulWidget {
  final List<TTableHeader<T>> headers;
  final List<T> items;
  final double mobileBreakpoint;
  final double? cardWidth;
  final bool showStaggeredAnimation;
  final Duration animationDuration;
  final bool forceCardStyle;
  final TTableStyling? styling;
  final void Function(T item)? onItemTap;
  final bool shrinkWrap;
  final double? minWidth;
  final double? maxWidth;
  final bool showScrollbars;

  const TTable({
    super.key,
    required this.headers,
    required this.items,
    this.mobileBreakpoint = 768,
    this.cardWidth,
    this.showStaggeredAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.forceCardStyle = false,
    this.styling,
    this.onItemTap,
    this.shrinkWrap = true,
    this.minWidth,
    this.maxWidth,
    this.showScrollbars = true,
  });

  @override
  State<TTable<T>> createState() => _TTableState<T>();
}

class _TTableState<T> extends State<TTable<T>> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _horizontalScrollController;
  late ScrollController _verticalScrollController;
  bool _isCardView = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldShowCardView = widget.forceCardStyle || constraints.maxWidth <= widget.mobileBreakpoint;

        if (shouldShowCardView != _isCardView) {
          _isCardView = shouldShowCardView;
          _animationController.reset();
          _animationController.forward();
        }

        Widget child = _isCardView ? _buildCardView() : _buildTableView(constraints);

        // Calculate if we need horizontal scroll based on column widths
        bool needsHorizontalScroll = false;
        double totalRequiredWidth = 0;

        if (!_isCardView) {
          totalRequiredWidth = _calculateTotalRequiredWidth();
          needsHorizontalScroll = totalRequiredWidth > constraints.maxWidth;
        }

        if (widget.minWidth != null || widget.maxWidth != null) {
          child = ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minWidth ?? 0,
              maxWidth: widget.maxWidth ?? double.infinity,
            ),
            child: child,
          );
        }

        // Apply horizontal scroll if needed and set minimum width
        if (!_isCardView && (needsHorizontalScroll || (widget.minWidth != null && widget.minWidth! > constraints.maxWidth))) {
          // Ensure the table has enough width to display all columns properly
          final minTableWidth = totalRequiredWidth > 0 ? totalRequiredWidth : (widget.minWidth ?? constraints.maxWidth);

          child = SizedBox(
            width: minTableWidth,
            child: child,
          );

          child = _buildScrollableWrapper(child, isHorizontal: true);
        } else if (!_isCardView) {
          // When no horizontal scroll is needed, stretch to full available width
          child = SizedBox(
            width: constraints.maxWidth,
            child: child,
          );
        }

        return SizedBox(
          width: double.infinity,
          child: child,
        );
      },
    );
  }

  double _calculateTotalRequiredWidth() {
    double totalWidth = 0;

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

  Widget _buildCardView() {
    if (widget.items.isEmpty) {
      return tableEmptyState();
    }

    Widget listView = ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      padding: widget.styling?.contentPadding ?? const EdgeInsets.all(0),
      itemCount: widget.items.length,
      itemBuilder: _buildCardItem,
    );

    return widget.showScrollbars && !widget.shrinkWrap ? _buildScrollableWrapper(listView) : listView;
  }

  Widget _buildCardItem(BuildContext context, int index) {
    return _buildAnimatedItem(
      index: index,
      child: TTableCard<T>(
        item: widget.items[index],
        headers: widget.headers,
        styling: widget.styling,
        onTap: widget.onItemTap != null ? () => widget.onItemTap!(widget.items[index]) : null,
        width: widget.cardWidth,
      ),
    );
  }

  Widget _buildTableView([BoxConstraints? constraints]) {
    Widget content;
    final defaultPadding = widget.styling?.contentPadding ?? const EdgeInsets.only(bottom: 8);

    if (widget.shrinkWrap) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTableHeader(),
          Padding(
            padding: defaultPadding,
            child: _buildTable(),
          ),
          if (widget.items.isEmpty) tableEmptyState()
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeader(),
          Expanded(
            child: widget.showScrollbars
                ? RawScrollbar(
                    controller: _verticalScrollController,
                    thumbVisibility: true,
                    interactive: true,
                    thickness: 8.0,
                    radius: const Radius.circular(4.0),
                    thumbColor: AppColors.grey.shade300,
                    trackColor: AppColors.grey.shade100,
                    trackBorderColor: Colors.transparent,
                    crossAxisMargin: 2.0,
                    mainAxisMargin: 4.0,
                    minThumbLength: 36.0,
                    child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: defaultPadding,
                      child: _buildTable(),
                    ),
                  )
                : SingleChildScrollView(
                    controller: _verticalScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: defaultPadding,
                    child: _buildTable(),
                  ),
          ),
          if (widget.items.isEmpty) tableEmptyState()
        ],
      );
    }

    return content;
  }

  Widget _buildTable() {
    return SizedBox(
      width: double.infinity, // Ensure table stretches full width
      child: Column(
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return _buildAnimatedTableRow(index, item);
        }).toList(),
      ),
    );
  }

  Widget _buildAnimatedTableRow(int index, T item) {
    final rowStyle = widget.styling?.rowStyle ?? const TRowStyle();

    // Create the entire row as a single card
    Widget rowCard = Container(
      width: double.infinity, // Force full width
      margin: rowStyle.margin ?? const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: rowStyle.elevation ?? 1,
        borderRadius: rowStyle.borderRadius ?? BorderRadius.circular(8),
        color: rowStyle.backgroundColor ?? Colors.white,
        child: InkWell(
          onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
          borderRadius: rowStyle.borderRadius ?? BorderRadius.circular(8),
          child: Container(
            width: double.infinity, // Ensure inner container also stretches
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.shade50,
                  offset: Offset(0, 2),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: rowStyle.padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Table(
              columnWidths: _getColumnWidths(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: widget.headers.map((header) {
                    Widget cellContent = _buildCellContent(header, item);

                    // Apply alignment
                    return Align(
                      alignment: header.alignment ?? Alignment.centerLeft,
                      child: cellContent,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Apply animation to the entire row card
    return _buildAnimatedItem(
      index: index,
      child: rowCard,
    );
  }

  Map<int, TableColumnWidth> _getColumnWidths() {
    Map<int, TableColumnWidth> columnWidths = {};

    // Count fixed width columns and calculate remaining space for flex columns
    double totalFixedWidth = 0;
    int flexColumnCount = 0;

    for (final header in widget.headers) {
      if (header.maxWidth != null && header.maxWidth != double.infinity) {
        totalFixedWidth += header.maxWidth!;
      } else if (header.minWidth != null && header.minWidth! > 0) {
        totalFixedWidth += header.minWidth!;
      } else {
        flexColumnCount++;
      }
    }

    for (int i = 0; i < widget.headers.length; i++) {
      final header = widget.headers[i];

      if (header.maxWidth != null && header.maxWidth != double.infinity) {
        // Fixed width column
        columnWidths[i] = FixedColumnWidth(header.maxWidth!);
      } else if (header.minWidth != null && header.minWidth! > 0) {
        // Use FixedColumnWidth for minWidth to ensure it's respected
        columnWidths[i] = FixedColumnWidth(header.minWidth!);
      } else {
        // Flexible column - these will stretch to fill remaining space
        columnWidths[i] = FlexColumnWidth(header.flex?.toDouble() ?? 1.0);
      }
    }

    return columnWidths;
  }

  Widget _buildTableHeader() {
    final headerStyle = widget.styling?.headerTextStyle ??
        TextStyle(
          fontSize: 13.6,
          fontWeight: FontWeight.w400,
          color: AppColors.grey[500],
        );

    final defaultPadding = widget.styling?.contentPadding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    return Container(
      width: double.infinity, // Ensure header stretches full width
      padding: widget.styling?.headerPadding ??
          EdgeInsets.symmetric(
            vertical: 12,
            horizontal: defaultPadding.horizontal,
          ),
      decoration: widget.styling?.headerDecoration,
      child: Table(
        columnWidths: _getColumnWidths(),
        children: [
          TableRow(
            children: widget.headers.map((header) {
              return Container(
                  constraints: BoxConstraints(
                    minWidth: header.minWidth ?? 0,
                    maxWidth: header.maxWidth ?? double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      header.text,
                      style: headerStyle,
                      textAlign: header.alignment?.toTextAlign() ?? TextAlign.left,
                    ),
                  ));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCellContent(TTableHeader<T> header, T item) {
    if (header.builder != null) {
      return Builder(
        builder: (context) => header.builder!(context, item),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        header.getValue(item),
        style: widget.styling?.rowTextStyle ??
            TextStyle(
              fontSize: 13.6,
              fontWeight: FontWeight.w300,
              color: AppColors.grey[600],
            ),
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    if (!widget.showStaggeredAnimation) {
      return child;
    }

    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        (0.05 * index).clamp(0.0, 0.3),
        (0.3 + (0.05 * index)).clamp(0.3, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset((1 - animation.value) * 50, 0),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildScrollableWrapper(Widget child, {bool isHorizontal = false}) {
    if (isHorizontal) {
      return TScrollbar(
        controller: _horizontalScrollController,
        isHorizontal: true,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          child: child,
        ),
      );
    }

    return TScrollbar(
      controller: _verticalScrollController,
      thumbVisibility: widget.showScrollbars,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}

class TScrollbar extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final bool isHorizontal;
  final bool thumbVisibility;

  const TScrollbar({
    super.key,
    required this.child,
    required this.controller,
    this.isHorizontal = false,
    this.thumbVisibility = true,
  });

  @override
  State<TScrollbar> createState() => _TScrollbarState();
}

class _TScrollbarState extends State<TScrollbar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: RawScrollbar(
        controller: widget.controller,
        scrollbarOrientation: widget.isHorizontal ? ScrollbarOrientation.bottom : ScrollbarOrientation.right,
        thumbVisibility: widget.thumbVisibility,
        trackVisibility: true,
        interactive: true,
        thickness: 8.0,
        radius: const Radius.circular(8.0),
        thumbColor: _isHovered ? AppColors.grey.shade200 : AppColors.grey.shade50.withAlpha(200),
        trackColor: Colors.transparent,
        trackBorderColor: Colors.transparent,
        crossAxisMargin: 0.0,
        mainAxisMargin: 0.0,
        minThumbLength: 36.0,
        child: widget.child,
      ),
    );
  }
}
