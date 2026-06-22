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

  /// Optional list of fields rendered in the sidebar panel.
  ///
  /// When non-null, the form layout splits into a main area and a sidebar
  /// whose column span is controlled by [sidebarSize].
  /// On sm/md breakpoints (where [sidebarSize] span is 0) the sidebar fields
  /// are appended below the main fields in a single column.
  List<TFormField>? get sidebarFields => null;

  /// Controls the column span of the sidebar panel at each breakpoint.
  ///
  /// Defaults to `TGridSize(sm: 0, md: 0, lg: 4)` which means:
  /// - sm/md: no sidebar — sidebar fields fall below the main fields.
  /// - lg: sidebar occupies 4 columns, main fields occupy 8 columns.
  TGridSize get sidebarSize => const TGridSize(sm: 0, md: 0, lg: 4);

  // All field including sidebar sidebar fields
  List<TFormField> get allFields => [...fields, if (sidebarFields != null) ...sidebarFields!];

  /// Collects validation errors from all fields.
  List<String> get validationErrors => _getValidationErrors(allFields);

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
  void reset() => _resetFields(allFields);

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
  void dispose() => _disposeFields(allFields);

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
