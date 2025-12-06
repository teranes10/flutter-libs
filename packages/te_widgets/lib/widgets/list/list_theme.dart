import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Theme configuration for [TList].
///
/// `TListTheme` defines global list behavior and appearance, including:
/// - Animations
/// - Scroll physics
/// - Padding
/// - Builders for states (empty, error, loading)
/// - Sticky headers/footers
/// - Drag and drop styling
class TListTheme {
  final TListAnimationBuilder? animationBuilder;
  final Duration animationDuration;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final TListEmptyBuilder? emptyStateBuilder;
  final TListErrorBuilder? errorStateBuilder;
  final TListLoadingBuilder? loadingBuilder;
  final TListHeaderBuilder? headerBuilder;
  final TListFooterBuilder? footerBuilder;
  final bool? headerSticky;
  final bool? footerSticky;
  final bool? infiniteScroll;
  final double itemBaseHeight;
  final TListFooterBuilder infiniteScrollFooterBuilder;
  final TListSeparatorBuilder? listSeparatorBuilder;
  final TListDragProxyDecorator? dragProxyDecorator;
  final TGridMode? grid;
  final TGridDelegateBuilder? gridDelegate;

  /// Creates a list theme.
  const TListTheme({
    this.animationBuilder = TListAnimationBuilders.staggered,
    this.animationDuration = const Duration(milliseconds: 800),
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.emptyStateBuilder,
    this.errorStateBuilder,
    this.loadingBuilder,
    this.headerBuilder,
    this.headerSticky,
    this.footerBuilder,
    this.footerSticky,
    this.infiniteScroll,
    double? itemBaseHeight,
    required this.infiniteScrollFooterBuilder,
    this.listSeparatorBuilder,
    this.dragProxyDecorator,
    this.grid,
    this.gridDelegate,
  })  : assert(!shrinkWrap || infiniteScroll != true, 'TListTheme: shrinkWrap disables scrolling, so infiniteScroll cannot be used.'),
        assert(!shrinkWrap || headerSticky != true, 'TListTheme: shrinkWrap disables scrolling, so headerSticky cannot be used.'),
        assert(!shrinkWrap || footerSticky != true, 'TListTheme: shrinkWrap disables scrolling, so footerSticky cannot be used.'),
        itemBaseHeight = grid != null ? 200 : 40;

  /// Creates a copy of the theme with updated properties.
  TListTheme copyWith({
    TListAnimationBuilder? animationBuilder,
    Duration? animationDuration,
    bool? shrinkWrap,
    ScrollPhysics? physics,
    EdgeInsets? padding,
    TListEmptyBuilder? emptyStateBuilder,
    TListErrorBuilder? errorStateBuilder,
    TListLoadingBuilder? loadingBuilder,
    TListHeaderBuilder? headerBuilder,
    TListFooterBuilder? footerBuilder,
    bool? headerSticky,
    bool? footerSticky,
    bool? infiniteScroll,
    double? itemBaseHeight,
    TListFooterBuilder? infiniteScrollFooterBuilder,
    TListSeparatorBuilder? listSeparatorBuilder,
    TListDragProxyDecorator? dragProxyDecorator,
    TGridMode? grid,
    TGridDelegateBuilder? gridDelegate,
  }) {
    return TListTheme(
      animationBuilder: animationBuilder ?? this.animationBuilder,
      animationDuration: animationDuration ?? this.animationDuration,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      physics: physics ?? this.physics,
      padding: padding ?? this.padding,
      emptyStateBuilder: emptyStateBuilder ?? this.emptyStateBuilder,
      errorStateBuilder: errorStateBuilder ?? this.errorStateBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      headerBuilder: headerBuilder ?? this.headerBuilder,
      headerSticky: headerSticky ?? this.headerSticky,
      footerBuilder: footerBuilder ?? this.footerBuilder,
      footerSticky: footerSticky ?? this.footerSticky,
      infiniteScroll: infiniteScroll ?? this.infiniteScroll,
      itemBaseHeight: itemBaseHeight ?? this.itemBaseHeight,
      infiniteScrollFooterBuilder: infiniteScrollFooterBuilder ?? this.infiniteScrollFooterBuilder,
      listSeparatorBuilder: listSeparatorBuilder ?? this.listSeparatorBuilder,
      dragProxyDecorator: dragProxyDecorator ?? this.dragProxyDecorator,
      grid: grid ?? this.grid,
      gridDelegate: gridDelegate ?? this.gridDelegate,
    );
  }

  /// Creates a default theme derived from the context colors.
  factory TListTheme.defaultTheme(ColorScheme colors) {
    return TListTheme(
      loadingBuilder: (BuildContext context) {
        return SizedBox(
          height: 4,
          child: LinearProgressIndicator(
            backgroundColor: colors.primaryContainer,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          ),
        );
      },
      infiniteScrollFooterBuilder: (BuildContext context) {
        final controller = TListScope.maybeOf(context)?.controller;
        final showLoading = controller != null ? controller.listItems.isNotEmpty && controller.isLoading : false;
        final showNoMoreItems = controller != null ? controller.page > 1 && !controller.hasMoreItems : false;

        if (showLoading) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 14,
              children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary)),
                Text('Loading...', style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
              ],
            ),
          );
        }

        if (showNoMoreItems) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('No more items to display.',
                style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant), textAlign: TextAlign.center),
          );
        }

        return const SizedBox(height: 40);
      },
      dragProxyDecorator: (Widget child, int index, Animation<double> animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final animValue = Curves.easeInOut.transform(animation.value);
            final elevation = lerpDouble(0, 8, animValue) ?? 0;
            final scale = lerpDouble(1.0, 1.01, animValue) ?? 1.0;

            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: elevation,
                color: Colors.transparent,
                shadowColor: context.colors.shadow,
                borderRadius: BorderRadius.circular(8),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  /// Builds a default empty state widget.
  static Widget buildEmptyState(
    ColorScheme colors, {
    IconData icon = Icons.inbox_outlined,
    String title = 'No data available',
    message = 'No items found',
  }) {
    return LayoutBuilder(builder: (_, constraints) {
      return constraints.maxWidth > 250
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 64, color: colors.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colors.onSurface)),
                    const SizedBox(height: 8),
                    Text(message, style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant), textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : Center(
              child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Text(message),
            ));
    });
  }

  /// Builds a default error state widget.
  static Widget buildErrorState(
    ColorScheme colors, {
    IconData icon = Icons.error_outline,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colors.onSurface)),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
