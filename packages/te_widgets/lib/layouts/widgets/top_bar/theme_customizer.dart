import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

/// Opens the live theme customizer as a non-blocking side panel.
Future<void> showThemeCustomizer(BuildContext context, {bool showNavigation = true}) {
  return TSheetService.showSideSheet<void>(
    context,
    (_) => _ThemeCustomizer(showNavigation: showNavigation),
    title: 'Customize theme',
    width: 340,
    barrierColor: Colors.transparent,
  );
}

String _label(String key) {
  final spaced = key.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ');
  return spaced[0].toUpperCase() + spaced.substring(1);
}

class _ThemeCustomizer extends ConsumerWidget {
  const _ThemeCustomizer({this.showNavigation = true});

  /// Show the left sidebar / top bar placement switch (desktop only).
  final bool showNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final overrides = brightness == Brightness.dark ? state.darkOverrides : state.lightOverrides;
    final colors = context.colors;

    Widget swatch(Color c, {required bool selected, required VoidCallback onTap, String? tooltip}) => TTooltip(
          message: tooltip ?? '',
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(color: selected ? colors.onSurface : colors.outlineVariant, width: selected ? 2.5 : 1),
              ),
              child: selected ? Icon(Icons.check, size: 16, color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white) : null,
            ),
          ),
        );

    // The whole panel scrolls: the glass options make the top section taller than many screens.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showNavigation && context.isDesktop) ...[
            Text('Navigation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant)),
            const SizedBox(height: 8),
            TTabs<bool>(
              style: TTabStyle.segmented,
              fill: true,
              selectedValue: ref.watch(sidebarNotifierProvider).isNone,
              onTabChanged: (top) {
                final sidebar = ref.read(sidebarNotifierProvider.notifier);
                if (top) {
                  sidebar.setMode(TSidebarMode.none);
                } else if (ref.read(sidebarNotifierProvider).isNone) {
                  sidebar.setMode(TSidebarMode.full);
                }
              },
              tabs: const [
                TTab(value: false, text: 'Left bar', icon: HugeIcons.strokeRoundedSidebarLeft),
                TTab(value: true, text: 'Top bar', icon: HugeIcons.strokeRoundedLayoutTop),
              ],
            ),
            if (!ref.watch(sidebarNotifierProvider).isNone) ...[
              const SizedBox(height: 12),
              Text('Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant)),
              const SizedBox(height: 8),
              TTabs<TProfilePosition>(
                style: TTabStyle.segmented,
                fill: true,
                selectedValue: state.profilePosition,
                onTabChanged: notifier.setProfilePosition,
                tabs: const [
                  TTab(value: TProfilePosition.sidebar, text: 'Left bar', icon: HugeIcons.strokeRoundedSidebarLeft),
                  TTab(value: TProfilePosition.topBar, text: 'Top bar', icon: HugeIcons.strokeRoundedLayoutTop),
                ],
              ),
            ],
            const SizedBox(height: 16),
          ],
          Text('Theme', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant)),
          const SizedBox(height: 8),
          TTabs<Brightness>(
            style: TTabStyle.segmented,
            fill: true,
            selectedValue: brightness,
            onTabChanged: (v) => notifier.setThemeMode(v == Brightness.dark ? ThemeMode.dark : ThemeMode.light),
            tabs: const [
              TTab(value: Brightness.light, text: 'Light', icon: HugeIcons.strokeRoundedSun02),
              TTab(value: Brightness.dark, text: 'Dark', icon: HugeIcons.strokeRoundedMoon02),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('Glass Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant)),
              ),
              TSwitch(value: ref.watch(themeNotifierProvider).glass, onValueChanged: (v) => notifier.setGlass(v!)),
            ],
          ),
          if (state.glass) ..._glassOptions(context, notifier, state, colors),
          const SizedBox(height: 16),
          Text('Accent', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < primaryColorOptions.length; i++)
                swatch(
                  primaryColorOptions[i].color,
                  selected: state.customColor == null && state.primaryColorIndex == i,
                  tooltip: primaryColorOptions[i].name,
                  onTap: () => notifier.selectColor(i),
                ),
              TColorPickerPopover(
                title: 'Accent color',
                alignment: TPopupAlignment.leftCenter,
                color: state.primaryColor,
                onChanged: (c) {
                  notifier.setCustomColor(c);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.customColor,
                    border: Border.all(
                        color: state.customColor != null ? colors.onSurface : colors.outlineVariant,
                        width: state.customColor != null ? 2.5 : 1),
                  ),
                  child: Icon(Icons.add,
                      size: 16,
                      color: state.customColor == null
                          ? colors.onSurfaceVariant
                          : (state.customColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Colors (${brightness == Brightness.dark ? 'Dark' : 'Light'} mode)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant),
                ),
              ),
              TButton(
                type: TButtonType.softText,
                size: TSize.xs,
                text: 'Reset all',
                icon: Icons.restart_alt,
                onTap: () => notifier.resetScheme(brightness),
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kSchemeColorKeys.length + 1,
            itemBuilder: (context, i) {
              final key = i == 0 ? kScaffoldBackgroundKey : kSchemeColorKeys[i - 1];
              final color = i == 0 ? Theme.of(context).scaffoldBackgroundColor : schemeColor(scheme, key);
              final overridden = overrides.containsKey(key);
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TColorPickerPopover(
                  title: _label(key),
                  color: color,
                  enableAlpha: key == 'scrim' || key == 'surfaceTint' || key == 'shadow',
                  alignment: TPopupAlignment.leftCenter,
                  onChanged: (c) => notifier.setSchemeColor(brightness, key, c),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_label(key),
                                  style: TextStyle(
                                      fontSize: 13, color: colors.onSurface, fontWeight: overridden ? FontWeight.w600 : FontWeight.w400)),
                              Text('#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                                  style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        if (overridden)
                          TButton(
                            type: TButtonType.softText,
                            size: TSize.xs,
                            tooltip: 'Reset',
                            icon: Icons.restart_alt,
                            onTap: () => notifier.resetSchemeColor(brightness, key),
                          ),
                      ],
                    ),
                  ),
                ),
              ]);
            },
          ),
        ],
      ),
    );
  }
}

