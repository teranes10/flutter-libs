import 'csv_column.dart';

/// Represents a single editable row of data in [TCsvEditor].
class TCsvRow {
  static int _autoIdCounter = 0;

  /// Unique internal ID for widget keying and animations.
  final String id;

  /// Cell values keyed by [TCsvColumn.key].
  final Map<String, dynamic> values;

  /// Validation error messages keyed by [TCsvColumn.key].
  final Map<String, String> errors;

  TCsvRow({
    String? id,
    Map<String, dynamic>? values,
    Map<String, String>? errors,
  })  : id = id ?? 'row_${++_autoIdCounter}_${DateTime.now().microsecondsSinceEpoch}',
        values = values != null ? Map<String, dynamic>.from(values) : <String, dynamic>{},
        errors = errors != null ? Map<String, String>.from(errors) : <String, String>{};

  /// Whether this row has no validation errors.
  bool get isValid => errors.isEmpty;

  /// Gets a cell value by column key.
  dynamic getValue(String key) => values[key];

  /// Sets a cell value by column key.
  void setValue(String key, dynamic value) {
    values[key] = value;
  }

  /// Validates all cells in this row against column schemas.
  void validate(List<TCsvColumn> columns) {
    errors.clear();
    for (final col in columns) {
      final val = values[col.key];
      final error = col.validate(val);
      if (error != null) {
        errors[col.key] = error;
      }
    }
  }

  /// Exports row values as a clean map.
  Map<String, dynamic> toMap() => Map<String, dynamic>.from(values);

  /// Creates a clone of this row with an optional new ID.
  TCsvRow clone({bool newId = true}) {
    return TCsvRow(
      id: newId ? null : id,
      values: Map<String, dynamic>.from(values),
      errors: Map<String, String>.from(errors),
    );
  }

  @override
  String toString() => 'TCsvRow(id: $id, values: $values, isValid: $isValid)';
}
