import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TDataTable<T> extends StatefulWidget with TPaginationMixin<T> {
  final List<TTableHeader<T>> headers;
  final TTableDecoration decoration;

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
    this.items,
    this.itemsPerPage = 10,
    this.itemsPerPageOptions = const [5, 10, 15, 25, 50],
    this.searchDelay = 2500,
    this.loading = false,
    this.search,
    this.onLoad,
    this.decoration = const TTableDecoration(),
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
                backgroundColor: AppColors.grey[100],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
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
                const SizedBox(height: 16),
                _buildToolbar(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 12,
        spacing: 12,
        children: [
          TPagination(currentPage: currentPage, totalPages: totalPages, onPageChanged: onPageChanged),
          _buildInfoContainer(),
        ],
      ),
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
        ),
      ],
    );
  }
}
