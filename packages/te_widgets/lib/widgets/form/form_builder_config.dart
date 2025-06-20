part of 'form_builder.dart';

abstract class TFormBase {
  double get formWidth => 650;
  String get formTitle => 'Add New Item';
  String get formActionName => 'Add New Item';
  bool get isFormPersistent => true;
  bool get isFormCloseButton => true;

  List<TFormField> get fields;

  List<String> get validationErrors {
    List<String> errorsList = [];

    for (var field in fields) {
      if (field._field is TInputValidationMixin) {
        final input = field._field as TInputValidationMixin;
        final errors = input.validateValue(field.prop.value);
        if (errors.isNotEmpty) {
          errorsList.addAll(errors);
        }
      } else if (field._field is TItemsFormBuilder) {
        final items = field.prop.value;
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
        final item = field.prop.value;
        if (item is TFormBase) {
          final errors = item.validationErrors;
          if (errors.isNotEmpty) {
            errorsList.addAll(errors);
          }
        }
      }
    }

    return errorsList;
  }

  bool get isValid => validationErrors.isEmpty;
}

enum TBreakpoint {
  sm,
  md,
  lg;

  static TBreakpoint getBreakpoint(double width) {
    if (width >= 900) return TBreakpoint.lg;
    if (width >= 600) return TBreakpoint.md;
    return TBreakpoint.sm;
  }
}

class TFieldSize {
  final int? sm, md, lg;

  const TFieldSize({this.sm, this.md, this.lg});

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
