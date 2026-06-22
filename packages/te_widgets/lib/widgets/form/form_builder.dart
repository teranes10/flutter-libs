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

  /// Horizontal spacing between fields.
  final double gapX;

  /// Vertical spacing between fields.
  final double gapY;

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
    this.gapX = 16.0,
    this.gapY = 26.0,
    this.onValueChanged,
    this.icon,
    this.label,
    this.description,
    this.initiallyExpanded = false,
  }) : assert((input == null) != (fields == null), 'Provide either "input" or "fields", not both.');

  /// Builds the column widgets for [fieldList], attaching value-change listeners.
  List<Widget> _buildFieldCols(List<TFormField> fieldList) {
    return fieldList.map((field) {
      final isForm = field._field is TFormBuilder || field._field is TItemsFormBuilder;

      field._attach(() {
        onValueChanged?.call();
        input?.onValueChanged();
      });

      final widget = isForm ? Padding(padding: const EdgeInsets.only(top: 20), child: field._field) : field._field;

      return TGridCol(
        sm: field._size.sm,
        md: field._size.md,
        lg: field._size.lg,
        child: widget,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedFields = input?.fields ?? fields ?? [];
    final resolvedSidebarFields = input?.sidebarFields;
    final resolvedSidebarSize = input?.sidebarSize ?? const TGridSize(sm: 0, md: 0, lg: 4);

    Widget formContent;

    if (resolvedSidebarFields != null) {
      // Sidebar span at each breakpoint (0 means no sidebar at that size).
      final sidebarSm = resolvedSidebarSize.sm ?? 0;
      final sidebarMd = resolvedSidebarSize.md ?? 0;
      final sidebarLg = resolvedSidebarSize.lg ?? 4;

      // Main area occupies the remainder of the 12-column grid.
      final mainSm = sidebarSm == 0 ? 12 : 12 - sidebarSm;
      final mainMd = sidebarMd == 0 ? 12 : 12 - sidebarMd;
      final mainLg = sidebarLg == 0 ? 12 : 12 - sidebarLg;

      final mainCol = TGridCol(
        sm: mainSm,
        md: mainMd,
        lg: mainLg,
        child: TGridRow(
          gapX: gapX,
          gapY: gapY,
          children: _buildFieldCols(resolvedFields),
        ),
      );

      // On breakpoints where the sidebar span is 0, append sidebar fields
      // below main fields in a full-width single column.
      final sidebarCol = TGridCol(
        sm: sidebarSm == 0 ? 12 : sidebarSm,
        md: sidebarMd == 0 ? 12 : sidebarMd,
        lg: sidebarLg == 0 ? 12 : sidebarLg,
        child: TGridRow(
          gapX: gapX,
          gapY: gapY,
          children: _buildFieldCols(resolvedSidebarFields),
        ),
      );

      // On sm/md where sidebar span is 0 the sidebar col becomes 12-wide and
      // wraps below; on lg it sits alongside the main col (8:4).
      formContent = TGridRow(
        gapX: gapX,
        gapY: gapY,
        children: [mainCol, sidebarCol],
      );
    } else {
      formContent = TGridRow(
        gapX: gapX,
        gapY: gapY,
        children: _buildFieldCols(resolvedFields),
      );
    }

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
