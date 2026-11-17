import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Documentation page showcasing all Color variants and features.
class ColorsPage extends StatefulWidget {
  const ColorsPage({super.key});

  @override
  State<ColorsPage> createState() => _ColorsPageState();
}

class _ColorsPageState extends State<ColorsPage> {
  Color _picked = const Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        children: [
          Column(
            children: [
              buildColor(context.colors.shadow, label: 'shadow'),
              buildColor(context.colors.scrim, label: 'scrim'),
              buildColor(context.colors.surfaceDim, label: 'surfaceDim'),
              buildColor(context.colors.surfaceContainerLowest, label: 'surfaceContainerLowest'),
              buildColor(context.colors.surfaceContainerLow, label: 'surfaceContainerLow'),
              buildColor(context.colors.surface, label: 'surface'),
              buildColor(context.colors.surfaceContainer, label: 'surfaceContainer'),
              buildColor(context.colors.surfaceContainerHigh, label: 'surfaceContainerHigh'),
              buildColor(context.colors.surfaceContainerHighest, label: 'surfaceContainerHighest'),
              buildColor(context.colors.surfaceTint, label: 'surfaceTint'),
              buildColor(context.colors.outline, label: 'outline'),
              buildColor(context.colors.outlineVariant, label: 'outlineVariant'),
            ],
          ),

          buildPicker(context),
          buildColorShades(context.theme.grey, label: 'grey'),
          buildColorShades(context.theme.primary, label: 'primary'),
          buildColorShades(context.theme.secondary, label: 'secondary'),
          buildColorShades(context.theme.success, label: 'success'),
          buildColorShades(context.theme.warning, label: 'warning'),
          buildColorShades(context.theme.info, label: 'info'),
          buildColorShades(context.theme.danger, label: 'danger'),
        ],
      ),
    );
  }

  /// Pick any colour; its generated palette (via [toMaterial]) is shown below the picker.
  Widget buildPicker(BuildContext context) {
    final hex = '#${_picked.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    return Column(
      children: [
        TColorPickerPopover(
          title: 'Pick a color',
          color: _picked,
          onChanged: (c) => setState(() => _picked = c),
          child: Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              color: _picked,
              border: Border.all(color: context.colors.outlineVariant),
            ),
            alignment: Alignment.center,
            child: Text(
              'Pick color  $hex',
              style: TextStyle(color: _picked.computeLuminance() > 0.5 ? Colors.black : Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        buildColorShades(_picked.toMaterial(), label: 'picked'),
      ],
    );
  }

  Widget buildColorShades(MaterialColor color, {String? label, double width = 200, double height = 50}) {
    final shades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950];

    return Column(
      children: shades
          .map(
            (shade) => color[shade] != null
                ? Container(
                    width: width,
                    height: height,
                    color: color[shade],
                    child: Center(child: Text(label != null ? "$label - $shade" : shade.toString())),
                  )
                : SizedBox.shrink(),
          )
          .toList(),
    );
  }

  Widget buildColor(Color color, {required String label, double width = 250, double height = 50}) {
    return Container(
      width: width,
      height: height,
      color: color,
      child: Center(
        child: Row(
          children: [
            Container(width: 20, height: height - 20, color: context.getTonalBackground(color, color).tonal),
            Text('$label (${color.computeLuminance().toStringAsFixed(3)})'),
          ],
        ),
      ),
    );
  }
}
