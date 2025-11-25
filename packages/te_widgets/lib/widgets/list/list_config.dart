import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:te_widgets/te_widgets.dart';

enum TItemAddPosition { first, last }

enum TSelectionMode { none, single, multiple }

enum TExpansionMode { none, single, multiple }

typedef ItemToString<T> = String Function(T item);
typedef ItemChildrenAccessor<T> = List<T>? Function(T item);
typedef ItemTextAccessor<T> = String Function(T item);
typedef ItemKeyAccessor<T, K> = K Function(T item);
typedef ListItemTap<T, K> = void Function(TListItem<T, K> item);
typedef ListItemFactory<T, K> = TListItem<T, K> Function(T item);
typedef ListItemBuilder<T, K> = Widget Function(BuildContext context, TListItem<T, K> item, int index);
typedef TLoadListener<T> = Future<TLoadResult<T>> Function(TLoadOptions<T> options);

typedef TListEmptyBuilder = Widget Function(BuildContext context);
typedef TListErrorBuilder = Widget Function(BuildContext context, TListError error);
typedef TListLoadingBuilder = Widget Function(BuildContext context);
typedef TListHeaderBuilder = Widget Function(BuildContext context);
typedef TListFooterBuilder = Widget Function(BuildContext context);
typedef TListSeparatorBuilder = Widget? Function(BuildContext context, int index);
typedef TListDragProxyDecorator = Widget Function(Widget, int, Animation<double>);
typedef TListReorderCallback = void Function(int, int);
typedef TGridDelegateBuilder = TGridDelegate Function(BuildContext context);

class TLoadOptions<T> {
  final int page;
  final int itemsPerPage;
  final String? search;

  int get offset => (page - 1) * itemsPerPage;
  int get limit => itemsPerPage;

  const TLoadOptions({
    required this.page,
    required this.itemsPerPage,
    this.search,
  });

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

class TLoadResult<T> {
  final List<T> items;
  final int totalItems;

  const TLoadResult(this.items, this.totalItems);

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

enum TGridMode { masonry, aligned }

class TGridDelegate {
  final int? crossAxisCount;
  final double? maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const TGridDelegate({
    this.crossAxisCount,
    this.maxCrossAxisExtent,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
  }) : assert(
          (crossAxisCount != null) ^ (maxCrossAxisExtent != null),
          'Either crossAxisCount OR maxCrossAxisExtent must be provided, but not both.',
        );

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
