part of 'form_builder.dart';

abstract class TFormBase {
  List<TFormField> get fields;

  List<String> get validationErrors {
    List<String> errorsList = [];

    for (var field in fields) {
      if (field._field is TInputValidationMixin) {
        var input = field._field as TInputValidationMixin;
        var errors = input.validateValue(field.prop.value);
        if (errors.isNotEmpty) {
          errorsList.addAll(errors);
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
  const TFieldSize.md(int columns)
      : sm = null,
        md = columns,
        lg = null;
  const TFieldSize.lg(int columns)
      : sm = null,
        md = null,
        lg = columns;

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
