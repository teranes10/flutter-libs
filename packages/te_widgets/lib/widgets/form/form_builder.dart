import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

part 'field_prop.dart';
part 'form_field.dart';
part 'form_builder_config.dart';

/// A responsive form builder with grid layout.
///
/// `TFormBuilder` provides automatic form layout with:
/// - 12-column responsive grid system
/// - Automatic field sizing based on breakpoints
/// - Integration with TFormBase
/// - Nested form support
///
/// ## Basic Usage
///
/// ```dart
/// class UserForm extends TFormBase {
///   final name = TFieldProp<String>('');
///   final email = TFieldProp<String>('');
///
///   @override
///   List<TFormField> get fields => [
///     TFormField.text(name, 'Name').size(6),
///     TFormField.text(email, 'Email').size(6),
///   ];
/// }
///
/// TFormBuilder(input: UserForm())
/// ```
///
/// See also:
/// - [TFormField] for field creation
/// - [TFormBase] for form models
class TFormBuilder extends StatelessWidget {
  /// The form model to build.
  final TFormBase? input;

  /// Manual list of fields (alternative to input).
  final List<TFormField>? fields;

  /// Spacing between fields.
  final double gutter;

  /// Callback fired when any field value changes.
  final VoidCallback? onValueChanged;

  /// Optional label for the form.
  final String? label;

  /// Creates a form builder.
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
    final colorScheme = context.colors;

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
                child: Text(label!, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: colorScheme.onSurface)),
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
