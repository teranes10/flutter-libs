import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TScrollbar extends StatelessWidget {
  final ScrollController controller;
  final bool isHorizontal;
  final bool thumbVisibility;
  final Widget child;

  const TScrollbar({
    super.key,
    required this.controller,
    this.isHorizontal = false,
    this.thumbVisibility = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return THoverable(
      builder: (context, isHovered) {
        return RawScrollbar(
          controller: controller,
          scrollbarOrientation: isHorizontal ? ScrollbarOrientation.bottom : ScrollbarOrientation.right,
          thumbVisibility: thumbVisibility,
          trackVisibility: true,
          interactive: true,
          thickness: 8.0,
          radius: const Radius.circular(8.0),
          thumbColor: isHovered ? colors.surfaceContainerLow : colors.surfaceContainerHigh,
          trackColor: Colors.transparent,
          trackBorderColor: Colors.transparent,
          crossAxisMargin: 0.0,
          mainAxisMargin: 0.0,
          minThumbLength: 36.0,
          child: child,
        );
      },
    );
  }
}
