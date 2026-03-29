import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TRowExpandedBuilder {
  static Widget keyValue(BuildContext ctx, List<TKeyValue> values) {
    final colors = ctx.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
      child: TKeyValueSection(
        values: values,
      ),
    );
  }
}
