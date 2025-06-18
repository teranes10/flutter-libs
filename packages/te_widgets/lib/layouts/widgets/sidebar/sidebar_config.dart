import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

class TSidebarItem {
  final IconData? icon;
  final String? text;
  final String? route;
  final Widget? page;
  final List<TSidebarItem>? children;
  final VoidCallback? onTap;
  final bool initiallyExpanded;

  const TSidebarItem({
    this.page,
    this.icon,
    this.text,
    this.route,
    this.children,
    this.onTap,
    this.initiallyExpanded = false,
  });

  bool containsRoute(String currentRoute) {
    if (route == currentRoute) return true;
    return children?.any((child) => child.containsRoute(currentRoute)) ?? false;
  }

  bool get hasChildren => children?.isNotEmpty ?? false;
  bool get isClickable => route != null || onTap != null;
}

class TSidebarConstants {
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration overlayAnimationDuration = Duration(milliseconds: 150);
  static const Duration hoverDelay = Duration(milliseconds: 200);
  static const Duration overlayHideDelay = Duration(milliseconds: 400);
  static const Duration smoothHideDelay = Duration(milliseconds: 400);

  static const double iconSize = 20.0;
  static const double overlayIconSize = 18.0;
  static const double expandIconSize = 16.0;
  static const double arrowIconSize = 12.0;

  static const EdgeInsets itemPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 14);
  static const EdgeInsets minimizedItemPadding = EdgeInsets.all(12);
  static const EdgeInsets overlayItemPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);
}

class TSidebarTheme {
  final Color defaultColor;
  final Color hoverColor;
  final Color activeColor;
  final Color activeBackgroundColor;
  final Color borderColor;

  const TSidebarTheme({
    required this.defaultColor,
    required this.hoverColor,
    required this.activeColor,
    required this.activeBackgroundColor,
    required this.borderColor,
  });

  factory TSidebarTheme.defaultTheme(BuildContext context) {
    return TSidebarTheme(
      defaultColor: AppColors.grey[500]!,
      hoverColor: AppColors.grey[400]!,
      activeColor: Theme.of(context).colorScheme.onPrimaryContainer,
      activeBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
      borderColor: AppColors.grey[100]!,
    );
  }

  Color getItemColor({
    required bool isActive,
    required bool containsActive,
    required bool isHovered,
  }) {
    if (isActive || containsActive) return activeColor;
    if (isHovered) return hoverColor;
    return defaultColor;
  }
}
