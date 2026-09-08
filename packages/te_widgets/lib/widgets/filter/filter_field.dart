import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A complex filter builder field that maps UI filter conditions to strongly-typed filter objects.
///
/// Supports backend filter models like C# `StringFilter`, `NumberFilter<T>`,
/// `DateTimeFilter`, `DateOnlyFilter`, `BoolFilter`, `GuidFilter`, and `EnumFilter<T>`.
///
/// Features:
/// - Dynamic field selection with [TSelect]
/// - Adaptive operators with [TSelect]
/// - Dynamic input widgets based on field type ([TTextField], [TNumberField], [TDateTimeTextField], [TSwitch], [TTagsField], [TMultiSelect])
/// - Two-way serialization to/from JSON or strongly-typed aggregate models (e.g. `ProductFilter`)
/// - Responsive 12-column row layout with desktop/mobile support
///
/// ## Example Usage
///
/// ```dart
/// TFilterField<ProductFilter>(
///   label: 'Product Filters',
///   construct: (json) => ProductFilter.fromJson(json),
///   filters: [
///     TFilter.text('Product Name', key: 'name'),
///     TFilter.guid('Brand ID', key: 'brandId'),
///     TFilter.boolean('Is Active', key: 'isActive'),
///     TFilter.dateTime('Created At', key: 'createdAt'),
///     TFilter.number<double>('Price', key: 'price'),
///   ],
///   onValueChanged: (filter) => print('Updated filter: $filter'),
/// )
/// ```
class TFilterField<T> extends StatefulWidget with TFocusMixin, TInputValueMixin<T>, TInputValidationMixin<T> {
  /// The label text displayed above the filter container.
  @override
  final String? label;

  /// Optional tag/badge text displayed next to the label.
  final String? tag;

  /// Helper text displayed beneath the label.
  final String? helperText;

  /// Contextual information tooltip text.
  final String? info;

  /// Whether this field is required.
  @override
  final bool isRequired;

  /// Whether the filter field is disabled.
  final bool disabled;

  /// Whether the filter field is auto focused.
  final bool autoFocus;

  /// Whether the filter field is read only.
  final bool readOnly;

  @override
  final FocusNode? focusNode;

  @override
  final T? value;

  @override
  final ValueNotifier<T?>? valueNotifier;

  @override
  final ValueChanged<T?>? onValueChanged;

  @override
  final List<String? Function(T?)>? rules;

  @override
  final Duration? validationDebounce;

  /// Available filter field definitions.
  final List<TFilterDef> filters;

  /// Factory function to construct a typed filter model [T] from the generated JSON map.
  final T Function(Map<String, dynamic> json)? construct;

  /// Serializer function to extract the JSON map from [T] when editing existing values.
  final Map<String, dynamic> Function(T value)? toJson;

  /// Label for the "Add Filter" button.
  final String addFilterLabel;

  /// Label for the "Clear All" button.
  final String clearAllLabel;

  /// Text shown when no filter rules are active.
  final String emptyLabel;

  /// Whether to show the "Clear All" action button.
  final bool showClearAll;

  /// Theme configuration for this filter field.
  final TFilterFieldTheme? theme;

  /// Creates a [TFilterField].
  const TFilterField({
    super.key,
    this.label = 'Filters',
    this.tag,
    this.helperText,
    this.info,
    this.isRequired = false,
    this.disabled = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.focusNode,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.rules,
    this.validationDebounce,
    required this.filters,
    this.construct,
    this.toJson,
    this.addFilterLabel = 'Add Filter',
    this.clearAllLabel = 'Clear All',
    this.emptyLabel = 'No filter conditions applied.',
    this.showClearAll = true,
    this.theme,
  });

  @override
  State<TFilterField<T>> createState() => _TFilterFieldState<T>();
}

