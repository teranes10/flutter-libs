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

  final IconData? icon;

  /// Optional title for the form.
  final String? label;

  /// Optional sub title for the form.
  final String? description;

  final bool initiallyExpanded;

  /// Creates a form builder.
  const TFormBuilder({
    super.key,
    this.input,
    this.fields,
    this.gutter = 26.0,
    this.onValueChanged,
    this.icon,
    this.label,
    this.description,
    this.initiallyExpanded = false,
  }) : assert((input == null) != (fields == null), 'Provide either "input" or "fields", not both.');

  @override
  Widget build(BuildContext context) {
    final formContent = LayoutBuilder(builder: (context, constraints) {
      final breakpoint = TBreakpoint.getBreakpoint(constraints.maxWidth);
      final totalWidth = constraints.maxWidth;
      final unitWidth = (totalWidth - (gutter * 11)) / 12;

      return Wrap(
        spacing: gutter,
        runSpacing: gutter,
        children: [
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

            return isForm ? Padding(padding: const EdgeInsets.only(top: 20), child: widget) : widget;
          })
        ],
      );
    });

    if (label == null) return formContent;

    return TAccordion(
      title: label!,
      subtitle: description,
      leading: icon,
      initiallyExpanded: initiallyExpanded,
      content: formContent,
    );
  }
}
