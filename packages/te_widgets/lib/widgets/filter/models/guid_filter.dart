import 'package:flutter/foundation.dart';

/// Filter model for GUID/UUID fields matching C# `GuidFilter`.
///
/// Supports exact matching (`eq`, `ne`), set membership (`inField`, `notIn`),
/// and nullability checks (`isNull`).
@immutable
class GuidFilter {
  /// Whether the field is null.
  final bool? isNull;

  /// Equals comparison.
  final String? eq;

  /// Not equals comparison.
  final String? ne;

  /// In list comparison (serialized to JSON as `'in'`).
  final List<String>? inField;

  /// Not in list comparison.
  final List<String>? notIn;

  /// Creates a [GuidFilter].
  const GuidFilter({
    this.isNull,
    this.eq,
    this.ne,
    this.inField,
    this.notIn,
  });

  /// Deserializes a [GuidFilter] from a JSON map.
  factory GuidFilter.fromJson(Map<String, dynamic> json) => GuidFilter(
        isNull: json['isNull'] as bool?,
        eq: json['eq']?.toString(),
        ne: json['ne']?.toString(),
        inField: (json['in'] as List?)?.map((e) => e.toString()).toList(),
        notIn: (json['notIn'] as List?)?.map((e) => e.toString()).toList(),
      );

  /// Serializes this [GuidFilter] to a JSON map.
  Map<String, dynamic> toJson() => {
        if (isNull != null) 'isNull': isNull,
        if (eq != null) 'eq': eq,
        if (ne != null) 'ne': ne,
        if (inField != null) 'in': inField,
        if (notIn != null) 'notIn': notIn,
      };

  /// Creates a copy of this filter with the given fields replaced.
  GuidFilter copyWith({
    bool? isNull,
    String? eq,
    String? ne,
    List<String>? inField,
    List<String>? notIn,
  }) =>
      GuidFilter(
        isNull: isNull ?? this.isNull,
        eq: eq ?? this.eq,
        ne: ne ?? this.ne,
        inField: inField ?? this.inField,
        notIn: notIn ?? this.notIn,
      );

  /// Whether all filter conditions are null or empty.
  bool get isEmpty =>
      isNull == null && eq == null && ne == null && (inField == null || inField!.isEmpty) && (notIn == null || notIn!.isEmpty);

  /// Whether at least one filter condition is specified.
  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuidFilter &&
          other.isNull == isNull &&
          other.eq == eq &&
          other.ne == ne &&
          listEquals(other.inField, inField) &&
          listEquals(other.notIn, notIn);

  @override
  int get hashCode => Object.hash(
        isNull,
        eq,
        ne,
        inField != null ? Object.hashAll(inField!) : null,
        notIn != null ? Object.hashAll(notIn!) : null,
      );

  @override
  String toString() => 'GuidFilter(isNull: $isNull, eq: $eq, ne: $ne, in: $inField, notIn: $notIn)';
}