List<Widget> _glassOptions(BuildContext context, ThemeNotifier notifier, TThemeState state, ColorScheme colors) {
  final label = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant);
  final mix = state.glassColors ?? TGlassTuning.defaultBlobColors;
  // One slider, bound to whichever background is active (the image one is tuned much lower by default).
  final blobAlpha = state.glassStatic ? state.glassImageBlobAlpha : state.glassBlobAlpha;

  Widget switchRow(String text, bool value, ValueChanged<bool> onChanged) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Expanded(child: Text(text, style: label)),
          TSwitch(value: value, onValueChanged: (v) => onChanged(v!)),
        ]),
      );

  Future<void> pick() async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;
    await notifier.setGlassImageBytes(await files.first.readAsBytes());
  }

  final t = state.glassTweaks;
  void tweak(TGlassTweaks v) => notifier.setGlassTweaks(v);

  Widget slider(String text, String value, double v, double min, double max, ValueChanged<double> onChanged) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(text, style: label)),
            Text(value, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
          ]),
          TSlider(value: v.clamp(min, max), min: min, max: max, onValueChanged: (x) => onChanged(x!)),
        ]),
      );

  String pct(double v) => '${(v * 100).round()}%';

  Widget group(String title, IconData icon, List<Widget> children, {bool open = false}) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: TAccordion(
          title: title,
          icon: icon,
          initiallyExpanded: open,
          content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      );

  final hasImage = state.glassStatic;
  return [
    const SizedBox(height: 8),
    group(
        'Glass surface',
        Icons.blur_on,
        [
          TTabs<TGlassLook>(
            style: TTabStyle.segmented,
            fill: true,
            selectedValue: state.glassLook,
            onTabChanged: notifier.setGlassLook,
            tabs: [for (final l in TGlassLook.values) TTab(value: l, text: l.label)],
          ),
          const SizedBox(height: 12),
          slider('Blur', t.blur.round().toString(), t.blur, 0, 40, (v) => tweak(t.copyWith(blur: v))),
          slider('Saturation', pct(t.saturation), t.saturation, 0, 2.5, (v) => tweak(t.copyWith(saturation: v))),
          slider('Brightness', pct(t.brightness), t.brightness, 0.5, 1.5, (v) => tweak(t.copyWith(brightness: v))),
          slider('Fill opacity', pct(t.fillAlpha / 255), t.fillAlpha.toDouble(), 0, 255, (v) => tweak(t.copyWith(fillAlpha: v.round()))),
          slider('Edge shine', pct(t.shine / 255), t.shine.toDouble(), 0, 255, (v) => tweak(t.copyWith(shine: v.round()))),
          Align(
            alignment: Alignment.centerRight,
            child: TButton(
                type: TButtonType.softText,
                size: TSize.xs,
                text: 'Reset',
                icon: Icons.restart_alt,
                onTap: () {
                  final d = TGlassTweaks.defaults(state.glassLook);
                  tweak(
                      t.copyWith(blur: d.blur, saturation: d.saturation, brightness: d.brightness, fillAlpha: d.fillAlpha, shine: d.shine));
                }),
          ),
        ],
        open: true),
    group('Background', Icons.wallpaper, [
      switchRow('Image background', state.glassStatic, notifier.setGlassStatic),
      if (hasImage) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            TButton(type: TButtonType.softText, size: TSize.xs, text: 'Choose image', icon: Icons.image_outlined, onTap: pick),
            const SizedBox(width: 8),
            if (state.glassImageBytes != null)
              TButton(
                  type: TButtonType.softText, size: TSize.xs, text: 'Remove', icon: Icons.delete_outline, onTap: notifier.clearGlassImage),
          ]),
        ),
        slider('Image blur', state.glassImageBlur.round().toString(), state.glassImageBlur, 0, 30, notifier.setGlassImageBlur),
        slider('Image dim', '${state.glassImageDim}%', state.glassImageDim.toDouble(), 0, 80, (v) => notifier.setGlassImageDim(v.round())),
        slider('Image saturation', pct(t.imageSaturation), t.imageSaturation, 0, 2, (v) => tweak(t.copyWith(imageSaturation: v))),
        slider('Image brightness', pct(t.imageBrightness), t.imageBrightness, 0.5, 1.5, (v) => tweak(t.copyWith(imageBrightness: v))),
      ],
      // Over a photo the blobs only exist while animating.
      if (!state.glassStatic || state.glassAnimated)
        slider('Blob opacity', '${(blobAlpha / 255 * 100).round()}%', blobAlpha / 255 * 100, 0, 100, (v) {
          final alpha = (v / 100 * 255).round();
          state.glassStatic ? notifier.setGlassImageBlobAlpha(alpha) : notifier.setGlassBlobAlpha(alpha);
        }),
    ]),
    group('Motion', Icons.animation, [
      switchRow('Animate (mouse + auto drift)', state.glassAnimated, notifier.setGlassAnimated),
      if (state.glassAnimated) ...[
        slider('Idle before drift', '${state.glassIdleSeconds}s', state.glassIdleSeconds.toDouble(), 3, 60,
            (v) => notifier.setGlassIdleSeconds(v.round())),
        slider('Drift speed', pct(t.driftSpeed), t.driftSpeed, 0.1, 3, (v) => tweak(t.copyWith(driftSpeed: v))),
        slider('Pointer pull', pct(t.pointerPull), t.pointerPull, 0, 2.5, (v) => tweak(t.copyWith(pointerPull: v))),
      ],
    ]),
    group('Background colors', Icons.palette_outlined, [
      Text('Presets', style: label),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final preset in _glassPresets)
          Tooltip(
            message: preset.name,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                notifier.setGlassColors(preset.colors);
                notifier.setCustomColor(preset.accent);
              },
              child: Container(
                width: 56,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(colors: preset.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  border: Border.all(
                    color: _sameColors(state.glassColors, preset.colors) ? colors.onSurface : colors.outlineVariant,
                    width: _sameColors(state.glassColors, preset.colors) ? 2 : 1,
                  ),
                ),
              ),
            ),
          ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: Text('Blob colors', style: label)),
        if (state.glassColors != null)
          TButton(type: TButtonType.softText, size: TSize.xs, text: 'Reset', icon: Icons.restart_alt, onTap: notifier.resetGlassColors),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (var i = 0; i < mix.length; i++)
          TColorPickerPopover(
            title: 'Blob ${i + 1}',
            alignment: TPopupAlignment.leftCenter,
            color: mix[i],
            onChanged: (c) => notifier.setGlassColors([...mix]..[i] = c),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(shape: BoxShape.circle, color: mix[i], border: Border.all(color: colors.outlineVariant)),
            ),
          ),
        if (mix.length < 8)
          TButton(
              type: TButtonType.softText, size: TSize.xs, icon: Icons.add, onTap: () => notifier.setGlassColors([...mix, colors.primary])),
        if (mix.length > 2)
          TButton(
              type: TButtonType.softText, size: TSize.xs, icon: Icons.remove, onTap: () => notifier.setGlassColors([...mix]..removeLast())),
      ]),
    ]),
    const SizedBox(height: 8),
  ];
}

