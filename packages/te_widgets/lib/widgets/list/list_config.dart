import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:te_widgets/te_widgets.dart';

/// Position to add new items in the list.
enum TItemAddPosition { first, last }

/// Mode for selecting list items.
enum TSelectionMode { none, single, multiple }

/// Mode for expanding list items.
enum TExpansionMode { none, single, multiple }

// Typedefs for item accessors
typedef ItemToString<T> = String Function(T item);
typedef ItemChildrenAccessor<T> = List<T>? Function(T item);
typedef ItemTextAccessor<T> = String Function(T item);
typedef ItemKeyAccessor<T, K> = K Function(T item);
typedef ListItemTap<T, K> = void Function(TListItem<T, K> item);
typedef ListItemFactory<T, K> = TListItem<T, K> Function(T item);
typedef ListItemBuilder<T, K> = Widget Function(BuildContext context, TListItem<T, K> item, int index);
typedef TLoadListener<T> = Future<TLoadResult<T>> Function(TLoadOptions<T> options);

// Typedefs for list builders
typedef TListEmptyBuilder = Widget Function(BuildContext context);
typedef TListErrorBuilder = Widget Function(BuildContext context, TListError error);
typedef TListLoadingBuilder = Widget Function(BuildContext context);
typedef TListHeaderBuilder = Widget Function(BuildContext context);
typedef TListFooterBuilder = Widget Function(BuildContext context);
typedef TListSeparatorBuilder = Widget? Function(BuildContext context, int index);
typedef TListDragProxyDecorator = Widget Function(Widget, int, Animation<double>);
typedef TListReorderCallback = void Function(int, int);
typedef TGridDelegateBuilder = TGridDelegate Function(BuildContext context);

/// Options for loading data in the list.
class TLoadOptions<T> {
  /// The page number to load (1-based).
  final int page;

  /// Number of items per page.
  final int itemsPerPage;

  /// Search query string.
  final String? search;

  /// Calculated offset for pagination.
  int get offset => (page - 1) * itemsPerPage;

  /// Limit for pagination.
  int get limit => itemsPerPage;

  /// Creates load options.
  const TLoadOptions({
    required this.page,
    required this.itemsPerPage,
    this.search,
  });

  /// Creates a copy with updated properties.
  TLoadOptions<T> copyWith({
    int? page,
    int? itemsPerPage,
    String? search,
  }) {
    return TLoadOptions<T>(
      page: page ?? this.page,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      search: search ?? this.search,
    );
  }

  @override
  String toString() => 'TLoadOptions<$T>(page: $page, itemsPerPage: $itemsPerPage, search: $search)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TLoadOptions<T> &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          itemsPerPage == other.itemsPerPage &&
          search == other.search;

  @override
  int get hashCode => Object.hash(page, itemsPerPage, search);
}

/// Result of a data load operation.
class TLoadResult<T> {
  /// The loaded items.
  final List<T> items;

  /// Total number of items available (for pagination).
  final int totalItems;

  /// Creates a load result.
  const TLoadResult(this.items, this.totalItems);

  /// Creates a copy with updated properties.
  TLoadResult<T> copyWith({
    List<T>? items,
    int? totalItems,
  }) {
    return TLoadResult<T>(
      items ?? this.items,
      totalItems ?? this.totalItems,
    );
  }

  @override
  String toString() {
    return 'TLoadResult<$T>(items: ${items.length}, totalItems: $totalItems)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TLoadResult<T> && runtimeType == other.runtimeType && items == other.items && totalItems == other.totalItems;

  @override
  int get hashCode => Object.hash(items, totalItems);
}

/// Grid layout mode.
enum TGridMode {
  /// Masonry layout (staggered).
  masonry,
  /// Aligned grid layout.
  aligned
}

/// Delegate for controlling grid layout.
class TGridDelegate {
  /// Fixed cross-axis count.
  final int? crossAxisCount;

  /// Maximum extent of cross-axis items.
  final double? maxCrossAxisExtent;

  /// Spacing along the main axis.
  final double mainAxisSpacing;

  /// Spacing along the cross axis.
  final double crossAxisSpacing;

  /// Creates a grid delegate.
  const TGridDelegate({
    this.crossAxisCount,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
  }) : assert(
          (crossAxisCount != null) ^ (maxCrossAxisExtent != null),
          'Either crossAxisCount OR maxCrossAxisExtent must be provided, but not both.',
        );

  /// Returns a [SliverSimpleGridDelegate] for internal use.
  SliverSimpleGridDelegate get simpleGridDelegate {
    final count = crossAxisCount;
    if (count != null) {
      return SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
      );
    }

    final extent = maxCrossAxisExtent;
    return SliverSimpleGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: extent ?? 350,
    );
  }

  /// Calculates items per row based on total width.
  int calculateItemsPerRow(double maxWidth) {
    if (crossAxisCount != null) {
      return crossAxisCount!;
    }

    final extent = maxCrossAxisExtent!;
    if (extent <= 0) return 1;

    final total = maxWidth;
    return (total / extent).ceil().clamp(1, 100);
  }
}
