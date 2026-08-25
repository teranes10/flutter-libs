import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

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
        if (actions != null) ...actions!,
        if (profile != null)
          LayoutProfileButton(
            profile: profile!,
            showThemeToggle: showThemeToggle,
            showColorToggle: showColorToggle,
            showFullscreenToggle: showFullscreenToggle,
            showLogout: showLogout,
            onLogout: onLogout,
          )
        else ...[
          if (showThemeToggle) const LayoutThemeToggleButton(),
          if (showColorToggle) const LayoutColorToggleButton(),
          if (kIsWeb && showFullscreenToggle) const LayoutFullscreenToggleButton(),
          if (showLogout && onLogout != null) LayoutLogoutButton(onLogout: onLogout),
        ],
      ],
    );
  }
}
