import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/pagination_mixin.dart';
import 'package:te_widgets/te_widgets.dart';

class TDataTable<T> extends StatefulWidget with TPaginationMixin<T> {
  final List<TTableHeader<T>> headers;

  // Table styling properties
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

  const TDataTable({
    super.key,
    required this.headers,
    this.items,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [5, 10, 15, 25, 50],
    this.searchDelay = 300,
    this.loading = false,
    this.search,
    this.onLoad,
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
  State<TDataTable<T>> createState() => _TDataTableState<T>();
}

class _TDataTableState<T> extends State<TDataTable<T>> with TPaginationStateMixin<T, TDataTable<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Loading indicator
        if (loading)
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              backgroundColor: AppColors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ),

        // Table
        TTable<T>(
          headers: widget.headers,
          items: paginatedItems,
          mobileBreakpoint: widget.mobileBreakpoint,
          cardWidth: widget.cardWidth,
          showStaggeredAnimation: widget.showStaggeredAnimation,
          animationDuration: widget.animationDuration,
          forceCardStyle: widget.forceCardStyle,
          styling: widget.styling,
          onItemTap: widget.onItemTap,
          shrinkWrap: widget.shrinkWrap,
          minWidth: widget.minWidth,
          maxWidth: widget.maxWidth,
          showScrollbars: widget.showScrollbars,
        ),

        // Toolbar with pagination and controls
        if (totalItems > 0) ...[
          const SizedBox(height: 16),
          _buildToolbar(),
        ],
      ],
    );
  }

  Widget _buildToolbar() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 12,
      spacing: 12,
      children: [
        TPagination(
          currentPage: currentPage,
          totalPages: totalPages,
          onPageChanged: onPageChanged,
        ),
        _buildInfoContainer(),
      ],
    );
  }

  Widget _buildInfoContainer() {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      spacing: 12,
      children: [
        Text(
          paginationInfo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: AppColors.grey[500],
          ),
        ),
        SizedBox(
          width: 70,
          child: TSelect(
            size: TInputSize.sm,
            selectedIcon: null,
            value: computedItemsPerPage,
            items: computedItemsPerPageOptions,
            onValueChanged: (value) {
              onItemsPerPageChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
