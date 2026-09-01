import 'package:flutter/material.dart';

/// Supported data types for columns in [TCsvEditor].
enum TCsvColumnType {
  /// String text field.
  text,

  /// Floating point or decimal number.
  number,

  /// Integer number.
  integer,

  /// Boolean switch / checkbox (true/false).
  boolean;

  /// Human readable label.
  String get label => switch (this) {
        TCsvColumnType.text => 'Text',
        TCsvColumnType.number => 'Number',
        TCsvColumnType.integer => 'Integer',
        TCsvColumnType.boolean => 'Boolean',
      };

  /// Icon representing the type.
  IconData get icon => switch (this) {
        TCsvColumnType.text => Icons.text_fields_rounded,
        TCsvColumnType.number => Icons.pin_outlined,
        TCsvColumnType.integer => Icons.tag_rounded,
        TCsvColumnType.boolean => Icons.toggle_on_outlined,
      };
}

/// Defines a column schema for [TCsvEditor].
///
/// `TCsvColumn` describes:
/// - [key]: Unique field key used in output maps.
/// - [header]: Expected header label.
/// - [type]: The column data type ([TCsvColumnType.text], [TCsvColumnType.number], [TCsvColumnType.integer], [TCsvColumnType.boolean]).
/// - [isRequired]: Whether the value must be non-empty and valid.
/// - [defaultValue]: Fallback value when empty.
/// - [aliases]: Synonyms used to automatically match CSV headers if the uploaded CSV header names differ.
/// - [validator]: Custom validation rule.
///
/// ## Example
/// ```dart
/// TCsvColumn.text(key: 'name', header: 'Product Name', isRequired: true)
/// TCsvColumn.number(key: 'price', header: 'Price (\$)')
/// TCsvColumn.boolean(key: 'in_stock', header: 'In Stock')
/// ```
class TCsvColumn {
  /// Field key in the resulting row map.
  final String key;

  /// Expected header title string.
  final String header;

  /// Data type of the column.
  final TCsvColumnType type;

  /// Whether this column requires a non-empty value.
  final bool isRequired;

  /// Default value if cell is empty or missing.
  final dynamic defaultValue;

  /// Alternative header names to check during auto-mapping (e.g. `['qty', 'quantity']`).
  final List<String> aliases;

  /// Custom validation function returning error message or null if valid.
  final String? Function(dynamic value)? validator;

  /// Custom formatter for display.
  final String Function(dynamic value)? format;

  /// Optional placeholder for inline editor.
  final String? placeholder;

  /// Optional helper text.
  final String? helperText;

  /// Minimum width of the column in the table.
  final double minWidth;

  /// Maximum width of the column in the table.
  final double? maxWidth;

  /// Flex factor for column width.
  final int? flex;

  /// Content alignment inside cell.
  final Alignment alignment;

  const TCsvColumn({
    required this.key,
    required this.header,
    this.type = TCsvColumnType.text,
    this.isRequired = false,
    this.defaultValue,
    this.aliases = const [],
    this.validator,
    this.format,
    this.placeholder,
    this.helperText,
    this.minWidth = 140,
    this.maxWidth,
    this.flex,
    this.alignment = Alignment.centerLeft,
  });

  /// Creates a text column.
  const TCsvColumn.text({
    required this.key,
    required this.header,
    this.isRequired = false,
    this.defaultValue,
    this.aliases = const [],
    this.validator,
    this.format,
    this.placeholder,
    this.helperText,
    this.minWidth = 150,
    this.maxWidth,
    this.flex,
    this.alignment = Alignment.centerLeft,
  }) : type = TCsvColumnType.text;

  /// Creates a floating point / decimal number column.
  const TCsvColumn.number({
    required this.key,
    required this.header,
    this.isRequired = false,
    this.defaultValue,
    this.aliases = const [],
    this.validator,
    this.format,
    this.placeholder,
    this.helperText,
    this.minWidth = 150,
    this.maxWidth,
    this.flex,
    this.alignment = Alignment.centerRight,
  }) : type = TCsvColumnType.number;

