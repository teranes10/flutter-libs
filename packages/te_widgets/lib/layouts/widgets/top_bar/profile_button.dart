import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

import 'theme_customizer.dart';

class LayoutProfileButton extends ConsumerWidget {
  final Widget profile;
  final bool showThemeToggle;
  final bool showColorToggle;
  final bool showLogout;
  final VoidCallback? onLogout;

  /// Extra widgets shown in the dropdown just before the logout item.
  final List<Widget>? actions;

  /// Show only the avatar (name and role move to the top of the dropdown).
  final bool minified;

  /// Fill the available width and push the dropdown arrow to the far end.
  final bool expand;

  /// Show the navigation placement (left sidebar / top bar) option in the theme customizer.
  final bool showLayoutSwitch;

  const LayoutProfileButton({
    super.key,
    required this.profile,
    this.showThemeToggle = true,
    this.showColorToggle = true,
    this.showLogout = true,
    this.onLogout,
    this.actions,
    this.minified = false,
    this.expand = false,
    this.showLayoutSwitch = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final colors = context.colors;

    final source = profile;
    final avatar = minified && source is TImage
        ? TImage.circle(
            url: source.url,
            bytes: source.bytes,
            size: source.size,
            placeholder: source.placeholder,
            padding: source.padding,
            cacheKey: source.cacheKey,
            forceCache: source.forceCache,
            disabled: true,
          )
        : profile;

    final items = <TDropdownItem>[
      if (minified && source is TImage && (source.title != null || source.subTitle != null))
        TDropdownItem(
          customContent: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (source.title != null)
                  Text(source.title!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: colors.onSurface)),
                if (source.subTitle != null)
                  Text(source.subTitle!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300, color: colors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Divider(height: 1, color: colors.outlineVariant),
              ],
            ),
          ),
        ),
      if (showThemeToggle)
        TDropdownItem(
          text: 'Theme',
          group: true,
          children: const [TDropdownItem(customContent: _ThemeModeSegment())],
        ),
      if (showColorToggle)
        TDropdownItem(
          icon: HugeIcons.strokeRoundedPaintBoard,
          color: themeState.primaryColor,
          text: 'Customize',
          onTap: () => showThemeCustomizer(context, showNavigation: showLayoutSwitch),
        ),
      if (actions != null)
        for (final action in actions!)
          TDropdownItem(
            customContent: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: action,
            ),
          ),
      if (showLogout && onLogout != null)
        TDropdownItem(
          icon: HugeIcons.strokeRoundedLogout01,
          text: 'Log out',
          onTap: onLogout,
        ),
    ];

    if (items.isEmpty) return avatar;

    Widget dropdown(TDropdownTheme? theme) => TDropdown(
          theme: theme,
          triggerMode: TDropdownTriggerMode.tap,
          items: items,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: minified
                ? avatar
                : Row(
                    mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      if (expand) Expanded(child: Align(alignment: Alignment.centerLeft, child: profile)) else profile,
                      const SizedBox(width: 12),
                      TIcon.raw(expand ? HugeIcons.strokeRoundedMoreHorizontal : HugeIcons.strokeRoundedArrowDown01,
                          size: 16, color: colors.onSurfaceVariant),
                    ],
                  ),
          ),
        );

    // Minified sidebar: the trigger is only an avatar, so the overlay keeps a normal width instead of matching it.
    // Sidebar profile: the overlay spans the trigger (sidebar width minus its padding).
    if (!expand || minified) {
      return dropdown(TDropdownTheme.defaultTheme(colors).copyWith(boxConstraints: const BoxConstraints(minWidth: 200)));
    }
    // Not a LayoutBuilder: the sidebar wraps this in IntrinsicWidth, which LayoutBuilder can't answer.
    return _WidthProbe(
      builder: (width) => dropdown(
        width == null ? null : TDropdownTheme.defaultTheme(colors).copyWith(boxConstraints: BoxConstraints.tightFor(width: width)),
      ),
    );
  }
}

/// Reports its own laid-out width to [builder] (null on the first frame).
class _WidthProbe extends StatefulWidget {
  const _WidthProbe({required this.builder});

  final Widget Function(double? width) builder;

  @override
  State<_WidthProbe> createState() => _WidthProbeState();
}

class _WidthProbeState extends State<_WidthProbe> {
  double? _width;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final w = (context.findRenderObject() as RenderBox?)?.size.width;
      if (w != null && w != _width) setState(() => _width = w);
    });
    return widget.builder(_width);
  }
}

/// Segmented picker shown under the "Theme" group header. Watches the provider
/// itself because the dropdown overlay doesn't rebuild with the profile button.
class _ThemeModeSegment extends ConsumerWidget {
  const _ThemeModeSegment();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeNotifierProvider).themeMode;
    final notifier = ref.read(themeNotifierProvider.notifier);
    const modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
    const icons = [HugeIcons.strokeRoundedSun02, HugeIcons.strokeRoundedMoon02, HugeIcons.strokeRoundedAiVisionRecognition];
    const labels = ['Light', 'Dark', 'System'];

    return _SegmentPad(
      child: TButtonGroup(
        type: TButtonGroupType.segmented,
        size: TButtonSize.sm,
        expanded: true,
        items: [
          for (var i = 0; i < modes.length; i++)
            TButtonGroupItem(
              icon: icons[i],
              tooltip: labels[i],
              active: mode == modes[i],
              onTap: () => notifier.setThemeMode(modes[i]),
            ),
        ],
      ),
    );
  }
}

class _SegmentPad extends StatelessWidget {
  const _SegmentPad({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(6, 0, 6, 6), child: child);
}
