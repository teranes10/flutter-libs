import 'package:te_widgets/te_widgets.dart';

/// Represents a single active filter condition rule (Field + Operator + Value).
class TFilterRule {
  /// The key of the selected filter field.
  String fieldKey;

  /// The ID of the selected operator (e.g. `'eq'`, `'contains'`, `'gt'`, `'in'`, `'isNull'`).
  String operatorId;

  /// The current input value for this filter rule.
  dynamic value;

  /// Creates a [TFilterRule].
  TFilterRule({
    required this.fieldKey,
    required this.operatorId,
    this.value,
  });

  /// Creates a copy of this rule with optional new values.
  TFilterRule copyWith({
    String? fieldKey,
    String? operatorId,
    dynamic value,
  }) =>
      TFilterRule(
        fieldKey: fieldKey ?? this.fieldKey,
        operatorId: operatorId ?? this.operatorId,
        value: value ?? this.value,
      );

  /// Converts a list of [TFilterRule] instances into a nested JSON filter map.
  static Map<String, dynamic> rulesToJson(
    List<TFilterRule> rules,
    List<TFilterDef> defs,
  ) {
    final result = <String, dynamic>{};

    for (final rule in rules) {
      if (rule.fieldKey.isEmpty || rule.operatorId.isEmpty) continue;

      final def = _findMatchingDef(defs, rule.fieldKey);

      final fieldMap = (result[rule.fieldKey] as Map<String, dynamic>?) ?? <String, dynamic>{};

      final op = TFilterOperator.fromId(rule.operatorId);

      if (op.type == TFilterOperatorType.isNull) {
        fieldMap['isNull'] = rule.value is bool ? rule.value : true;
      } else if (op.type == TFilterOperatorType.isNotNull) {
        fieldMap['isNull'] = false;
      } else if (op.isListOperator) {
        final rawVal = rule.value;
        List<dynamic> listVal;
        if (rawVal is List) {
          listVal = rawVal;
        } else if (rawVal != null) {
          listVal = [rawVal];
        } else {
          listVal = [];
        }

        final formattedList = listVal.map((item) => _formatValue(item, def)).toList();
        fieldMap[rule.operatorId] = formattedList;
      } else {
        if (rule.value != null) {
          fieldMap[rule.operatorId] = _formatValue(rule.value, def);
        }
      }

      if (fieldMap.isNotEmpty) {
        result[rule.fieldKey] = fieldMap;
      }
    }

    return result;
  }

  static dynamic _formatValue(dynamic val, TFilterDef def) {
    if (val == null) return null;
    if (val is DateTime) {
      return val.toIso8601String();
    }
    if (val is Enum) {
      return val.name;
    }
    if (def.type == TFilterType.number && val is String) {
      return num.tryParse(val) ?? val;
    }
    return val;
  }

  /// Converts a nested JSON map into a list of [TFilterRule] instances.
  static List<TFilterRule> fromFilterJson(
    Map<String, dynamic> json,
    List<TFilterDef> defs,
  ) {
    final rules = <TFilterRule>[];

    for (final entry in json.entries) {
      final fieldKey = entry.key;
      final val = entry.value;

      final def = _findMatchingDef(defs, fieldKey);

      if (val is Map<String, dynamic>) {
        if (_hasOperatorKeys(val)) {
          _extractRulesFromMap(def.key, val, def, rules);
        } else {
          // Nested object structure: e.g. {'user': {'address': {'city': {'eq': 'London'}}}}
          _extractNestedRules(fieldKey, val, defs, rules);
        }
      } else if (val != null) {
        // Direct object or model with toJson()
        try {
          final dynVal = val as dynamic;
          final map = dynVal.toJson() as Map<String, dynamic>;
          if (_hasOperatorKeys(map)) {
            _extractRulesFromMap(def.key, map, def, rules);
          } else {
            _extractNestedRules(fieldKey, map, defs, rules);
          }
        } catch (_) {
          rules.add(TFilterRule(
            fieldKey: def.key,
            operatorId: 'eq',
            value: val,
          ));
        }
      }
    }

    return rules;
  }

