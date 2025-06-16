import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/widgets/text-field/text_field.dart';

abstract class TFormBase {
  List<TFormField> get fields;
}

class TFormBuilder extends StatelessWidget {
  final TFormBase? input;
  final List<TFormField>? fields;
  final double gutter;
  final VoidCallback? onValueChanged;

  const TFormBuilder({
    super.key,
    this.input,
    this.fields,
    this.gutter = 16.0,
    this.onValueChanged,
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
            child: field.builder((value) {
              field.prop._value = value;
              onValueChanged?.call();
            }),
          );
        }).toList(),
      );
    });
  }
}

class TFormField<T> {
  final TFieldProp<T> prop;
  final Widget Function(ValueChanged<T>) builder;
  TFieldSize _size = const TFieldSize();

  TFormField({
    required this.prop,
    required this.builder,
  });

  TFormField<T> size(int md, {int? sm = 12, int? lg = 12}) {
    _size = TFieldSize(sm: sm, md: md, lg: lg);
    return this;
  }

  static TFormField<String> text(
    TFieldProp<String> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    TInputSize? size,
    int? rows,
    List<String? Function(String?)>? rules,
    TFieldSize? fieldSize,
  }) {
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
        onValueChanged: onValueChanged,
      ),
    );
  }
}

class TFieldProp<T> {
  T _value;

  TFieldProp(T value) : _value = value;

  T get value => _value;
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

enum TBreakpoint {
  sm,
  md,
  lg;

  static TBreakpoint getBreakpoint(double width) {
    if (width >= 992) return TBreakpoint.lg;
    if (width >= 768) return TBreakpoint.md;
    return TBreakpoint.sm;
  }
}