class _GlassPreset {
  final String name;
  final List<Color> colors;

  /// Accent (primary) applied with the preset: a readable colour from the mix.
  final Color accent;
  const _GlassPreset(this.name, this.colors, this.accent);
}

const _glassPresets = <_GlassPreset>[
  _GlassPreset('Slate Blue', TGlassTuning.defaultBlobColors, Color(0xFF3B82C4)),
  _GlassPreset('Calm Teal', [Color(0xFF2A7F86), Color(0xFF4FA3A5), Color(0xFF7BBFB5), Color(0xFF3C6E8F)], Color(0xFF2A9D8F)),
  _GlassPreset('Sage', [Color(0xFF2F7D65), Color(0xFF4FA08A), Color(0xFF86BFA9), Color(0xFF3A6B7A)], Color(0xFF3FA37F)),
  _GlassPreset('Indigo', [Color(0xFF4B5FA8), Color(0xFF6F7FC4), Color(0xFF8E9AD6), Color(0xFF3F4C85)], Color(0xFF5B6FD1)),
  _GlassPreset('Violet Mist', [Color(0xFF6B5BA8), Color(0xFF8C7BC4), Color(0xFFA99BD8), Color(0xFF4F5C9A)], Color(0xFF7C6BC4)),
  _GlassPreset('Warm Sand', [Color(0xFFB08968), Color(0xFFC9A27E), Color(0xFF8FA3A0), Color(0xFF6F8F8C)], Color(0xFFC08A5A)),
  _GlassPreset('Rose Dust', [Color(0xFFB05A78), Color(0xFFCC7F96), Color(0xFF8E6BA8), Color(0xFF5F7FA8)], Color(0xFFC0617F)),
  _GlassPreset('Graphite', [Color(0xFF3E4C5E), Color(0xFF5C6B7D), Color(0xFF7D8A99), Color(0xFF4E7A8C)], Color(0xFF5F8FA8)),
];

bool _sameColors(List<Color>? a, List<Color> b) {
  if (a == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].toARGB32() != b[i].toARGB32()) return false;
  }
  return true;
}
