import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A versatile empty state placeholder widget.
///
/// `TEmptyState` provides standardized placeholders for empty lists, search misses,
/// 404 views, failed queries, and initial dashboard states.
///
/// ## Named Constructors
/// - [TEmptyState.noData] — Standard "No data available" empty state.
/// - [TEmptyState.search] — Empty state when a search query yields no matches.
/// - [TEmptyState.notFound] — 404 or missing entity empty state.
/// - [TEmptyState.error] — Failure / error state with retry action.
/// - [TEmptyState.compact] — Low-profile single-line or mini placeholder for dropdowns or cards.
///
/// ## Basic Usage
///
/// ```dart
/// // Standard empty state with action
/// TEmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'No Customers Yet',
///   description: 'Get started by creating your first customer account.',
///   action: TButton(
///     text: 'Add Customer',
///     icon: Icons.add,
///     onTap: () => openAddCustomer(),
///   ),
/// )
///
/// // Search results empty state
/// TEmptyState.search(
///   query: 'Widgets',
///   onClear: () => searchController.clear(),
/// )
/// ```
class TEmptyState extends StatelessWidget {
  /// The icon to display. Supports [IconData], HugeIcon, or a custom [Widget].
  final dynamic icon;

  /// Custom illustration or image widget displayed instead of [icon].
  final Widget? image;

  /// Primary title text.
  final String? title;

  /// Custom title widget replacing [title].
  final Widget? titleWidget;

  /// Secondary descriptive text.
  final String? description;

  /// Custom description widget replacing [description].
  final Widget? descriptionWidget;

  /// Primary call-to-action button or widget.
  final Widget? action;

  /// Secondary call-to-action button or link.
  final Widget? secondaryAction;

  /// Whether to render a low-profile compact layout (ideal for dropdowns, small cards, or side sheets).
  final bool compact;

  /// Padding around the entire empty state container.
  final EdgeInsetsGeometry padding;

  /// Custom color for the icon.
  final Color? iconColor;

  /// Custom background color for the circular icon container.
  final Color? iconBackgroundColor;

  /// Size of the icon. Defaults to 32.0 in normal mode, 20.0 in compact mode.
  final double? iconSize;

  /// Creates a customizable empty state widget.
  const TEmptyState({
    super.key,
    this.icon,
    this.image,
    this.title,
    this.titleWidget,
    this.description,
    this.descriptionWidget,
    this.action,
    this.secondaryAction,
    this.compact = false,
    this.padding = const EdgeInsets.all(32.0),
    this.iconColor,
    this.iconBackgroundColor,
    this.iconSize,
  });

  /// Creates a standard "No Data" placeholder.
  const TEmptyState.noData({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.image,
    this.title = 'No data available',
    this.titleWidget,
    this.description = 'There are no records to display at this time.',
    this.descriptionWidget,
    this.action,
    this.secondaryAction,
    this.compact = false,
    this.padding = const EdgeInsets.all(32.0),
    this.iconColor,
    this.iconBackgroundColor,
    this.iconSize,
  });

  /// Creates a search results empty state placeholder.
  factory TEmptyState.search({
    Key? key,
    String? query,
    String? title,
    String? description,
    VoidCallback? onClear,
    Widget? action,
    bool compact = false,
    EdgeInsetsGeometry padding = const EdgeInsets.all(32.0),
  }) {
    final effectiveTitle = title ?? (query != null && query.isNotEmpty ? 'No results for "$query"' : 'No matching results');
    final effectiveDesc = description ?? 'Try checking for spelling errors or adjusting your search filters.';

    final effectiveAction = action ??
        (onClear != null
            ? TButton(
                text: 'Clear Search',
                icon: Icons.clear_rounded,
                type: TButtonType.tonal,
                size: TButtonSize.xs,
                onPressed: (_) => onClear(),
              )
            : null);

    return TEmptyState(
      key: key,
      icon: Icons.search_off_rounded,
      title: effectiveTitle,
      description: effectiveDesc,
      action: effectiveAction,
      compact: compact,
      padding: padding,
    );
  }

  /// Creates a 404 or missing resource empty state.
  const TEmptyState.notFound({
    super.key,
    this.icon = Icons.find_in_page_outlined,
    this.image,
    this.title = 'Item Not Found',
    this.titleWidget,
    this.description = 'The item or resource you requested could not be located.',
    this.descriptionWidget,
    this.action,
    this.secondaryAction,
    this.compact = false,
    this.padding = const EdgeInsets.all(32.0),
    this.iconColor,
    this.iconBackgroundColor,
    this.iconSize,
  });

  /// Creates an error / failure empty state with an optional retry callback.
  factory TEmptyState.error({
    Key? key,
    String title = 'Something went wrong',
    String description = 'Failed to load data. Please check your connection and try again.',
    VoidCallback? onRetry,
    Widget? action,
    bool compact = false,
    EdgeInsetsGeometry padding = const EdgeInsets.all(32.0),
  }) {
    final effectiveAction = action ??
        (onRetry != null
            ? TButton(
                text: 'Try Again',
                icon: Icons.refresh_rounded,
                type: TButtonType.tonal,
                size: TButtonSize.xs,
                onPressed: (_) => onRetry(),
              )
            : null);

    return TEmptyState(
      key: key,
      icon: Icons.error_outline_rounded,
      iconColor: Colors.redAccent,
      title: title,
      description: description,
      action: effectiveAction,
      compact: compact,
      padding: padding,
    );
  }

  /// Creates a compact empty state for small cards, popovers, or table cells.
  const TEmptyState.compact({
    super.key,
    this.icon = Icons.inbox_outlined,
    String message = 'No items found',
    this.action,
    this.iconColor,
    this.iconBackgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  })  : title = null,
        titleWidget = null,
        description = message,
        descriptionWidget = null,
        secondaryAction = null,
        image = null,
        compact = true,
        iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (compact) {
      return Center(
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                TIcon.raw(
                  icon,
                  size: iconSize ?? 18.0,
                  color: iconColor ?? colors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8.0),
              ],
              Flexible(
                child: Text(
                  description ?? title ?? 'No data',
                  style: TextStyle(
                    fontSize: 13.0,
                    color: colors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 12.0),
                action!,
              ],
            ],
          ),
        ),
      );
    }

    Widget? visualNode;
    if (image != null) {
      visualNode = image;
    } else if (icon != null) {
      final effectiveIconColor = iconColor ?? colors.onSurfaceVariant.withValues(alpha: 0.85);
      final effectiveBgColor = iconBackgroundColor ?? colors.surfaceContainerHighest.withValues(alpha: 0.5);
      final size = iconSize ?? 30.0;

      visualNode = Container(
        width: size * 2.0,
        height: size * 2.0,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: TIcon.raw(
          icon,
          size: size,
          color: effectiveIconColor,
        ),
      );
    }

    Widget? titleNode;
    if (titleWidget != null) {
      titleNode = titleWidget;
    } else if (title != null) {
      titleNode = Text(
        title!,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      );
    }

    Widget? descNode;
    if (descriptionWidget != null) {
      descNode = descriptionWidget;
    } else if (description != null) {
      descNode = Text(
        description!,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.5,
          color: colors.onSurfaceVariant,
          height: 1.4,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (visualNode != null) ...[
                visualNode,
                const SizedBox(height: 16.0),
              ],
              if (titleNode != null) titleNode,
              if (titleNode != null && descNode != null) const SizedBox(height: 6.0),
              if (descNode != null) descNode,
              if (action != null || secondaryAction != null) ...[
                const SizedBox(height: 18.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (action != null) action!,
                    if (secondaryAction != null) secondaryAction!,
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