  /// Creates an integer number column.
  const TCsvColumn.integer({
    required this.key,
    required this.header,
    this.isRequired = false,
    this.defaultValue,
    this.aliases = const [],
    this.validator,
    this.format,
    this.placeholder,
    this.helperText,
    this.minWidth = 140,
    this.maxWidth,
    this.flex,
    this.alignment = Alignment.centerRight,
  }) : type = TCsvColumnType.integer;

  /// Creates a boolean toggle / switch column.
  const TCsvColumn.boolean({
    required this.key,
    required this.header,
    this.isRequired = false,
    this.defaultValue = false,
    this.aliases = const [],
    this.validator,
    this.format,
    this.placeholder,
    this.helperText,
    this.minWidth = 110,
    this.maxWidth = 160,
    this.flex,
    this.alignment = Alignment.center,
  }) : type = TCsvColumnType.boolean;

  /// Parses a raw input value into the column's target data type.
  dynamic parseValue(dynamic rawValue) {
    if (rawValue == null) {
      return defaultValue;
    }

    if (type == TCsvColumnType.text) {
      final str = rawValue.toString().trim();
      return str.isEmpty ? defaultValue : str;
    }

    if (type == TCsvColumnType.number) {
      if (rawValue is num) return rawValue.toDouble();
      final str = rawValue.toString().trim().replaceAll('\$', '').replaceAll(',', '');
      if (str.isEmpty) return defaultValue;
      final parsed = double.tryParse(str);
      return parsed ?? defaultValue;
    }

    if (type == TCsvColumnType.integer) {
      if (rawValue is int) return rawValue;
      if (rawValue is num) return rawValue.toInt();
      final str = rawValue.toString().trim().replaceAll('\$', '').replaceAll(',', '');
      if (str.isEmpty) return defaultValue;
      final parsed = int.tryParse(str) ?? double.tryParse(str)?.toInt();
      return parsed ?? defaultValue;
    }

    if (type == TCsvColumnType.boolean) {
      if (rawValue is bool) return rawValue;
      final str = rawValue.toString().trim().toLowerCase();
      if (str.isEmpty) return defaultValue ?? false;
      if (str == 'true' || str == '1' || str == 'yes' || str == 'y' || str == 't' || str == 'active' || str == 'enabled') {
        return true;
      }
      if (str == 'false' || str == '0' || str == 'no' || str == 'n' || str == 'f' || str == 'inactive' || str == 'disabled') {
        return false;
      }
      return defaultValue ?? false;
    }

    return rawValue;
  }

  /// Validates a parsed or raw value, returning an error message if invalid, or null if valid.
  String? validate(dynamic value) {
    if (isRequired) {
      if (value == null) return '$header is required';
      if (type == TCsvColumnType.text && value.toString().trim().isEmpty) {
        return '$header is required';
      }
    }

    if (value != null && value.toString().trim().isNotEmpty) {
      if (type == TCsvColumnType.number) {
        if (value is! num) {
          final str = value.toString().trim().replaceAll('\$', '').replaceAll(',', '');
          if (double.tryParse(str) == null) {
            return '$header must be a valid number';
          }
        }
      } else if (type == TCsvColumnType.integer) {
        if (value is! int) {
          final str = value.toString().trim().replaceAll('\$', '').replaceAll(',', '');
          if (int.tryParse(str) == null && double.tryParse(str) == null) {
            return '$header must be a whole number';
          }
        }
      }
    }

    if (validator != null) {
      return validator!(value);
    }

    return null;
  }

  /// Formats value for display or CSV serialization.
  String formatValue(dynamic value) {
    if (value == null) return '';
    if (format != null) return format!(value);

    if (type == TCsvColumnType.boolean) {
      return value == true ? 'true' : 'false';
    }

    return value.toString();
  }
}
