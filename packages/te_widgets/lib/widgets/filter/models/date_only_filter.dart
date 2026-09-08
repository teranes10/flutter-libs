import 'package:flutter/foundation.dart';

/// Filter model for date-only fields matching C# `DateOnlyFilter`.
///
/// Supports exact matching (`eq`, `ne`), date range comparisons (`gt`, `gte`, `lt`, `lte`),
/// set membership (`inField`, `notIn`), and nullability checks (`isNull`).
@immutable
class DateOnlyFilter {
  /// Whether the field is null.
  final bool? isNull;

  /// Equals comparison (e.g. `'2026-09-03'`).
  final String? eq;

  /// Not equals comparison.
  final String? ne;

  /// Greater than comparison.
  final String? gt;

  /// Greater than or equal to comparison.
  final String? gte;

  /// Less than comparison.
  final String? lt;

  /// Less than or equal to comparison.
  final String? lte;

  /// In list comparison (serialized to JSON as `'in'`).
  final List<String>? inField;

  /// Not in list comparison.
  final List<String>? notIn;

  /// Creates a [DateOnlyFilter].
  const DateOnlyFilter({
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

  /// Deserializes a [DateOnlyFilter] from a JSON map.
  factory DateOnlyFilter.fromJson(Map<String, dynamic> json) => DateOnlyFilter(
        isNull: json['isNull'] as bool?,
        eq: json['eq']?.toString(),
        ne: json['ne']?.toString(),
        gt: json['gt']?.toString(),
        gte: json['gte']?.toString(),
        lt: json['lt']?.toString(),
        lte: json['lte']?.toString(),
        inField: (json['in'] as List?)?.map((e) => e.toString()).toList(),
        notIn: (json['notIn'] as List?)?.map((e) => e.toString()).toList(),
      );

  /// Serializes this [DateOnlyFilter] to a JSON map.
  Map<String, dynamic> toJson() => {
        if (isNull != null) 'isNull': isNull,
        if (eq != null) 'eq': eq,
        if (ne != null) 'ne': ne,
        if (gt != null) 'gt': gt,
        if (gte != null) 'gte': gte,
        if (lt != null) 'lt': lt,
        if (lte != null) 'lte': lte,
        if (inField != null) 'in': inField,
        if (notIn != null) 'notIn': notIn,
      };

  /// Creates a copy of this filter with the given fields replaced.
  DateOnlyFilter copyWith({
    bool? isNull,
    String? eq,
    String? ne,
    String? gt,
    String? gte,
    String? lt,
    String? lte,
    List<String>? inField,
    List<String>? notIn,
  }) =>
      DateOnlyFilter(
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
      other is DateOnlyFilter &&
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
      'DateOnlyFilter(isNull: $isNull, eq: $eq, ne: $ne, gt: $gt, gte: $gte, lt: $lt, lte: $lte, in: $inField, notIn: $notIn)';
}
