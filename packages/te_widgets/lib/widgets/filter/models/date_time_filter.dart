import 'package:flutter/foundation.dart';

/// Filter model for date-time fields matching C# `DateTimeFilter`.
///
/// Supports exact matching (`eq`, `ne`), date/time range comparisons (`gt`, `gte`, `lt`, `lte`),
/// set membership (`inField`, `notIn`), and nullability checks (`isNull`).
@immutable
class DateTimeFilter {
  /// Whether the field is null.
  final bool? isNull;

  /// Equals comparison.
  final DateTime? eq;

  /// Not equals comparison.
  final DateTime? ne;

  /// Greater than comparison.
  final DateTime? gt;

  /// Greater than or equal to comparison.
  final DateTime? gte;

  /// Less than comparison.
  final DateTime? lt;

  /// Less than or equal to comparison.
  final DateTime? lte;

  /// In list comparison (serialized to JSON as `'in'`).
  final List<DateTime>? inField;

  /// Not in list comparison.
  final List<DateTime>? notIn;

  /// Creates a [DateTimeFilter].
  const DateTimeFilter({
    this.isNull,
    this.eq,
    this.ne,
    this.gt,
    this.gte,
    this.lt,
    this.lte,
    this.inField,
    this.notIn,
  });

  /// Deserializes a [DateTimeFilter] from a JSON map.
  factory DateTimeFilter.fromJson(Map<String, dynamic> json) => DateTimeFilter(
        isNull: json['isNull'] as bool?,
        eq: _parseDate(json['eq']),
        ne: _parseDate(json['ne']),
        gt: _parseDate(json['gt']),
        gte: _parseDate(json['gte']),
        lt: _parseDate(json['lt']),
        lte: _parseDate(json['lte']),
        inField: (json['in'] as List?)?.map((e) => _parseDate(e)).whereType<DateTime>().toList(),
        notIn: (json['notIn'] as List?)?.map((e) => _parseDate(e)).whereType<DateTime>().toList(),
      );

  static DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    return DateTime.tryParse(val.toString());
  }

  /// Serializes this [DateTimeFilter] to a JSON map.
  Map<String, dynamic> toJson() => {
        if (isNull != null) 'isNull': isNull,
        if (eq != null) 'eq': eq?.toIso8601String(),
        if (ne != null) 'ne': ne?.toIso8601String(),
        if (gt != null) 'gt': gt?.toIso8601String(),
        if (gte != null) 'gte': gte?.toIso8601String(),
        if (lt != null) 'lt': lt?.toIso8601String(),
        if (lte != null) 'lte': lte?.toIso8601String(),
        if (inField != null) 'in': inField!.map((e) => e.toIso8601String()).toList(),
        if (notIn != null) 'notIn': notIn!.map((e) => e.toIso8601String()).toList(),
      };

  /// Creates a copy of this filter with the given fields replaced.
  DateTimeFilter copyWith({
    bool? isNull,
    DateTime? eq,
    DateTime? ne,
    DateTime? gt,
    DateTime? gte,
    DateTime? lt,
    DateTime? lte,
    List<DateTime>? inField,
    List<DateTime>? notIn,
  }) =>
      DateTimeFilter(
        isNull: isNull ?? this.isNull,
        eq: eq ?? this.eq,
        ne: ne ?? this.ne,
        gt: gt ?? this.gt,
        gte: gte ?? this.gte,
        lt: lt ?? this.lt,
        lte: lte ?? this.lte,
        inField: inField ?? this.inField,
        notIn: notIn ?? this.notIn,
      );

  /// Whether all filter conditions are null or empty.
  bool get isEmpty =>
      isNull == null &&
      eq == null &&
      ne == null &&
      gt == null &&
      gte == null &&
      lt == null &&
      lte == null &&
      (inField == null || inField!.isEmpty) &&
      (notIn == null || notIn!.isEmpty);

  /// Whether at least one filter condition is specified.
  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateTimeFilter &&
          other.isNull == isNull &&
          other.eq == eq &&
          other.ne == ne &&
          other.gt == gt &&
          other.gte == gte &&
          other.lt == lt &&
          other.lte == lte &&
          listEquals(other.inField, inField) &&
          listEquals(other.notIn, notIn);

  @override
  int get hashCode => Object.hash(
        isNull,
        eq,
        ne,
        gt,
        gte,
        lt,
        lte,
        inField != null ? Object.hashAll(inField!) : null,
        notIn != null ? Object.hashAll(notIn!) : null,
      );

  @override
  String toString() =>
      'DateTimeFilter(isNull: $isNull, eq: $eq, ne: $ne, gt: $gt, gte: $gte, lt: $lt, lte: $lte, in: $inField, notIn: $notIn)';
}
