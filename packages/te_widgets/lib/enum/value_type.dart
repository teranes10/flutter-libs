import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/formatters/decimal_input_formatter.dart';
import 'package:te_widgets/formatters/integer_input_formatter.dart';

enum BaseValueType { string, integer, floating, numeric, boolean, dateTime, timeOfDay, unknown }

extension BaseValueTypeX on BaseValueType? {
  TextInputType get keyboardType {
    return switch (this) {
      BaseValueType.integer => TextInputType.number,
      BaseValueType.floating || BaseValueType.numeric => const TextInputType.numberWithOptions(decimal: true),
      BaseValueType.dateTime || BaseValueType.timeOfDay => TextInputType.datetime,
      _ => TextInputType.text,
    };
  }

  List<TextInputFormatter> getInputFormatters(int? decimals) {
    return switch (this) {
      BaseValueType.integer => [IntegerInputFormatter()],
      BaseValueType.floating || BaseValueType.numeric => [DecimalInputFormatter(decimals: decimals)],
      _ => [],
    };
  }
}

class ValueType {
  final BaseValueType type;
  final bool isList;

  ValueType(this.type, {this.isList = false});

  factory ValueType.from(String typeStr) {
    bool list = false;
    if (typeStr.startsWith('List<') && typeStr.endsWith('>')) {
      list = true;
      typeStr = typeStr.substring(5, typeStr.length - 1);
    }

    final baseType = switch (typeStr) {
      'String' => BaseValueType.string,
      'int' => BaseValueType.integer,
      'double' => BaseValueType.floating,
      'num' => BaseValueType.numeric,
      'bool' => BaseValueType.boolean,
      'DateTime' => BaseValueType.dateTime,
      'TimeOfDay' => BaseValueType.timeOfDay,
      _ => BaseValueType.unknown,
    };

    if (baseType == BaseValueType.unknown) {
      debugPrint('Unknown type: $typeStr');
    }

    return ValueType(baseType, isList: list);
  }

  @override
  String toString() => isList ? 'List<$type>' : type.toString();
}
