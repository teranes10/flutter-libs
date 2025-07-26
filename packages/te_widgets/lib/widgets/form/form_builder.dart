import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

part 'field_prop.dart';
part 'form_field.dart';
part 'form_builder_config.dart';

class TFormBuilder extends StatelessWidget {
  final TFormBase? input;
  final List<TFormField>? fields;
  final double gutter;
  final VoidCallback? onValueChanged;
  final String? label;

  const TFormBuilder({
    super.key,
    this.input,
    this.fields,
    this.gutter = 16.0,
    this.onValueChanged,
    this.label,
  }) : assert((input == null) != (fields == null), 'Provide either "input" or "fields", not both.');

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return LayoutBuilder(builder: (context, constraints) {
      final breakpoint = TBreakpoint.getBreakpoint(constraints.maxWidth);
      final totalWidth = constraints.maxWidth;
      final unitWidth = (totalWidth - (gutter * 11)) / 12;

      return Wrap(
        spacing: gutter,
        runSpacing: gutter,
        children: [
          if (label != null)
            SizedBox(
              width: (unitWidth * 12) + (11 * gutter),
              child: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(label!, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: theme.onSurface)),
              ),
            ),
          ...(input?.fields ?? fields ?? []).map((field) {
            final span = field._size.getSpan(breakpoint);
            final width = (unitWidth * span) + ((span - 1) * gutter);
            final isForm = field._field is TFormBuilder || field._field is TItemsFormBuilder;

            field._attach(() {
              onValueChanged?.call();
              input?.onValueChanged();
            });

            final widget = SizedBox(
              width: width,
              child: field._field,
            );

            return isForm ? Padding(padding: EdgeInsets.only(top: 15), child: widget) : widget;
          })
        ],
      );
    });
  }
}
