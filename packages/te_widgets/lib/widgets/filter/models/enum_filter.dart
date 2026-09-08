import 'package:flutter/foundation.dart';

/// Filter model for enum fields matching C# `EnumFilter<T>`.
///
/// Supports exact matching (`eq`, `ne`), ordering comparisons (`gt`, `gte`, `lt`, `lte`),
/// set membership (`inField`, `notIn`), and nullability checks (`isNull`).
///
/// Type parameter [T] must extend [Enum].
@immutable
class EnumFilter<T extends Enum> {
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

  /// Creates an [EnumFilter].
  const EnumFilter({
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

  /// Deserializes an [EnumFilter] from a JSON map given a parser function or enum values list.
  factory EnumFilter.fromJson(
    Map<String, dynamic> json, {
    T Function(String)? enumParser,
    List<T>? values,
  }) {
    T? parse(dynamic val) {
      if (val == null) return null;
      if (val is T) return val;
      final str = val.toString();
      if (enumParser != null) return enumParser(str);
      if (values != null) {
        for (final v in values) {
          if (v.name == str || v.toString() == str) return v;
        }
      }
      return null;
    }

    return EnumFilter<T>(
      isNull: json['isNull'] as bool?,
      eq: parse(json['eq']),
      ne: parse(json['ne']),
      gt: parse(json['gt']),
      gte: parse(json['gte']),
      lt: parse(json['lt']),
      lte: parse(json['lte']),
      inField: (json['in'] as List?)?.map((e) => parse(e)).whereType<T>().toList(),
      notIn: (json['notIn'] as List?)?.map((e) => parse(e)).whereType<T>().toList(),
    );
  }

  /// Serializes this [EnumFilter] to a JSON map.
  Map<String, dynamic> toJson([String Function(T)? enumSerializer]) => {
        if (isNull != null) 'isNull': isNull,
        if (eq != null) 'eq': enumSerializer != null ? enumSerializer(eq!) : eq?.name,
        if (ne != null) 'ne': enumSerializer != null ? enumSerializer(ne!) : ne?.name,
        if (gt != null) 'gt': enumSerializer != null ? enumSerializer(gt!) : gt?.name,
        if (gte != null) 'gte': enumSerializer != null ? enumSerializer(gte!) : gte?.name,
        if (lt != null) 'lt': enumSerializer != null ? enumSerializer(lt!) : lt?.name,
        if (lte != null) 'lte': enumSerializer != null ? enumSerializer(lte!) : lte?.name,
        if (inField != null)
          'in': inField!.map((e) => enumSerializer != null ? enumSerializer(e) : e.name).toList(),
        if (notIn != null)
          'notIn': notIn!.map((e) => enumSerializer != null ? enumSerializer(e) : e.name).toList(),
      };

  /// Creates a copy of this filter with the given fields replaced.
  EnumFilter<T> copyWith({
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
      EnumFilter<T>(
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
      other is EnumFilter<T> &&
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
      'EnumFilter(isNull: $isNull, eq: $eq, ne: $ne, gt: $gt, gte: $gte, lt: $lt, lte: $lte, in: $inField, notIn: $notIn)';
}