class _TFilterFieldState<T> extends State<TFilterField<T>>
    with TFocusStateMixin<TFilterField<T>>, TInputValueStateMixin<T, TFilterField<T>>, TInputValidationStateMixin<T, TFilterField<T>> {
  late List<TFilterRule> _rules;

  @override
  void initState() {
    super.initState();
    _rules = _extractRulesFromValue(widget.value ?? widget.valueNotifier?.value);
  }

  @override
  void onExternalValueChanged(T? value) {
    super.onExternalValueChanged(value);
    final updatedRules = _extractRulesFromValue(value);
    setState(() {
      _rules = updatedRules;
    });
  }

  List<TFilterRule> _extractRulesFromValue(T? val) {
    if (val == null) return [];

    if (val is Map<String, dynamic>) {
      return TFilterRule.fromFilterJson(val, widget.filters);
    }

    if (widget.toJson != null) {
      final json = widget.toJson!(val);
      return TFilterRule.fromFilterJson(json, widget.filters);
    }

    try {
      final dynVal = val as dynamic;
      final json = dynVal.toJson() as Map<String, dynamic>;
      return TFilterRule.fromFilterJson(json, widget.filters);
    } catch (_) {
      return [];
    }
  }

  void _notifyChanged() {
    final jsonMap = TFilterRule.rulesToJson(_rules, widget.filters);

    T? constructed;
    if (widget.construct != null) {
      constructed = jsonMap.isEmpty ? widget.construct!(jsonMap) : widget.construct!(jsonMap);
    } else if (T == dynamic || T == (Map<String, dynamic>)) {
      constructed = jsonMap as T?;
    } else {
      constructed = null;
    }

    notifyValueChanged(constructed);
  }

  TFilterDef _findDef(String? key) {
    if (widget.filters.isEmpty) {
      return TFilterDef(
        key: key ?? '',
        label: key ?? '',
        type: TFilterType.text,
        operators: TFilterOperator.textOperators,
      );
    }
    for (final d in widget.filters) {
      if (d.key == key) return d;
    }
    return widget.filters.first;
  }

  void _addRule() {
    if (widget.filters.isEmpty) return;

    final existingKeys = _rules.map((r) => r.fieldKey).toSet();
    TFilterDef? nextDef;
    for (final d in widget.filters) {
      if (!existingKeys.contains(d.key)) {
        nextDef = d;
        break;
      }
    }
    nextDef ??= widget.filters.first;

    final defaultOp = nextDef.operators.isNotEmpty ? nextDef.operators.first : TFilterOperator.eq;

    setState(() {
      _rules.add(TFilterRule(
        fieldKey: nextDef!.key,
        operatorId: defaultOp.id,
        value: _defaultValueForType(nextDef.type, defaultOp),
      ));
    });

    _notifyChanged();
  }

  dynamic _defaultValueForType(TFilterType type, TFilterOperator op) {
    if (op.isListOperator) return <dynamic>[];
    if (op.isNullOperator) return true;
    if (type == TFilterType.boolean) return true;
    return null;
  }

  void _removeRule(int index) {
    if (index >= 0 && index < _rules.length) {
      setState(() {
        _rules.removeAt(index);
      });
      _notifyChanged();
    }
  }

  void _clearAllRules() {
    setState(() {
      _rules.clear();
    });
    _notifyChanged();
  }

  void _updateRuleField(int index, String? newFieldKey) {
    if (newFieldKey == null || index < 0 || index >= _rules.length) return;

    final def = _findDef(newFieldKey);
    final defaultOp = def.operators.isNotEmpty ? def.operators.first : TFilterOperator.eq;

    setState(() {
      _rules[index] = TFilterRule(
        fieldKey: newFieldKey,
        operatorId: defaultOp.id,
        value: _defaultValueForType(def.type, defaultOp),
      );
    });

    _notifyChanged();
  }

  void _updateRuleOperator(int index, String? newOperatorId) {
    if (newOperatorId == null || index < 0 || index >= _rules.length) return;

    final rule = _rules[index];
    final oldOp = TFilterOperator.fromId(rule.operatorId);
    final newOp = TFilterOperator.fromId(newOperatorId);

    dynamic adaptedValue = rule.value;
    if (newOp.isListOperator && !oldOp.isListOperator) {
      adaptedValue = rule.value != null ? [rule.value] : <dynamic>[];
    } else if (!newOp.isListOperator && oldOp.isListOperator) {
      final list = rule.value as List?;
      adaptedValue = (list != null && list.isNotEmpty) ? list.first : null;
    } else if (newOp.isNullOperator) {
      adaptedValue = newOp.type == TFilterOperatorType.isNull;
    }

    setState(() {
      _rules[index] = rule.copyWith(
        operatorId: newOperatorId,
        value: adaptedValue,
      );
    });

    _notifyChanged();
  }

  void _updateRuleValue(int index, dynamic newValue) {
    if (index < 0 || index >= _rules.length) return;

    setState(() {
      _rules[index] = _rules[index].copyWith(value: newValue);
    });

    _notifyChanged();
  }

  Widget _buildValueInput(
      int index, TFilterRule rule, TFilterDef def, TTextFieldTheme smallTextTheme, TTagsFieldTheme smallTagsTheme, ThemeData themeData) {
    final op = TFilterOperator.fromId(rule.operatorId);

    if (op.isNullOperator) {
      return const SizedBox.shrink();
    }

    switch (def.type) {
      case TFilterType.text:
        if (op.isListOperator) {
          final tagsList = (rule.value is List)
              ? (rule.value as List).map((e) => e.toString()).toList()
              : (rule.value != null ? [rule.value.toString()] : <String>[]);
          return TTagsField(
            theme: smallTagsTheme,
            placeholder: def.placeholder ?? 'Add text values...',
            disabled: widget.disabled,
            readOnly: widget.readOnly,
            value: tagsList,
            onValueChanged: (val) => _updateRuleValue(index, val ?? []),
          );
        }
        return TTextField<String>(
          theme: smallTextTheme,
          placeholder: def.placeholder ?? 'Enter text...',
          clearable: true,
          disabled: widget.disabled,
          readOnly: widget.readOnly,
          value: rule.value?.toString(),
          onValueChanged: (val) => _updateRuleValue(index, val),
        );

      case TFilterType.number:
        if (op.isListOperator) {
          final tagsList = (rule.value is List)
              ? (rule.value as List).map((e) => e.toString()).toList()
              : (rule.value != null ? [rule.value.toString()] : <String>[]);
          return TTagsField(
            theme: smallTagsTheme,
            placeholder: def.placeholder ?? 'Add numbers...',
            disabled: widget.disabled,
            readOnly: widget.readOnly,
            value: tagsList,
            onValueChanged: (val) {
              final parsed = (val ?? []).map((e) => num.tryParse(e)).whereType<num>().toList();
              _updateRuleValue(index, parsed);
            },
          );
        }
        final numVal = rule.value is num ? rule.value as num : num.tryParse(rule.value?.toString() ?? '');
        final numTheme = (def.numberTheme ?? context.theme.numberFieldTheme).copyWith(size: TInputSize.sm);
        return TNumberField<num>(
          placeholder: def.placeholder ?? 'Enter number...',
          clearable: true,
          disabled: widget.disabled,
          readOnly: widget.readOnly,
          theme: numTheme,
          value: numVal,
          onValueChanged: (val) => _updateRuleValue(index, val),
        );

      case TFilterType.dateTime:
        final dateStr = rule.value is DateTime ? (rule.value as DateTime).toIso8601String() : rule.value?.toString();
        return TDateTimeTextField(
          theme: smallTextTheme,
          placeholder: def.placeholder,
          formatType: def.formatType,
          disabled: widget.disabled,
          readOnly: widget.readOnly,
          value: dateStr,
          onValueChanged: (val) => _updateRuleValue(index, val),
        );

      case TFilterType.date:
        final dateStr = rule.value is DateTime ? (rule.value as DateTime).toIso8601String() : rule.value?.toString();
        return TDateTimeTextField(
          theme: smallTextTheme,
          placeholder: def.placeholder,
          formatType: TDateTimeFormatType.date,
          disabled: widget.disabled,
          readOnly: widget.readOnly,
          value: dateStr,
          onValueChanged: (val) => _updateRuleValue(index, val),
        );

      case TFilterType.boolean:
        final boolVal = rule.value is bool ? (rule.value as bool) : (rule.value == 'true' || rule.value == true);
        return Container(
          alignment: Alignment.centerLeft,
          height: 38,
          child: TSwitch(
            size: TInputSize.sm,
            value: boolVal,
            disabled: widget.disabled || widget.readOnly,
            onValueChanged: (val) => _updateRuleValue(index, val ?? true),
          ),
        );

      case TFilterType.guid:
        if ((def.items != null && def.items!.isNotEmpty) || def.onLoad != null) {
          if (op.isListOperator) {
            final selList = (rule.value is List) ? (rule.value as List) : (rule.value != null ? [rule.value] : []);
            return TMultiSelect<dynamic, dynamic, String>(
              theme: smallTagsTheme,
              placeholder: def.placeholder ?? 'Select items...',
              items: def.items,
              onLoad: def.onLoad,
              itemsPerPage: def.itemsPerPage,
              searchDelay: def.searchDelay,
              lazy: def.lazy,
              visibleItemsCount: def.visibleItemsCount,
              itemText: def.itemText ?? (x) => x.toString(),
              itemValue: def.itemValue ?? (x) => x,
              itemKey: def.itemKey != null
                  ? (x) => def.itemKey!(x).toString()
                  : (x) => (def.itemValue != null ? def.itemValue!(x).toString() : x.toString()),
              itemSubText: def.itemSubText,
              itemImageUrl: def.itemImageUrl,
              disabled: widget.disabled,
              readOnly: widget.readOnly,
              value: selList,
              onValueChanged: (val) => _updateRuleValue(index, val ?? []),
            );
          }
          return TSelect<dynamic, dynamic, String>(
            theme: smallTextTheme,
            placeholder: def.placeholder ?? 'Select item...',
            items: def.items,
            onLoad: def.onLoad,
            itemsPerPage: def.itemsPerPage,
            searchDelay: def.searchDelay,
            lazy: def.lazy,
            loadOnSearchOnly: def.loadOnSearchOnly,
            visibleItemsCount: def.visibleItemsCount,
            itemText: def.itemText ?? (x) => x.toString(),
            itemValue: def.itemValue ?? (x) => x,
            itemKey: def.itemKey != null
                ? (x) => def.itemKey!(x).toString()
                : (x) => (def.itemValue != null ? def.itemValue!(x).toString() : x.toString()),
            itemSubText: def.itemSubText,
            itemImageUrl: def.itemImageUrl,
            disabled: widget.disabled,
            readOnly: widget.readOnly,
            value: rule.value,
            onValueChanged: (val) => _updateRuleValue(index, val),
          );
        }
        if (op.isListOperator) {
          final tagsList = (rule.value is List)
              ? (rule.value as List).map((e) => e.toString()).toList()
              : (rule.value != null ? [rule.value.toString()] : <String>[]);
          return TTagsField(
            theme: smallTagsTheme,
            placeholder: def.placeholder ?? 'Add GUIDs...',
            disabled: widget.disabled,
            readOnly: widget.readOnly,
            value: tagsList,
            onValueChanged: (val) => _updateRuleValue(index, val ?? []),
          );
        }
        return TTextField<String>(
          theme: smallTextTheme,
          placeholder: def.placeholder ?? 'Enter GUID...',
          clearable: true,
          disabled: widget.disabled,
          readOnly: widget.readOnly,
          value: rule.value?.toString(),
          onValueChanged: (val) => _updateRuleValue(index, val),
        );

      case TFilterType.enumFilter:
      case TFilterType.select:
        if (op.isListOperator) {
          final selList = (rule.value is List) ? (rule.value as List) : (rule.value != null ? [rule.value] : []);
          return TMultiSelect<dynamic, dynamic, String>(
            theme: smallTagsTheme,
            placeholder: def.placeholder ?? 'Select options...',
            items: def.items,
            onLoad: def.onLoad,
            itemsPerPage: def.itemsPerPage,
            searchDelay: def.searchDelay,
            lazy: def.lazy,
            visibleItemsCount: def.visibleItemsCount,
            itemText: def.itemText ?? (x) => x.toString(),
            itemValue: def.itemValue ?? (x) => x,
            itemKey: def.itemKey != null
                ? (x) => def.itemKey!(x).toString()
                : (x) => (def.itemValue != null ? def.itemValue!(x).toString() : x.toString()),
            itemSubText: def.itemSubText,
            itemImageUrl: def.itemImageUrl,
            disabled: widget.disabled,
            readOnly: widget.readOnly,
            value: selList,
            onValueChanged: (val) => _updateRuleValue(index, val ?? []),
          );
        }
        return TSelect<dynamic, dynamic, String>(
          theme: smallTextTheme,
          placeholder: def.placeholder ?? 'Select option...',
          items: def.items,
          onLoad: def.onLoad,
          itemsPerPage: def.itemsPerPage,
          searchDelay: def.searchDelay,
          lazy: def.lazy,
          loadOnSearchOnly: def.loadOnSearchOnly,
          visibleItemsCount: def.visibleItemsCount,
          itemText: def.itemText ?? (x) => x.toString(),
          itemValue: def.itemValue ?? (x) => x,
          itemKey: def.itemKey != null
              ? (x) => def.itemKey!(x).toString()
              : (x) => (def.itemValue != null ? def.itemValue!(x).toString() : x.toString()),
          itemSubText: def.itemSubText,
          itemImageUrl: def.itemImageUrl,
          disabled: widget.disabled,
          readOnly: widget.readOnly,
          value: rule.value,
          onValueChanged: (val) => _updateRuleValue(index, val),
        );
    }
  }

  Widget _buildRuleRow(int index, TFilterRule rule, ThemeData themeData, TFilterFieldTheme filterTheme) {
    final def = _findDef(rule.fieldKey);

    final op = TFilterOperator.fromId(rule.operatorId);
    final smallTextTheme = context.theme.textFieldTheme.copyWith(size: TInputSize.sm);
    final smallTagsTheme = context.theme.tagsFieldTheme.copyWith(size: TInputSize.sm);

    final ruleBg = filterTheme.ruleBackgroundColor;
    final ruleBorder = filterTheme.ruleBorderColor;
    final hasRuleDecoration = ruleBg != null || ruleBorder != null;

    final fieldSelect = TSelect<TFilterDef, String, String>(
      theme: smallTextTheme,
      items: widget.filters.toList(),
      itemKey: (d) => d.key,
      itemValue: (d) => d.key,
      itemText: (d) => d.label,
      placeholder: 'Field',
      disabled: widget.disabled || widget.readOnly,
      value: rule.fieldKey,
      onValueChanged: (val) => _updateRuleField(index, val),
    );

    final operatorDropdown = TDropdown(
      theme: context.theme.dropdownTheme.copyWith(
        gap: 0.0,
        itemPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      ),
      triggerMode: TDropdownTriggerMode.tap,
      enabled: !widget.disabled && !widget.readOnly,
      items: def.operators.map((o) {
        return TDropdownItem(
          icon: o.icon,
          text: o.label,
          onTap: () => _updateRuleOperator(index, o.id),
        );
      }).toList(),
      child: TInputContainer(
        size: TInputSize.sm,
        block: false,
        disabled: widget.disabled || widget.readOnly,
        child: TIcon.raw(
          op.icon ?? HugeIcons.strokeRoundedEqualSign,
          size: 16,
          color: themeData.colorScheme.onSurface,
        ),
      ),
    );

    final deleteButton = TButton(
      icon: HugeIcons.strokeRoundedDelete02,
      size: TButtonSize.sm,
      type: TButtonType.softText,
      color: themeData.colorScheme.error,
      onTap: (widget.disabled || widget.readOnly) ? null : () => _removeRule(index),
    );

    return Container(
      key: ValueKey('filter_rule_${index}_${rule.fieldKey}'),
      margin: EdgeInsets.only(bottom: filterTheme.rowGap),
      padding: filterTheme.rulePadding,
      decoration: hasRuleDecoration
          ? BoxDecoration(
              color: ruleBg,
              borderRadius: BorderRadius.circular(filterTheme.ruleBorderRadius),
              border: ruleBorder != null ? Border.all(color: ruleBorder) : null,
            )
          : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 380;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: fieldSelect),
                    SizedBox(width: filterTheme.fieldGap),
                    operatorDropdown,
                    SizedBox(width: filterTheme.fieldGap),
                    deleteButton,
                  ],
                ),
                if (!op.isNullOperator) ...[
                  SizedBox(height: filterTheme.fieldGap),
                  _buildValueInput(index, rule, def, smallTextTheme, smallTagsTheme, themeData),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: fieldSelect),
              SizedBox(width: filterTheme.fieldGap),
              operatorDropdown,
              if (!op.isNullOperator) ...[
                SizedBox(width: filterTheme.fieldGap),
                Expanded(
                  flex: 6,
                  child: _buildValueInput(index, rule, def, smallTextTheme, smallTagsTheme, themeData),
                ),
              ],
              SizedBox(width: filterTheme.fieldGap),
              deleteButton,
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final filterTheme = widget.theme ?? const TFilterFieldTheme();

    final cardBg = filterTheme.backgroundColor;
    final cardBorder = filterTheme.borderColor;
    final hasCardDecoration = cardBg != null || cardBorder != null;

    return Container(
      decoration: hasCardDecoration
          ? BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(filterTheme.borderRadius),
              border: cardBorder != null ? Border.all(color: cardBorder) : null,
            )
          : null,
      padding: filterTheme.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TBadge.count(
                count: _rules.length,
                offset: Offset(14, 4),
                size: TBadgeSize.sm,
                child: widget.label == null || widget.label!.isEmpty
                    ? SizedBox.shrink()
                    : Text(
                        widget.label!,
                        style: themeData.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: themeData.colorScheme.onSurface,
                        ),
                      ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showClearAll && _rules.isNotEmpty && !widget.disabled && !widget.readOnly) ...[
                    TButton(
                      type: TButtonType.softText,
                      size: TButtonSize.xs,
                      text: widget.clearAllLabel,
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: themeData.colorScheme.onSurfaceVariant,
                      onTap: _clearAllRules,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (!widget.disabled && !widget.readOnly)
                    TButton(
                      type: TButtonType.tonal,
                      size: TButtonSize.xs,
                      text: widget.addFilterLabel,
                      icon: HugeIcons.strokeRoundedAdd01,
                      onTap: _addRule,
                    ),
                ],
              ),
            ],
          ),

          if (widget.helperText != null) ...[
            const SizedBox(height: 3),
            Text(
              widget.helperText!,
              style: themeData.textTheme.bodySmall?.copyWith(
                color: themeData.colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Rules List or Empty State
          if (_rules.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: themeData.colorScheme.surfaceContainerHighest.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TIcon.raw(
                    HugeIcons.strokeRoundedFilter,
                    size: 28,
                    color: themeData.colorScheme.onSurfaceVariant.withAlpha(150),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.emptyLabel,
                    style: themeData.textTheme.bodyMedium?.copyWith(
                      color: themeData.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!widget.disabled && !widget.readOnly) ...[
                    const SizedBox(height: 12),
                    TButton(
                      type: TButtonType.text,
                      size: TButtonSize.sm,
                      icon: HugeIcons.strokeRoundedAdd01,
                      text: widget.addFilterLabel,
                      onTap: _addRule,
                    ),
                  ],
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _rules.length; i++) _buildRuleRow(i, _rules[i], themeData, filterTheme),
              ],
            ),
        ],
      ),
    );
  }
}
