import 'package:flutter/foundation.dart';
import 'package:hugeicons/hugeicons.dart';
import 't_filter_def.dart';

/// Enum representing the kind of operator.
enum TFilterOperatorType {
  eq,
  ne,
  contains,
  startsWith,
  endsWith,
  gt,
  gte,
  lt,
  lte,
  inList,
  notInList,
  isNull,
  isNotNull,
}

/// Defines an operator usable in a filter condition (e.g. Equals, Contains, In, Greater Than).
@immutable
class TFilterOperator {
  /// Unique identifier of the operator matching the JSON key (e.g. `'eq'`, `'contains'`, `'in'`, `'isNull'`).
  final String id;

  /// User-friendly label (e.g. `'Equals'`, `'Contains'`, `'In'`).
  final String label;

  /// Short symbol or prefix (e.g. `'='`, `'>='`, `'in'`).
  final String? shortLabel;

  /// Optional icon representing this operator.
  final dynamic icon;

  /// Operator type classification.
  final TFilterOperatorType type;

  /// Whether this operator expects a list of values (like `in` or `notIn`).
  bool get isListOperator => type == TFilterOperatorType.inList || type == TFilterOperatorType.notInList;

  /// Whether this operator is a null check (`isNull` or `isNotNull`).
  bool get isNullOperator => type == TFilterOperatorType.isNull || type == TFilterOperatorType.isNotNull;

  /// Creates a [TFilterOperator].
  const TFilterOperator({
    required this.id,
    required this.label,
    this.shortLabel,
    this.icon,
    required this.type,
  });

  static const eq =
      TFilterOperator(id: 'eq', label: 'Equals', shortLabel: '=', icon: HugeIcons.strokeRoundedEqualSign, type: TFilterOperatorType.eq);
  static const ne = TFilterOperator(
      id: 'ne', label: 'Not Equals', shortLabel: '!=', icon: HugeIcons.strokeRoundedNotEqualSign, type: TFilterOperatorType.ne);
  static const contains = TFilterOperator(
      id: 'contains', label: 'Contains', shortLabel: 'contains', icon: HugeIcons.strokeRoundedSearch01, type: TFilterOperatorType.contains);
  static const startsWith = TFilterOperator(
      id: 'startsWith',
      label: 'Starts With',
      shortLabel: 'starts with',
      icon: HugeIcons.strokeRoundedArrowRightDouble,
      type: TFilterOperatorType.startsWith);
  static const endsWith = TFilterOperator(
      id: 'endsWith',
      label: 'Ends With',
      shortLabel: 'ends with',
      icon: HugeIcons.strokeRoundedArrowLeftDouble,
      type: TFilterOperatorType.endsWith);
  static const gt = TFilterOperator(
      id: 'gt', label: 'Greater Than', shortLabel: '>', icon: HugeIcons.strokeRoundedGreaterThan, type: TFilterOperatorType.gt);
  static const gte = TFilterOperator(
      id: 'gte',
      label: 'Greater Than or Equal',
      shortLabel: '>=',
      icon: HugeIcons.strokeRoundedArrowRight03,
      type: TFilterOperatorType.gte);
  static const lt =
      TFilterOperator(id: 'lt', label: 'Less Than', shortLabel: '<', icon: HugeIcons.strokeRoundedLessThan, type: TFilterOperatorType.lt);
  static const lte = TFilterOperator(
      id: 'lte',
      label: 'Less Than or Equal',
      shortLabel: '<=',
      icon: HugeIcons.strokeRoundedArrowLeftFromLine,
      type: TFilterOperatorType.lte);
  static const inList = TFilterOperator(
      id: 'in', label: 'In', shortLabel: 'in', icon: HugeIcons.strokeRoundedCheckmarkSquare03, type: TFilterOperatorType.inList);
  static const notInList = TFilterOperator(
      id: 'notIn', label: 'Not In', shortLabel: 'not in', icon: HugeIcons.strokeRoundedCancel01, type: TFilterOperatorType.notInList);
  static const isNull = TFilterOperator(
      id: 'isNull', label: 'Is Null', shortLabel: 'is null', icon: HugeIcons.strokeRoundedHelpCircle, type: TFilterOperatorType.isNull);
  static const isNotNull = TFilterOperator(
      id: 'isNotNull',
      label: 'Is Not Null',
      shortLabel: 'is not null',
      icon: HugeIcons.strokeRoundedCheckmarkCircle01,
      type: TFilterOperatorType.isNotNull);

  /// All standard operators.
  static const List<TFilterOperator> all = [
    eq,
    ne,
    contains,
    startsWith,
    endsWith,
    gt,
    gte,
    lt,
    lte,
    inList,
    notInList,
    isNull,
    isNotNull,
  ];

  /// Standard operators for string/text fields.
  static const List<TFilterOperator> textOperators = [
    contains,
    eq,
    ne,
    startsWith,
    endsWith,
    inList,
    notInList,
    isNull,
    isNotNull,
  ];

  /// Standard operators for numeric fields.
  static const List<TFilterOperator> numberOperators = [
    eq,
    ne,
    gt,
    gte,
    lt,
    lte,
    inList,
    notInList,
    isNull,
    isNotNull,
  ];

  /// Standard operators for date/time fields.
  static const List<TFilterOperator> dateTimeOperators = [
    eq,
    ne,
    gt,
    gte,
    lt,
    lte,
    inList,
    notInList,
    isNull,
    isNotNull,
  ];

  /// Standard operators for boolean fields.
  static const List<TFilterOperator> boolOperators = [
    eq,
    ne,
    isNull,
    isNotNull,
  ];

  /// Standard operators for GUID/UUID fields.
  static const List<TFilterOperator> guidOperators = [
    eq,
    ne,
    inList,
    notInList,
    isNull,
    isNotNull,
  ];

  /// Standard operators for enum / choice fields.
  static const List<TFilterOperator> enumOperators = [
    eq,
    ne,
    inList,
    notInList,
    isNull,
    isNotNull,
  ];

  /// Finds an operator by its [id], defaulting to [eq] if not found.
  static TFilterOperator fromId(String id) {
    return all.firstWhere(
      (op) => op.id == id,
      orElse: () => eq,
    );
  }

  /// Returns the standard list of operators for a given [TFilterType].
  static List<TFilterOperator> getOperatorsForType(TFilterType type) {
    switch (type) {
      case TFilterType.text:
        return textOperators;
      case TFilterType.number:
        return numberOperators;
      case TFilterType.dateTime:
      case TFilterType.date:
        return dateTimeOperators;
      case TFilterType.boolean:
        return boolOperators;
      case TFilterType.guid:
        return guidOperators;
      case TFilterType.enumFilter:
      case TFilterType.select:
        return enumOperators;
    }
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is TFilterOperator && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TFilterOperator($id, $label)';
}
