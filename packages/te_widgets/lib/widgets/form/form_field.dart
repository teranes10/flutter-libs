part of 'form_builder.dart';

class TFormField<T> {
  final TFieldProp<T> prop;
  final Widget Function(ValueChanged<T>) builder;

  final Widget _field;
  TFieldSize _size = const TFieldSize();

  TFormField({
    required this.prop,
    required this.builder,
  }) : _field = builder((value) {
          prop._value = value;
        });

  TFormField<T> size(int md, {int? sm = 12, int? lg = 12}) {
    _size = TFieldSize(sm: sm, md: md, lg: lg);
    return this;
  }

  static TFormField<String> text(TFieldProp<String> prop, String? label,
      {String? tag,
      String? placeholder,
      String? helperText,
      bool isRequired = false,
      bool disabled = false,
      TInputSize? size,
      int? rows,
      List<String? Function(String?)>? rules,
      TFieldSize? fieldSize}) {
    return TFormField<String>(
      prop: prop,
      builder: (onValueChanged) => TTextField(
          label: label,
          tag: tag,
          placeholder: placeholder,
          helperText: helperText,
          isRequired: isRequired,
          disabled: disabled,
          size: size,
          rows: rows,
          rules: rules,
          value: prop.value,
          onValueChanged: onValueChanged),
    );
  }
}
