import 'package:flutter/foundation.dart';

/// Filter model for numeric fields matching C# `NumberFilter<T>`.
///
/// Supports exact matching (`eq`, `ne`), range comparisons (`gt`, `gte`, `lt`, `lte`),
/// set membership (`inField`, `notIn`), and nullability checks (`isNull`).
///
/// Type parameter [T] must extend [num] (such as [int] or [double]).
@immutable
class NumberFilter<T extends num> {
  /// Whether the field is null.
  final bool? isNull;

  /// Equals comparison.
  final T? eq;

  /// Not equals comparison.
  final T? ne;

  /// Greater than comparison.
  final T? gt;

  /// Greater than or equal to comparison.
  final T? gte;

  /// Less than comparison.
  final T? lt;

  /// Less than or equal to comparison.
  final T? lte;

  /// In list comparison (serialized to JSON as `'in'`).
  final List<T>? inField;

  /// Not in list comparison.
  final List<T>? notIn;

  /// Creates a [NumberFilter].
  const NumberFilter({
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

  /// Deserializes a [NumberFilter] from a JSON map.
  factory NumberFilter.fromJson(Map<String, dynamic> json) => NumberFilter<T>(
        isNull: json['isNull'] as bool?,
        eq: _parseNum<T>(json['eq']),
        ne: _parseNum<T>(json['ne']),
        gt: _parseNum<T>(json['gt']),
        gte: _parseNum<T>(json['gte']),
        lt: _parseNum<T>(json['lt']),
        lte: _parseNum<T>(json['lte']),
        inField: (json['in'] as List?)?.map((e) => _parseNum<T>(e)).whereType<T>().toList(),
        notIn: (json['notIn'] as List?)?.map((e) => _parseNum<T>(e)).whereType<T>().toList(),
      );

  static N? _parseNum<N extends num>(dynamic val) {
    if (val == null) return null;
    if (val is N) return val;
    if (N == int) {
      if (val is num) return val.toInt() as N;
      return int.tryParse(val.toString()) as N?;
    }
    if (N == double) {
      if (val is num) return val.toDouble() as N;
      return double.tryParse(val.toString()) as N?;
    }
    if (val is num) return val as N;
    return num.tryParse(val.toString()) as N?;
  }

  /// Serializes this [NumberFilter] to a JSON map.
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
  NumberFilter<T> copyWith({
    bool? isNull,
    T? eq,
    T? ne,
    T? gt,
    T? gte,
    T? lt,
    T? lte,
    List<T>? inField,
    List<T>? notIn,
  }) =>
      NumberFilter<T>(
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
      other is NumberFilter<T> &&
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
      'NumberFilter(isNull: $isNull, eq: $eq, ne: $ne, gt: $gt, gte: $gte, lt: $lt, lte: $lte, in: $inField, notIn: $notIn)';
}
