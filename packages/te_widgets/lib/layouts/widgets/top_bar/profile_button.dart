import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

class LayoutProfileButton extends ConsumerWidget {
  final Widget profile;
  final bool showThemeToggle;
  final bool showColorToggle;
  final bool showFullscreenToggle;
  final bool showLogout;
  final VoidCallback? onLogout;

  const LayoutProfileButton({
    super.key,
    required this.profile,
    this.showThemeToggle = true,
    this.showColorToggle = true,
    this.showFullscreenToggle = true,
    this.showLogout = true,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final currentThemeMode = themeState.themeMode;
    final activeColorIndex = themeState.primaryColorIndex;
    final selectedColorOption = primaryColorOptions[activeColorIndex];
    final isFullscreen = TFullscreen.isFullscreen;
    final colors = context.colors;

    final items = <TDropdownItem>[
      if (showThemeToggle)
        TDropdownItem(
          icon: switch (currentThemeMode) {
            ThemeMode.light => Icons.light_mode_outlined,
            ThemeMode.dark => Icons.dark_mode_outlined,
            ThemeMode.system => Icons.brightness_auto_outlined,
          },
          text: 'Theme (${currentThemeMode.name[0].toUpperCase()}${currentThemeMode.name.substring(1)})',
          children: [
            TDropdownItem(
              icon: Icons.brightness_auto_outlined,
              text: 'System',
              color: currentThemeMode == ThemeMode.system ? colors.primary : null,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
            ),
            TDropdownItem(
              icon: Icons.light_mode_outlined,
              text: 'Light',
              color: currentThemeMode == ThemeMode.light ? colors.primary : null,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
            ),
            TDropdownItem(
              icon: Icons.dark_mode_outlined,
              text: 'Dark',
              color: currentThemeMode == ThemeMode.dark ? colors.primary : null,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      if (showColorToggle)
        TDropdownItem(
          icon: Icons.palette_outlined,
          color: selectedColorOption.color,
          text: 'Accent Color',
          children: [
            for (var i = 0; i < primaryColorOptions.length; i++)
              TDropdownItem(
                text: primaryColorOptions[i].name,
                icon: Icons.circle,
                color: primaryColorOptions[i].color,
                onTap: () => themeNotifier.selectColor(i),
              ),
          ],
        ),
      if (kIsWeb && showFullscreenToggle)
        TDropdownItem(
          icon: isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
          text: isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
          onTap: () => TFullscreen.toggleFullscreen(),
        ),
      if (showLogout && onLogout != null)
        TDropdownItem(
          icon: Icons.logout_rounded,
          text: 'Log out',
          onTap: onLogout,
        ),
    ];

    if (items.isEmpty) return profile;

    return TDropdown(
      triggerMode: TDropdownTriggerMode.hover,
      items: items,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            profile,
            const SizedBox(width: 12),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
