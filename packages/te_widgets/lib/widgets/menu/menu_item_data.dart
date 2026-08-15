import 'package:flutter/material.dart';

/// Generic contract for anything the shared overlay-menu engine
/// (`TMenuOverlayPanel` / `TMenuOverlayItem` / `TMenuRootTrigger`) can render.
///
/// `TDropdownItem` and `TSidebarItem` both `extends` this instead of each
/// re-implementing hover/overlay/positioning logic on their own model.
/// Extend (not just implement) so the default `hasVisibleChildren` /
/// `visibleChildren` / `isHidden` implementations are inherited for free —
/// override them only where a concrete item type needs different rules
/// (e.g. `TSidebarItem.isHidden` also hides route-less leaf items).
abstract class TMenuItemData<T extends TMenuItemData<T>> {
  const TMenuItemData();

  IconData? get icon;
  String? get text;
  List<T>? get children;
  bool get hidden;
  bool get isClickable;
  Color? get color => null;

  bool get hasVisibleChildren => visibleChildren.isNotEmpty;
  List<T> get visibleChildren => children?.where((c) => !c.isHidden).toList() ?? const [];
  bool get isHidden => hidden;

  /// Invoked when the item itself (not a child with a submenu) is activated.
  void tap(BuildContext context);
}
