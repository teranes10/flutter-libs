import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TMeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<double> onMeasure;

  const TMeasureSize({super.key, required this.onMeasure, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => TMeasureSizeRenderObject(onMeasure);

  @override
  void updateRenderObject(BuildContext context, TMeasureSizeRenderObject renderObject) {
    renderObject.onMeasure = onMeasure;
  }
}

class TMeasureSizeRenderObject extends RenderProxyBox {
  ValueChanged<double> onMeasure;
  double? _prevHeight;

  TMeasureSizeRenderObject(this.onMeasure);

  @override
  void performLayout() {
    super.performLayout();
    final h = child?.size.height ?? 0;
    if (_prevHeight != h) {
      _prevHeight = h;
      WidgetsBinding.instance.addPostFrameCallback((_) => onMeasure(h));
    }
  }
}
