import 'package:flutter/foundation.dart';

/// Filter model for string fields matching C# `StringFilter`.
///
/// Supports exact matching (`eq`, `ne`), pattern matching (`startsWith`,
/// `endsWith`, `contains`), set membership (`inField`, `notIn`), and nullability checks (`isNull`).
@immutable
class StringFilter {
  /// Whether the field is null.
  final bool? isNull;

  /// Equals comparison.
  final String? eq;

  /// Not equals comparison.
  final String? ne;

  /// Starts with comparison.
  final String? startsWith;

  /// Ends with comparison.
  final String? endsWith;

  /// Contains comparison.
  final String? contains;

  /// In list comparison (serialized to JSON as `'in'`).
  final List<String>? inField;

  /// Not in list comparison.
  final List<String>? notIn;

  /// Creates a [StringFilter].
  const StringFilter({
    this.isNull,
    this.eq,
    this.ne,
    this.startsWith,
    this.endsWith,
    this.contains,
    this.inField,
    this.notIn,
  });

  /// Deserializes a [StringFilter] from a JSON map.
  factory StringFilter.fromJson(Map<String, dynamic> json) => StringFilter(
        isNull: json['isNull'] as bool?,
        eq: json['eq'] as String?,
        ne: json['ne'] as String?,
        startsWith: json['startsWith'] as String?,
        endsWith: json['endsWith'] as String?,
        contains: json['contains'] as String?,
        inField: (json['in'] as List?)?.map((e) => e.toString()).toList(),
        notIn: (json['notIn'] as List?)?.map((e) => e.toString()).toList(),
      );

  /// Serializes this [StringFilter] to a JSON map.
  Map<String, dynamic> toJson() => {
        if (isNull != null) 'isNull': isNull,
        if (eq != null) 'eq': eq,
        if (ne != null) 'ne': ne,
        if (startsWith != null) 'startsWith': startsWith,
        if (endsWith != null) 'endsWith': endsWith,
        if (contains != null) 'contains': contains,
        if (inField != null) 'in': inField,
        if (notIn != null) 'notIn': notIn,
      };

  /// Creates a copy of this filter with the given fields replaced.
  StringFilter copyWith({
    bool? isNull,
    String? eq,
    String? ne,
    String? startsWith,
    String? endsWith,
    String? contains,
    List<String>? inField,
    List<String>? notIn,
  }) =>
      StringFilter(
        isNull: isNull ?? this.isNull,
        eq: eq ?? this.eq,
        ne: ne ?? this.ne,
        startsWith: startsWith ?? this.startsWith,
        endsWith: endsWith ?? this.endsWith,
        contains: contains ?? this.contains,
        inField: inField ?? this.inField,
        notIn: notIn ?? this.notIn,
      );

  /// Whether all filter conditions are null or empty.
  bool get isEmpty =>
      isNull == null &&
      eq == null &&
      ne == null &&
      startsWith == null &&
      endsWith == null &&
      contains == null &&
      (inField == null || inField!.isEmpty) &&
      (notIn == null || notIn!.isEmpty);

  /// Whether at least one filter condition is specified.
  bool get isNotEmpty => !isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringFilter &&
          other.isNull == isNull &&
          other.eq == eq &&
          other.ne == ne &&
          other.startsWith == startsWith &&
          other.endsWith == endsWith &&
          other.contains == contains &&
          listEquals(other.inField, inField) &&
          listEquals(other.notIn, notIn);

  @override
  int get hashCode => Object.hash(
        isNull,
        eq,
        ne,
        startsWith,
        endsWith,
        contains,
        inField != null ? Object.hashAll(inField!) : null,
        notIn != null ? Object.hashAll(notIn!) : null,
      );

  @override
  String toString() =>
      'StringFilter(isNull: $isNull, eq: $eq, ne: $ne, startsWith: $startsWith, endsWith: $endsWith, contains: $contains, in: $inField, notIn: $notIn)';
}
