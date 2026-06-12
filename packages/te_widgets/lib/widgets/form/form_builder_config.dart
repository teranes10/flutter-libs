part of 'form_builder.dart';

/// Base class for creating structured forms.
abstract class TFormBase {
  /// The width of the form dialog/container.
  double get formWidth => 650;

  /// The title displayed on the form.
  String get formTitle => 'Add New Item';

  /// The text for the primary action button.
  String get formActionName => 'Add New Item';

  /// Whether the form state persists.
  bool get isFormPersistent => true;

  /// Whether to show a close button.
  bool get isFormCloseButton => true;

  /// Returns the list of fields in the form.
  List<TFormField> get fields;

  /// Collects validation errors from all fields.
  List<String> get validationErrors => _getValidationErrors(fields);

  List<String> _getValidationErrors(List<TFormField> fieldsToValidate) {
    List<String> errorsList = [];

    for (var field in fieldsToValidate) {
      if (field._field is TInputValidationMixin) {
        final input = field._field as TInputValidationMixin;
        final errors = input.validateValue(field.prop?.value);
        if (errors.isNotEmpty) {
          errorsList.addAll(errors);
        }
      } else if (field._field is TItemsFormBuilder) {
        final items = field.prop?.value ?? [];
        if (items is List && items.isNotEmpty) {
          for (var i = 0; i < items.length; i++) {
            final item = items[i];
            if (item is TFormBase) {
              final errors = item.validationErrors.map((e) => 'Item ${i + 1}: $e');
              if (errors.isNotEmpty) {
                errorsList.addAll(errors);
              }
            }
          }
        }
      } else if (field._field is TFormBuilder) {
        final fb = field._field as TFormBuilder;
        if (fb.input != null) {
          errorsList.addAll(fb.input!.validationErrors);
        } else if (fb.fields != null) {
          errorsList.addAll(_getValidationErrors(fb.fields!));
        }
      }
    }

    return errorsList;
  }

  /// Returns true if there are no validation errors.
  bool get isValid => validationErrors.isEmpty;

  /// Resets all fields to their initial values.
  void reset() => _resetFields(fields);

  void _resetFields(List<TFormField> fieldsToReset) {
    for (var field in fieldsToReset) {
      field.prop?.reset();
      if (field._field is TFormBuilder) {
        final fb = field._field as TFormBuilder;
        if (fb.fields != null) {
          _resetFields(fb.fields!);
        }
      }
    }
  }

  /// Hook called when any value changes.
  void onValueChanged() {}

  /// Disposes all field properties.
  void dispose() => _disposeFields(fields);

  void _disposeFields(List<TFormField> fieldsToDispose) {
    for (var field in fieldsToDispose) {
      field.prop?.dispose();
      if (field._field is TFormBuilder) {
        final fb = field._field as TFormBuilder;
        if (fb.fields != null) {
          _disposeFields(fb.fields!);
        }
      }
    }
  }
}

/// Screen width breakpoints for responsive layouts.
enum TBreakpoint {
  sm,
  md,
  lg;

  /// Determines the breakpoint based on width.
  static TBreakpoint getBreakpoint(double width) {
    if (width >= 900) return TBreakpoint.lg;
    if (width >= 600) return TBreakpoint.md;
    return TBreakpoint.sm;
  }
}

/// Defines the column span of a field at different breakpoints.
class TFieldSize {
  /// Span at small screens.
  final int? sm,

      /// Span at medium screens.
      md,

      /// Span at large screens.
      lg;

  /// Creates a responsive field size.
  const TFieldSize({this.sm, this.md, this.lg});

  /// Gets the span for a specific breakpoint, falling back to smaller sizes or 12 (full width).
  int getSpan(TBreakpoint bp) {
    switch (bp) {
      case TBreakpoint.lg:
        return lg ?? md ?? sm ?? 12;
      case TBreakpoint.md:
        return md ?? sm ?? 12;
      case TBreakpoint.sm:
        return sm ?? 12;
    }
  }
}
