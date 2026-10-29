import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A top-level menu (e.g. "File", "Edit") inside a [TMenubar].
class TMenubarMenu {
  /// The menu's label in the bar.
  final String label;

  /// The dropdown items shown when opened. Use [TDropdownItem] — the same
  /// model `TDropdown` and the sidebar use, so dividers
  /// (`TDropdownItem(customContent: Divider(...))`) and nested submenus
  /// (via `children`) work the same way here too.
  final List<TDropdownItem> items;

  /// Permission (`String` or [TPermission]) required to use this menu.
  final Object? permission;

  /// Overrides the denied behaviour (default: the menu stays but cannot open).
  final TAuthMode? onDenied;

  const TMenubarMenu({required this.label, required this.items, this.permission, this.onDenied});
}

/// A desktop-application-style horizontal menu bar with nested dropdown
/// menus (File, Edit, View, …), for admin tools that need classic app chrome
/// above or inside [TLayout].
///
/// Built directly on [TMenuRootTrigger] — the same hover/tap-to-open-panel
/// engine behind [TDropdown] and the sidebar's submenus — so each top-level
/// label is just a dropdown trigger positioned in a row; no separate
/// overlay/positioning logic lives in this widget.
///
/// ```dart
/// TMenubar(
///   menus: [
///     TMenubarMenu(label: 'File', items: [
///       TDropdownItem(text: 'New', icon: Icons.note_add, onTap: _onNew),
///       const TDropdownItem(customContent: Divider(height: 1)),
///       TDropdownItem(text: 'Exit', onTap: _onExit),
///     ]),
///   ],
/// )
/// ```
class TMenubar extends StatelessWidget {
  /// The top-level menus, in display order.
  final List<TMenubarMenu> menus;

  const TMenubar({super.key, required this.menus});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final menuTheme = TDropdownTheme.defaultTheme(colors).copyWith(
      alignment: TPopupAlignment.bottomLeft,
      offset: 0,
    );

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          for (final menu in menus)
            if (!context.authResolve(menu.permission, target: TAuthTarget.menuItem, onDenied: menu.onDenied).isHidden)
              Opacity(
                opacity: context.authResolve(menu.permission, target: TAuthTarget.menuItem, onDenied: menu.onDenied).isDisabled ? 0.45 : 1,
                child: TMenuRootTrigger<TDropdownItem>(
                  items: context.authResolve(menu.permission, target: TAuthTarget.menuItem, onDenied: menu.onDenied).isDisabled
                      ? const []
                      : menu.items,
                  theme: menuTheme,
                  triggerMode: TMenuTriggerMode.hover,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    child: Text(
                      menu.label,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurface),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
