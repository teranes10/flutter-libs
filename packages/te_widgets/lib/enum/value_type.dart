import 'package:flutter/material.dart';

enum BaseValueType { string, integer, floating, numeric, boolean, dateTime, timeOfDay, unknown }

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
