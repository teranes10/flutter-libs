import 'package:flutter/widgets.dart';
import 'package:te_widgets/te_widgets.dart';

class WidthHelper {
  static double? resolveWidth(Object action) {
    return switch (action) {
      SizedBox s => s.width,
      ConstrainedBox cb => cb.constraints.resolvedWidth,
      Container c => c.constraints?.resolvedWidth,
      BoxConstraints c => c.resolvedWidth,
      TButton b => b.estimateWidth(),
      _ => null,
    };
  }
}
