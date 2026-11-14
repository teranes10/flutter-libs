import 'package:flutter/material.dart';
import 'package:te_widgets/auth/auth_controller.dart';
import 'package:te_widgets/auth/auth_mode.dart';

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

  dynamic get icon;
  String? get text;
  List<T>? get children;
  bool get hidden;
  bool get isClickable;
  Color? get color => null;

  /// Optional image shown (circular) before the text, in place of [icon].
  String? get imageUrl => null;

  bool get hasVisibleChildren => visibleChildren.isNotEmpty;
  List<T> get visibleChildren => children?.where((c) => !c.isHidden).toList() ?? const [];
  bool get isHidden => hidden;

  /// Invoked when the item itself (not a child with a submenu) is activated.
  void tap(BuildContext context);

  Widget? get customContent => null;

  /// Permission (`String` or `TPermission`) required for this item.
  Object? get permission => null;

  /// Overrides the denied behaviour for this item.
  TAuthMode? get onDenied => null;

  /// Which [TAuthTarget] default applies to this kind of item.
  TAuthTarget get authTarget => TAuthTarget.menuItem;

  /// Whether a route-less group with no visible children should disappear.
  bool get hidesWhenEmpty => false;

  /// shadcn-style group: instead of opening a submenu popup (or a collapsible
  /// section), this item renders as a non-interactive text label with its
  /// [children] listed inline right beneath it. Leave `false` (default) to keep
  /// the nested popup / collapsible behaviour, so groups and popups can be mixed.
  bool get isGroup => false;

  /// For a [isGroup] item: draw a divider above its label. Off by default.
  bool get showDivider => false;

  TAuthResult authResult(BuildContext context) => context.authResolve(permission, target: authTarget, onDenied: onDenied);

  /// Context-aware [isHidden]: also honours permissions, recursively.
  bool isHiddenIn(BuildContext context) {
    if (isHidden || authResult(context).isHidden) return true;
    return (hidesWhenEmpty || isGroup) && !hasVisibleChildrenIn(context);
  }

  List<T> visibleChildrenIn(BuildContext context) => children?.where((c) => !c.isHiddenIn(context)).toList() ?? const [];

  bool hasVisibleChildrenIn(BuildContext context) => visibleChildrenIn(context).isNotEmpty;

  /// Context-aware [isClickable]: false when the item is disabled by permission.
  bool isClickableIn(BuildContext context) => isClickable && !authResult(context).isDisabled;
}
