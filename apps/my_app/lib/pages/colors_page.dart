import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Documentation page showcasing all Color variants and features.
class ColorsPage extends StatefulWidget {
  const ColorsPage({super.key});

  @override
  State<ColorsPage> createState() => _ColorsPageState();
}

class _ColorsPageState extends State<ColorsPage> {
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
              buildColor(context.colors.surfaceContainer, label: 'surfaceContainer'),
              buildColor(context.colors.surfaceContainerHigh, label: 'surfaceContainerHigh'),
              buildColor(context.colors.surfaceContainerHighest, label: 'surfaceContainerHighest'),
            ],
          ),

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

  Widget buildColor(Color color, {required String label, double width = 200, double height = 50}) {
    return Container(
      width: width,
      height: height,
      color: color,
      child: Center(child: Text(label)),
    );
  }
}
