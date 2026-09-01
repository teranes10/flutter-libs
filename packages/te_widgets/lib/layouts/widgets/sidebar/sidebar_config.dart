import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

class TSidebarItem extends TMenuItemData<TSidebarItem> {
  final Widget? page;
  final Widget Function(BuildContext context, GoRouterState state)? builder;
  @override
  final dynamic icon;
  @override
  final String? text;
  final String? route;
  @override
  final List<TSidebarItem>? children;
  final VoidCallback? onTap;
  final bool initiallyExpanded;
  final Object? extra;
  @override
  final bool hidden;
  final bool home;
  final int? bottomBarPosition;

  const TSidebarItem({
    this.page,
    this.builder,
    this.icon,
    this.text,
    this.route,
    this.children,
    this.onTap,
    this.initiallyExpanded = false,
    this.extra,
    this.hidden = false,
    this.home = false,
    this.bottomBarPosition,
  });

  TSidebarItem copyWith({
    Widget? page,
    Widget Function(BuildContext context, GoRouterState state)? builder,
    dynamic icon,
    String? text,
    String? route,
    List<TSidebarItem>? children,
    VoidCallback? onTap,
    bool? initiallyExpanded,
    Object? extra,
    bool? hidden,
    bool? home,
    int? bottomBarPosition,
  }) {
    return TSidebarItem(
      page: page ?? this.page,
      builder: builder ?? this.builder,
      icon: icon ?? this.icon,
      text: text ?? this.text,
      route: route ?? this.route,
      children: children ?? this.children,
      onTap: onTap ?? this.onTap,
      initiallyExpanded: initiallyExpanded ?? this.initiallyExpanded,
      extra: extra ?? this.extra,
      hidden: hidden ?? this.hidden,
      home: home ?? this.home,
      bottomBarPosition: bottomBarPosition ?? this.bottomBarPosition,
    );
  }

  @override
  String toString() => "$text -> $route";

  bool containsRoute(String currentRoute) {
    if (route == currentRoute) return true;
    return visibleChildren.any((child) => child.containsRoute(currentRoute));
  }

  @override
  bool get isHidden {
    if (hidden) return true;
    if (route == null && !hasVisibleChildren) return true;
    return false;
  }

  @override
  bool get isClickable => route != null || onTap != null;

  @override
  void tap(BuildContext context) {
    _navigate(context);
    onTap?.call();
  }

  void _navigate(BuildContext context) {
    if (route == null) return;
    try {
      if (route!.containsInMiddle('/')) {
        context.push(route!, extra: extra);
      } else {
        context.go(route!, extra: extra);
      }
    } catch (e) {
      debugPrint('TSidebarItem._navigate error: $e');
    }
  }
}

/// Sidebar-flavored [TMenuTheme]. The overlay-specific constants that used
/// to live as bare statics on `TSidebarConstants` (overlay animation
/// duration, overlay item padding, overlay/arrow icon sizes, hover/hide
/// delays) now live here instead, since the shared overlay engine reads
/// timing/sizing from an instance of `TMenuTheme`, not from a static
/// constants class. That's what made it possible to hand the sidebar's
/// popups to the same engine the dropdown uses.
class TSidebarTheme extends TMenuTheme {
  final EdgeInsets childPadding;
  final EdgeInsets minimizedItemPadding;
  final double expandIconSize;

  const TSidebarTheme({
    required super.defaultColor,
    required super.hoverColor,
    required super.activeColor,
    required super.activeBackgroundColor,
    required super.borderColor,
    this.childPadding = const EdgeInsets.fromLTRB(12, 9, 6, 9),
    this.minimizedItemPadding = const EdgeInsets.all(12),
    this.expandIconSize = 16.0,
    super.animationDuration = const Duration(milliseconds: 150),
    super.showDelay = const Duration(milliseconds: 200),
    super.hideDelay = const Duration(milliseconds: 400),
    // Root trigger (minimized icon) pops out to the right, same spot the
    // old `CompositedTransformFollower(offset: Offset(14, -8))` used.
    super.alignment = TPopupAlignment.rightTop,
    super.offset = 14.0,
    super.secondaryAlignment = TPopupAlignment.rightTop,
    super.secondaryOffset = 4.0,
    super.boxConstraints = const BoxConstraints(minWidth: 180, maxWidth: 275),
    super.iconSize = 18.0,
    super.arrowIconSize = 12.0,
    super.gap = 10.0,
    super.overlayElevation = 8.0,
    super.overlayBorderRadius = const BorderRadius.all(Radius.circular(8.0)),
    super.overlayPadding = const EdgeInsets.symmetric(vertical: 8),
    super.itemPadding = const EdgeInsets.fromLTRB(16, 12, 8, 12),
    super.itemBorderRadius = const BorderRadius.all(Radius.circular(6.0)),
    super.fontSize = 14.0,
    super.fontWeight = FontWeight.w300,
    super.arrowIcon,
    super.dropdownIcon,
    super.expandIcon,
  });

  factory TSidebarTheme.defaultTheme(BuildContext context) {
    final colors = context.colors;

    return TSidebarTheme(
      defaultColor: colors.onSurfaceVariant,
      hoverColor: colors.onSurface,
      activeColor: colors.onPrimaryContainer,
      activeBackgroundColor: colors.primaryContainer,
      borderColor: colors.outlineVariant,
    );
  }

