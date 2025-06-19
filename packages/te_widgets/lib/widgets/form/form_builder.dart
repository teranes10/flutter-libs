import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

part 'field_prop.dart';
part 'form_field.dart';
part 'form_builder_config.dart';

class TFormBuilder extends StatelessWidget {
  final TFormBase? input;
  final List<TFormField>? fields;
  final double gutter;

  const TFormBuilder({
    super.key,
    this.input,
    this.fields,
    this.gutter = 16.0,
  }) : assert((input == null) != (fields == null), 'Provide either "input" or "fields", not both.');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final breakpoint = TBreakpoint.getBreakpoint(constraints.maxWidth);
      final totalWidth = constraints.maxWidth;
      final unitWidth = (totalWidth - (gutter * 11)) / 12;

      return Wrap(
        spacing: gutter,
        runSpacing: gutter,
        children: (input?.fields ?? fields ?? []).map((field) {
          final span = field._size.getSpan(breakpoint);
          final width = (unitWidth * span) + ((span - 1) * gutter);

          return SizedBox(
            width: width,
            child: field._field,
          );
        }).toList(),
      );
    });
  }
}
