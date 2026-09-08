import 'package:flutter/foundation.dart';

/// Filter model for boolean fields matching C# `BoolFilter`.
///
/// Supports exact matching (`eq`, `ne`) and nullability checks (`isNull`).
@immutable
class BoolFilter {
  /// Whether the field is null.
  final bool? isNull;

  /// Equals comparison.
  final bool? eq;

  /// Not equals comparison.
  final bool? ne;

  /// Creates a [BoolFilter].
  const BoolFilter({
    this.isNull,
    this.eq,
    this.ne,
  });

  /// Deserializes a [BoolFilter] from a JSON map.
  factory BoolFilter.fromJson(Map<String, dynamic> json) => BoolFilter(
        isNull: json['isNull'] as bool?,
        eq: json['eq'] as bool?,
        ne: json['ne'] as bool?,
      );

  /// Serializes this [BoolFilter] to a JSON map.
  Map<String, dynamic> toJson() => {
        if (isNull != null) 'isNull': isNull,
        if (eq != null) 'eq': eq,
        if (ne != null) 'ne': ne,
      };

  /// Creates a copy of this filter with the given fields replaced.
  BoolFilter copyWith({
    bool? isNull,
    bool? eq,
    bool? ne,
  }) =>
      BoolFilter(
        isNull: isNull ?? this.isNull,
        eq: eq ?? this.eq,
        ne: ne ?? this.ne,
      );

  /// Whether all filter conditions are null.
  bool get isEmpty => isNull == null && eq == null && ne == null;

  /// Whether at least one filter condition is specified.
  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoolFilter &&
          other.isNull == isNull &&
          other.eq == eq &&
          other.ne == ne;

  @override
  int get hashCode => Object.hash(isNull, eq, ne);

  @override
  String toString() => 'BoolFilter(isNull: $isNull, eq: $eq, ne: $ne)';
}
