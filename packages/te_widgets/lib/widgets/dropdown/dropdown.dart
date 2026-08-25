import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

typedef TDropdownTriggerMode = TMenuTriggerMode;

/// `TDropdown` is now a thin adapter over the shared [TMenuRootTrigger] —
/// all the hover/tap scheduling, positioning, and panel rendering live in
/// the generic engine under `lib/helpers/menu/`.
///
/// NOTE / known behavior change: the old implementation special-cased a
/// bare `TButton` child by rewiring the button's own `onTap` instead of
/// wrapping it in a `GestureDetector`, so the button kept its native
/// ripple/press feedback. `TMenuRootTrigger` always wraps `child` in a
/// translucent `GestureDetector` in tap mode, so a `TButton` passed here
/// will get an extra tap layer on top of its own. Functionally it still
/// opens/closes correctly; if you rely on the button's own press visuals
/// specifically, `TMenuRootTrigger` would need an injection point for a
/// custom tap handler — flagging rather than silently dropping it.
class TDropdown extends StatelessWidget {
  final TDropdownTheme? theme;
  final List<TDropdownItem> items;
  final Widget child;
  final TDropdownTriggerMode triggerMode;
  final bool enabled;
  final Widget Function(BuildContext context, VoidCallback close)? builder;

  const TDropdown({
    super.key,
    this.theme,
    this.items = const [],
    required this.child,
    this.triggerMode = TDropdownTriggerMode.hover,
    this.enabled = true,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return Opacity(opacity: 0.7, child: child);

    final effectiveTheme = theme ?? TDropdownTheme.defaultTheme(context.colors);
    final isMobile = context.isMobilePlatform || context.isMobile;
    final effectiveMode = (triggerMode == TDropdownTriggerMode.tap || isMobile) ? TMenuTriggerMode.tap : TMenuTriggerMode.hover;

    return TMenuRootTrigger<TDropdownItem>(
      items: items,
      theme: effectiveTheme,
      triggerMode: effectiveMode,
      builder: builder,
      onItemTap: (item) {
        item.onTap?.call();
        TMenuOverlayController.hideAll();
      },
      child: child,
    );
  }
}