  @override
  TSidebarTheme copyWith({
    Color? defaultColor,
    Color? hoverColor,
    Color? activeColor,
    Color? activeBackgroundColor,
    Color? borderColor,
    EdgeInsets? childPadding,
    EdgeInsets? minimizedItemPadding,
    double? expandIconSize,
    Duration? animationDuration,
    Duration? showDelay,
    Duration? hideDelay,
    TPopupAlignment? alignment,
    double? offset,
    TPopupAlignment? secondaryAlignment,
    double? secondaryOffset,
    BoxConstraints? boxConstraints,
    double? iconSize,
    double? arrowIconSize,
    double? gap,
    double? overlayElevation,
    BorderRadius? overlayBorderRadius,
    EdgeInsets? overlayPadding,
    EdgeInsets? itemPadding,
    BorderRadius? itemBorderRadius,
    double? fontSize,
    FontWeight? fontWeight,
    IconData? arrowIcon,
    IconData? dropdownIcon,
    IconData? expandIcon,
  }) {
    return TSidebarTheme(
      defaultColor: defaultColor ?? this.defaultColor,
      hoverColor: hoverColor ?? this.hoverColor,
      activeColor: activeColor ?? this.activeColor,
      activeBackgroundColor: activeBackgroundColor ?? this.activeBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      childPadding: childPadding ?? this.childPadding,
      minimizedItemPadding: minimizedItemPadding ?? this.minimizedItemPadding,
      expandIconSize: expandIconSize ?? this.expandIconSize,
      animationDuration: animationDuration ?? this.animationDuration,
      showDelay: showDelay ?? this.showDelay,
      hideDelay: hideDelay ?? this.hideDelay,
      alignment: alignment ?? this.alignment,
      offset: offset ?? this.offset,
      secondaryAlignment: secondaryAlignment ?? this.secondaryAlignment,
      secondaryOffset: secondaryOffset ?? this.secondaryOffset,
      boxConstraints: boxConstraints ?? this.boxConstraints,
      iconSize: iconSize ?? this.iconSize,
      arrowIconSize: arrowIconSize ?? this.arrowIconSize,
      gap: gap ?? this.gap,
      overlayElevation: overlayElevation ?? this.overlayElevation,
      overlayBorderRadius: overlayBorderRadius ?? this.overlayBorderRadius,
      overlayPadding: overlayPadding ?? this.overlayPadding,
      itemPadding: itemPadding ?? this.itemPadding,
      itemBorderRadius: itemBorderRadius ?? this.itemBorderRadius,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      arrowIcon: arrowIcon ?? this.arrowIcon,
      dropdownIcon: dropdownIcon ?? this.dropdownIcon,
      expandIcon: expandIcon ?? this.expandIcon,
    );
  }
}

class TSidebarItemsResolver {
  /// Resolves relative paths and validates the sidebar item hierarchy.
  static List<TSidebarItem> resolve(List<TSidebarItem> items) {
    bool homeFound = false;
    final Set<String> routes = {};

    List<TSidebarItem> resolveInternal(List<TSidebarItem> items, {String? parentPath}) {
      return items.map((item) {
        // 1. Resolve Path
        String? resolvedRoute = item.route;

        if (resolvedRoute != null) {
          if (parentPath != null) {
            if (resolvedRoute.contains('/')) {
              throw ArgumentError(
                "TLayout: The child item's route '${item.route}' must be a single child path name only (no '/', no parent path, and no nested segments)",
              );
            }

            resolvedRoute = parentPath.endsWith('/') ? '$parentPath$resolvedRoute' : '$parentPath/$resolvedRoute';
          }
        }

        // 2. Validation: Multiple Homes
        if (item.home) {
          if (homeFound) {
            throw ArgumentError('TLayout: Multiple items marked as home. Only one item can be home.');
          }
          homeFound = true;
        }

        // 3. Validation: Bottom Bar Position
        if (item.bottomBarPosition != null) {
          if (item.bottomBarPosition! > 3) {
            throw ArgumentError('TLayout: Bottom bar position cannot be greater than 3.');
          }
          if (item.children?.isNotEmpty ?? false) {
            throw ArgumentError('TLayout: Bottom bar items cannot have children.');
          }
        }

        // 4. Validation: Duplicate Routes
        if (resolvedRoute != null && resolvedRoute.isNotEmpty && !resolvedRoute.contains(':')) {
          if (routes.contains(resolvedRoute)) {
            throw ArgumentError('TLayout: Duplicate route detected: $resolvedRoute');
          }
          routes.add(resolvedRoute);
        }

        // 5. Recursive children resolution
        final resolvedChildren = item.children != null ? resolveInternal(item.children!, parentPath: resolvedRoute) : null;

        return item.copyWith(
          route: resolvedRoute,
          children: resolvedChildren,
        );
      }).toList();
    }

    final resolvedItems = resolveInternal(items);

    // Default home if none found
    if (!homeFound && resolvedItems.isNotEmpty) {
      resolvedItems[0] = resolvedItems[0].copyWith(home: true);
    }

    return resolvedItems;
  }
}
