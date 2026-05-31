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
      padding: const EdgeInsets.all(20),
      child: Wrap(
        children: [
          Column(
            children: [
              Container(
                width: 200,
                height: 50,
                color: context.colors.surfaceDim,
                child: Center(child: Text('surfaceDim')),
              ),
              Container(
                width: 200,
                height: 50,
                color: context.colors.surfaceContainerLowest,
                child: Center(child: Text('surfaceContainerLowest')),
              ),
              Container(
                width: 200,
                height: 50,
                color: context.colors.surfaceContainerLow,
                child: Center(child: Text('surfaceContainerLow')),
              ),
              Container(
                width: 200,
                height: 50,
                color: context.colors.surfaceContainer,
                child: Center(child: Text('surfaceContainer')),
              ),
              Container(
                width: 200,
                height: 50,
                color: context.colors.surfaceContainerHigh,
                child: Center(child: Text('surfaceContainerHigh')),
              ),
              Container(
                width: 200,
                height: 50,
                color: context.colors.surfaceContainerHighest,
                child: Center(child: Text('surfaceContainerHighest')),
              ),
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
}
