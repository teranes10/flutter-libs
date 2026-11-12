import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_widgets/te_widgets.dart';

/// Opens the live theme customizer as a non-blocking side panel.
Future<void> showThemeCustomizer(BuildContext context) {
  return TSheetService.showSideSheet<void>(
    context,
    (_) => const _ThemeCustomizer(),
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
  const _ThemeCustomizer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final overrides = brightness == Brightness.dark ? state.darkOverrides : state.lightOverrides;
    final colors = context.colors;

    Widget swatch(Color c, {required bool selected, required VoidCallback onTap, String? tooltip}) => Tooltip(
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                onChanged: notifier.setCustomColor,
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
          const SizedBox(height: 8),
          TSwitch(
            label: 'Tint other colors with accent',
            value: state.tintByAccent,
            onValueChanged: (v) => notifier.setTintByAccent(v ?? false),
          ),
          const SizedBox(height: 12),
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
          Expanded(
            child: ListView.builder(
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
          ),
        ],
      ),
    );
  }
}
