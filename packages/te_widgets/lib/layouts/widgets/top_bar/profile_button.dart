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

  /// Extra widgets shown in the dropdown just before the logout item.
  final List<Widget>? actions;

  /// Show only the avatar (name and role move to the top of the dropdown).
  final bool minified;

  /// Fill the available width and push the dropdown arrow to the far end.
  final bool expand;

  /// Show the "Layout (Sidebar / Top bar)" switch in the dropdown.
  final bool showLayoutSwitch;

  const LayoutProfileButton({
    super.key,
    required this.profile,
    this.showThemeToggle = true,
    this.showColorToggle = true,
    this.showFullscreenToggle = true,
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
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final currentThemeMode = themeState.themeMode;
    final activeColorIndex = themeState.primaryColorIndex;
    final selectedColorOption = primaryColorOptions[activeColorIndex];
    final isFullscreen = TFullscreen.isFullscreen;
    final layoutStyle = themeState.layoutStyle;
    final sidebarMode = ref.watch(sidebarNotifierProvider);
    final sidebarNotifier = ref.read(sidebarNotifierProvider.notifier);
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
          icon: switch (currentThemeMode) {
            ThemeMode.light => HugeIcons.strokeRoundedSun02,
            ThemeMode.dark => HugeIcons.strokeRoundedMoon02,
            ThemeMode.system => HugeIcons.strokeRoundedAiVisionRecognition,
          },
          text: 'Theme (${currentThemeMode.name[0].toUpperCase()}${currentThemeMode.name.substring(1)})',
          children: [
            TDropdownItem(
              icon: HugeIcons.strokeRoundedAiVisionRecognition,
              text: 'System',
              color: currentThemeMode == ThemeMode.system ? colors.primary : null,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
            ),
            TDropdownItem(
              icon: HugeIcons.strokeRoundedSun02,
              text: 'Light',
              color: currentThemeMode == ThemeMode.light ? colors.primary : null,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
            ),
            TDropdownItem(
              icon: HugeIcons.strokeRoundedMoon02,
              text: 'Dark',
              color: currentThemeMode == ThemeMode.dark ? colors.primary : null,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      if (showColorToggle)
        TDropdownItem(
          icon: HugeIcons.strokeRoundedPaintBoard,
          color: selectedColorOption.color,
          text: 'Accent Color',
          children: [
            for (var i = 0; i < primaryColorOptions.length; i++)
              TDropdownItem(
                text: primaryColorOptions[i].name,
                icon: HugeIcons.strokeRoundedCircle,
                color: primaryColorOptions[i].color,
                onTap: () => themeNotifier.selectColor(i),
              ),
          ],
        ),
      if (TFullscreen.isSupported && showFullscreenToggle)
        TDropdownItem(
          icon: isFullscreen ? HugeIcons.strokeRoundedFullscreen : HugeIcons.strokeRoundedFullscreen,
          text: isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
          onTap: () => TFullscreen.toggleFullscreen(),
        ),
      // if (context.isDesktop)
      //   TDropdownItem(
      //     icon: HugeIcons.strokeRoundedLayout01,
      //     text: 'Layout (${layoutStyle.label})',
      //     children: [
      //       for (final style in TLayoutStyle.values)
      //         TDropdownItem(
      //           icon: style == TLayoutStyle.layout1 ? HugeIcons.strokeRoundedLayoutTop : HugeIcons.strokeRoundedSidebarLeft,
      //           text: style.label,
      //           color: layoutStyle == style ? colors.primary : null,
      //           onTap: () => themeNotifier.setLayoutStyle(style),
      //         ),
      //     ],
      //   ),
      if (showLayoutSwitch && context.isDesktop)
        TDropdownItem(
          icon: sidebarMode.isNone ? HugeIcons.strokeRoundedLayoutTop : HugeIcons.strokeRoundedSidebarLeft,
          text: 'Sidebar (${sidebarMode.isNone ? 'Top bar' : 'Sidebar'})',
          children: [
            TDropdownItem(
              icon: HugeIcons.strokeRoundedSidebarLeft,
              text: 'Sidebar',
              color: !sidebarMode.isNone ? colors.primary : null,
              onTap: () {
                if (sidebarMode.isNone) sidebarNotifier.setMode(TSidebarMode.full);
              },
            ),
            TDropdownItem(
              icon: HugeIcons.strokeRoundedLayoutTop,
              text: 'Top bar',
              color: sidebarMode.isNone ? colors.primary : null,
              onTap: () {
                // Top bar mode only exists in Layout 1.
                themeNotifier.setLayoutStyle(TLayoutStyle.layout1);
                sidebarNotifier.setMode(TSidebarMode.none);
              },
            ),
          ],
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
          triggerMode: TDropdownTriggerMode.hover,
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

    // Sidebar profile: the overlay spans the trigger (sidebar width minus its padding).
    if (!expand) return dropdown(null);
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
