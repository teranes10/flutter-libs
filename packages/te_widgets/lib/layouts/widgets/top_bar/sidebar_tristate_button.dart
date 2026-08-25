import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

/// Tristate sidebar button using [TButtonGroup] in single-icon cycle mode.
/// In none mode, displays a down arrow icon (or menu icon) and reveals all overflow
/// navigation items in a dropdown overlay with full multi-level submenu support.
/// Cycles through: minified (right arrow) -> full (left arrow) -> none (down arrow) -> minified.
class SidebarTristateButton extends ConsumerWidget {
  final List<TSidebarItem> items;
  final ValueNotifier<List<TSidebarItem>>? overflowNotifier;
  final TSidebarTheme? theme;

  const SidebarTristateButton({
    super.key,
    this.items = const [],
    this.overflowNotifier,
    this.theme,
  });

  String _getCurrentRoute(BuildContext context) {
    try {
      return GoRouterState.of(context).matchedLocation;
    } catch (e) {
      return ModalRoute.of(context)?.settings.name ?? '/';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (overflowNotifier != null) {
      return ValueListenableBuilder<List<TSidebarItem>>(
        valueListenable: overflowNotifier!,
        builder: (context, overflow, _) {
          return _buildButton(context, ref, overflow);
        },
      );
    }
    return _buildButton(context, ref, items);
  }

  Widget _buildButton(BuildContext context, WidgetRef ref, List<TSidebarItem> currentItems) {
    final mode = ref.watch(sidebarNotifierProvider);
    final notifier = ref.read(sidebarNotifierProvider.notifier);
    final colors = context.colors;
    final currentRoute = _getCurrentRoute(context);

    final button = Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        shape: BoxShape.circle,
      ),
      child: TButtonGroup(
        cycle: true,
        type: TButtonGroupType.icon,
        size: TButtonSize.xs.copyWith(icon: 18),
        initialIndex: mode.index,
        onIndexChanged: (index) {
          notifier.setMode(TSidebarMode.values[index]);
        },
        items: [
          TButtonGroupItem(
            icon: Icons.chevron_right_rounded,
            tooltip: 'Sidebar: Minified',
            active: mode == TSidebarMode.minified,
          ),
          TButtonGroupItem(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Sidebar: Full',
            active: mode == TSidebarMode.full,
          ),
          TButtonGroupItem(
            icon: Icons.keyboard_arrow_down_rounded,
            tooltip: 'Menu (Sidebar: Hidden)',
            active: mode == TSidebarMode.none,
          ),
        ],
      ),
    );

    if (mode == TSidebarMode.none && currentItems.isNotEmpty) {
      final menuTheme = (theme ?? TSidebarTheme.defaultTheme(context)).copyWith(
        alignment: TPopupAlignment.bottomLeft,
        offset: 6.0,
        secondaryAlignment: TPopupAlignment.rightTop,
        secondaryOffset: 4.0,
      );

      return TMenuRootTrigger<TSidebarItem>(
        items: currentItems.where((i) => !i.isHidden).toList(),
        theme: menuTheme,
        triggerMode: TMenuTriggerMode.hover,
        isActive: (i) => i.route == currentRoute,
        containsActive: (i) => i.containsRoute(currentRoute),
        onItemTap: (i) {
          i.tap(context);
          TMenuOverlayController.hideAll();
        },
        child: button,
      );
    }

    return button;
  }
}

/// Backwards-compatible alias for [SidebarTristateButton].
class SidebarToggleButton extends StatelessWidget {
  final List<TSidebarItem> items;
  final TSidebarTheme? theme;

  const SidebarToggleButton({
    super.key,
    this.items = const [],
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SidebarTristateButton(items: items, theme: theme);
  }
}
