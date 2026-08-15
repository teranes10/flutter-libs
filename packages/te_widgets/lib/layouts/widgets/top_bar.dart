import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────
// Top bars
// ─────────────────────────────────────────────────────────────────────────

class LayoutMobileTopBar extends StatelessWidget {
  const LayoutMobileTopBar({
    super.key,
    required this.resolvedItems,
    required this.showHamburgerMenu,
    required this.isSidebarOpen,
    required this.onToggleSidebar,
  });

  final List<TSidebarItem> resolvedItems;
  final bool showHamburgerMenu;
  final bool isSidebarOpen;
  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (Navigator.canPop(context))
                  TButton(
                    type: TButtonType.icon,
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                Expanded(
                  child: TBreadcrumbs(
                    items: resolvedItems,
                    includeHome: false,
                    homeLabel: 'Home',
                    homeRoute: '/',
                  ),
                ),
              ],
            ),
          ),
          if (showHamburgerMenu) ...[
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: TButton(
                key: ValueKey(isSidebarOpen),
                type: TButtonType.icon,
                icon: isSidebarOpen ? Icons.close_rounded : Icons.menu_rounded,
                size: TButtonSize.md.copyWith(icon: 20),
                color: colors.onSurface,
                onTap: onToggleSidebar,
                tooltip: isSidebarOpen ? 'Close menu' : 'Open menu',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LayoutDesktopTopBar extends StatelessWidget {
  const LayoutDesktopTopBar({
    super.key,
    required this.homeItem,
    required this.resolvedItems,
    required this.profile,
    required this.showThemeToggle,
    required this.showColorToggle,
    required this.actions,
    required this.showFullscreenToggle,
    required this.showLogout,
    required this.onLogout,
  });

  final TSidebarItem? homeItem;
  final List<TSidebarItem> resolvedItems;
  final Widget? profile;
  final bool showThemeToggle;
  final bool showColorToggle;
  final List<Widget>? actions;
  final bool showFullscreenToggle;
  final bool showLogout;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 9),
      child: Row(
        children: [
          const SidebarToggleButton(),
          const SizedBox(width: 10),
          Expanded(
            child: TBreadcrumbs(
              items: resolvedItems,
              includeHome: homeItem != null,
              homeLabel: homeItem?.text ?? 'Home',
              homeRoute: homeItem?.route ?? '/',
            ),
          ),
          LayoutActionsRow(
            profile: profile,
            showThemeToggle: showThemeToggle,
            showColorToggle: showColorToggle,
            actions: actions,
            showFullscreenToggle: showFullscreenToggle,
            showLogout: showLogout,
            onLogout: onLogout,
          ),
          const SizedBox(width: 15),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Scoped, single-purpose action buttons
// ─────────────────────────────────────────────────────────────────────────

/// Watches only `sidebarNotifierProvider`, so toggling the sidebar no
/// longer rebuilds the entire top bar.
class SidebarToggleButton extends ConsumerWidget {
  const SidebarToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isMinimized = ref.watch(sidebarNotifierProvider);
    final notifier = ref.read(sidebarNotifierProvider.notifier);

    return TTooltip(
      message: isMinimized ? 'Expand sidebar' : 'Collapse sidebar',
      color: colors.onSurfaceVariant,
      child: TIcon(
        icon: Icons.chevron_left_rounded,
        size: 20,
        color: colors.onSurfaceVariant,
        background: colors.surfaceContainerLowest,
        active: isMinimized,
        turns: (0, 0.5),
        onTap: notifier.toggleSidebar,
      ),
    );
  }
}

class LayoutThemeToggleButton extends ConsumerWidget {
  const LayoutThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;

    return TButton(
      size: TButtonSize.xs.copyWith(icon: 16),
      type: TButtonType.icon,
      icon: Icons.wb_sunny,
      color: Colors.yellow.shade700,
      activeIcon: Icons.nights_stay,
      activeColor: Colors.cyan.shade600,
      active: isDark,
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onChanged: (_) => ref.read(themeNotifierProvider.notifier).toggleTheme(),
    );
  }
}

class LayoutColorToggleButton extends ConsumerWidget {
  const LayoutColorToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeColorIndex = ref.watch(themeNotifierProvider).primaryColorIndex;
    final selectedColorOption = primaryColorOptions[activeColorIndex];

    return TDropdown(
      triggerMode: TDropdownTriggerMode.tap,
      items: [
        for (var i = 0; i < primaryColorOptions.length; i++)
          TDropdownItem(
            text: primaryColorOptions[i].name,
            icon: Icons.circle,
            color: primaryColorOptions[i].color,
            onTap: () => ref.read(themeNotifierProvider.notifier).selectColor(i),
          ),
      ],
      child: TButton(
        size: TButtonSize.xs.copyWith(icon: 16),
        type: TButtonType.icon,
        icon: Icons.palette_outlined,
        color: selectedColorOption.color,
        tooltip: 'Accent color',
      ),
    );
  }
}

/// Manages its own `TFullscreen` listener, so entering/exiting fullscreen
/// only rebuilds this button instead of the whole layout.
class LayoutFullscreenToggleButton extends StatefulWidget {
  const LayoutFullscreenToggleButton({super.key});

  @override
  State<LayoutFullscreenToggleButton> createState() => _LayoutFullscreenToggleButtonState();
}

class _LayoutFullscreenToggleButtonState extends State<LayoutFullscreenToggleButton> {
  late bool _isFullscreen = TFullscreen.isFullscreen;

  @override
  void initState() {
    super.initState();
    TFullscreen.registerListener(_onFullscreenChange);
  }

  void _onFullscreenChange(bool isFullscreen) {
    if (!mounted) return;
    setState(() => _isFullscreen = isFullscreen);
  }

  @override
  void dispose() {
    TFullscreen.unregisterListener(_onFullscreenChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TButton(
      size: TButtonSize.xs.copyWith(icon: 16),
      type: TButtonType.icon,
      icon: Icons.fullscreen,
      activeIcon: Icons.fullscreen_exit,
      activeColor: colors.error,
      color: colors.onSurfaceVariant,
      active: _isFullscreen,
      tooltip: _isFullscreen ? 'Exit fullscreen' : 'Enter fullscreen',
      onChanged: (_) => TFullscreen.toggleFullscreen(),
    );
  }
}

class LayoutLogoutButton extends StatelessWidget {
  const LayoutLogoutButton({super.key, required this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TButton(
      type: TButtonType.icon,
      icon: Icons.logout_rounded,
      size: TButtonSize.xs.copyWith(icon: 16),
      color: colors.onSurfaceVariant,
      tooltip: 'Log out',
      onPressed: (_) => onLogout?.call(),
    );
  }
}

/// The theme/color/fullscreen/logout cluster, shared by the desktop top bar
/// and the mobile sidebar footer (previously duplicated in both places).
class LayoutActionsRow extends StatelessWidget {
  const LayoutActionsRow({
    super.key,
    required this.profile,
    required this.showThemeToggle,
    required this.showColorToggle,
    required this.actions,
    required this.showFullscreenToggle,
    required this.showLogout,
    required this.onLogout,
    this.spacing = 10,
    this.runSpacing = 5,
  });

  final Widget? profile;
  final bool showThemeToggle;
  final bool showColorToggle;
  final List<Widget>? actions;
  final bool showFullscreenToggle;
  final bool showLogout;
  final VoidCallback? onLogout;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        if (profile != null) profile!,
        if (showThemeToggle) const LayoutThemeToggleButton(),
        if (showColorToggle) const LayoutColorToggleButton(),
        if (actions != null) ...actions!,
        if (kIsWeb && showFullscreenToggle) const LayoutFullscreenToggleButton(),
        if (showLogout) LayoutLogoutButton(onLogout: onLogout),
      ],
    );
  }
}
