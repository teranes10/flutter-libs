import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

export 'layout1.dart';
export 'layout2.dart';

/// Renders [TLayout1] or [TLayout2] depending on the user's chosen
/// [TLayoutStyle] (changeable from the profile menu), or [style] if given.
class TLayout extends ConsumerWidget {
  final List<TSidebarItem> items;
  final Widget? logo;
  final Widget? minifiedLogo;
  final Widget? profile;
  final List<Widget>? actions;
  final Widget child;
  final String? pageTitle;
  final double? minWidth;
  final double maxWidth;
  final bool showHamburgerMenu;
  final bool showThemeToggle;
  final bool showFullscreenToggle;
  final bool showColorToggle;
  final bool showLogout;
  final VoidCallback? onLogout;
  final TSidebarTheme? sidebarTheme;

  /// Forces a layout instead of following the saved preference.
  final TLayoutStyle? style;

  const TLayout({
    super.key,
    this.items = const [],
    this.logo,
    this.minifiedLogo,
    this.profile,
    this.actions,
    required this.child,
    this.pageTitle,
    this.minWidth = 235,
    this.maxWidth = 300,
    this.showHamburgerMenu = false,
    this.showThemeToggle = true,
    this.showFullscreenToggle = true,
    this.showColorToggle = true,
    this.showLogout = true,
    this.onLogout,
    this.sidebarTheme,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(themeNotifierProvider.select((s) => s.layoutStyle));
    final TLayoutStyle effective = style ?? saved;

    return switch (effective) {
      TLayoutStyle.layout1 => TLayout1(
          items: items,
          logo: logo,
          minifiedLogo: minifiedLogo,
          profile: profile,
          actions: actions,
          pageTitle: pageTitle,
          minWidth: minWidth,
          maxWidth: maxWidth,
          showHamburgerMenu: showHamburgerMenu,
          showThemeToggle: showThemeToggle,
          showFullscreenToggle: showFullscreenToggle,
          showColorToggle: showColorToggle,
          showLogout: showLogout,
          onLogout: onLogout,
          sidebarTheme: sidebarTheme,
          child: child,
        ),
      TLayoutStyle.layout2 => TLayout2(
          items: items,
          logo: logo,
          minifiedLogo: minifiedLogo,
          profile: profile,
          actions: actions,
          pageTitle: pageTitle,
          minWidth: minWidth,
          maxWidth: maxWidth,
          showHamburgerMenu: showHamburgerMenu,
          showThemeToggle: showThemeToggle,
          showFullscreenToggle: showFullscreenToggle,
          showColorToggle: showColorToggle,
          showLogout: showLogout,
          onLogout: onLogout,
          sidebarTheme: sidebarTheme,
          child: child,
        ),
    };
  }
}