  static bool _hasOperatorKeys(Map<String, dynamic> map) {
    const opKeys = {
      'isNull',
      'isNotNull',
      'eq',
      'ne',
      'contains',
      'startsWith',
      'endsWith',
      'gt',
      'gte',
      'lt',
      'lte',
      'in',
      'notIn',
    };
    return map.keys.any((k) => opKeys.contains(k));
  }

  static void _extractNestedRules(
    String prefix,
    Map<String, dynamic> nestedMap,
    List<TFilterDef> defs,
    List<TFilterRule> rules,
  ) {
    for (final entry in nestedMap.entries) {
      final nestedKey = '$prefix.${entry.key}';
      final val = entry.value;

      final def = _findMatchingDef(defs, nestedKey);

      if (val is Map<String, dynamic>) {
        if (_hasOperatorKeys(val)) {
          _extractRulesFromMap(def.key, val, def, rules);
        } else {
          _extractNestedRules(nestedKey, val, defs, rules);
        }
      } else if (val != null) {
        rules.add(TFilterRule(
          fieldKey: def.key,
          operatorId: 'eq',
          value: val,
        ));
      }
    }
  }

  static TFilterDef _findMatchingDef(List<TFilterDef> defs, String key) {
    // Exact match
    for (final d in defs) {
      if (d.key == key) return d;
    }
    // Case-insensitive match
    final lowerKey = key.toLowerCase();
    for (final d in defs) {
      if (d.key.toLowerCase() == lowerKey) return d;
    }
    // Normalized match (e.g. user.address.city matching userAddressCity or user_address_city)
    final norm = key.replaceAll(RegExp(r'[\s_\.\-]+'), '').toLowerCase();
    for (final d in defs) {
      if (d.key.replaceAll(RegExp(r'[\s_\.\-]+'), '').toLowerCase() == norm) return d;
    }
    return TFilterDef(
      key: key,
      label: key,
      type: TFilterType.text,
      operators: TFilterOperator.all,
    );
  }

  static void _extractRulesFromMap(
    String fieldKey,
    Map<String, dynamic> map,
    TFilterDef def,
    List<TFilterRule> rules,
  ) {
    if (map.containsKey('isNull') && map['isNull'] != null) {
      final isNullVal = map['isNull'] as bool;
      rules.add(TFilterRule(
        fieldKey: fieldKey,
        operatorId: isNullVal ? 'isNull' : 'isNotNull',
        value: isNullVal,
      ));
    }

    const opKeys = [
      'eq',
      'ne',
      'contains',
      'startsWith',
      'endsWith',
      'gt',
      'gte',
      'lt',
      'lte',
      'in',
      'notIn',
    ];

    for (final opKey in opKeys) {
      if (map.containsKey(opKey) && map[opKey] != null) {
        final opVal = map[opKey];
        rules.add(TFilterRule(
          fieldKey: fieldKey,
          operatorId: opKey,
          value: _parseExtractedValue(opVal, def, opKey == 'in' || opKey == 'notIn'),
        ));
      }
    }
  }

  static dynamic _parseExtractedValue(dynamic val, TFilterDef def, bool isList) {
    if (val == null) return null;

    if (isList && val is List) {
      return val.map((e) => _parseExtractedScalar(e, def)).toList();
    }

    return _parseExtractedScalar(val, def);
  }

  static dynamic _parseExtractedScalar(dynamic val, TFilterDef def) {
    if (val == null) return null;

    if (def.type == TFilterType.dateTime) {
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? val;
    }

    if (def.type == TFilterType.number) {
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? val;
    }

    if (def.type == TFilterType.boolean) {
      if (val is bool) return val;
      if (val == 'true') return true;
      if (val == 'false') return false;
    }

    if (def.type == TFilterType.enumFilter && def.items != null) {
      for (final item in def.items!) {
        if (item is Enum && (item.name == val || item.toString() == val)) {
          return item;
        }
      }
    }

    return val;
  }

  @override
  String toString() => 'TFilterRule($fieldKey $operatorId $value)';
}
