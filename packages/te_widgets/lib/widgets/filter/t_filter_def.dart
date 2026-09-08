import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

/// The underlying data type of a filterable field.
enum TFilterType {
  text,
  number,
  dateTime,
  date,
  boolean,
  guid,
  enumFilter,
  select,
}

/// Definition / descriptor of a single filterable field for a model of type [T].
class TFilterDef<T> {
  /// The key/field name in the target filter model or JSON object (e.g. `'name'`, `'price'`, `'createdAt'`).
  final String key;

  /// User-facing label displayed in the field selector dropdown (e.g. `'Product Name'`, `'Price'`).
  final String label;

  /// The data type of the filter field.
  final TFilterType type;

  /// List of operators available for this field.
  final List<TFilterOperator> operators;

  /// Placeholder hint text for the value input.
  final String? placeholder;

  /// Helper text displayed beneath or next to the value input.
  final String? helperText;

  /// Optional tag/badge text.
  final String? tag;

  /// Optional custom number field theme for numeric fields.
  final TNumberFieldTheme? numberTheme;

  /// Optional date format for date/dateTime fields.
  final DateFormat? dateFormat;

  /// Format type for date/dateTime fields.
  final TDateTimeFormatType formatType;

  /// Items list for enum or select fields.
  final List<dynamic>? items;

  /// Async/server load listener for select fields.
  final TLoadListener<dynamic>? onLoad;

  /// Number of items per page for paginated dropdowns.
  final int? itemsPerPage;

  /// Search debounce delay in milliseconds for async search.
  final int? searchDelay;

  /// Whether to load items lazily when the dropdown opens.
  final bool lazy;

  /// Whether to query only when a search term is typed.
  final bool loadOnSearchOnly;

  /// Number of items visible in the dropdown before scrolling.
  final int? visibleItemsCount;

  /// Text accessor for select/enum items.
  final ItemTextAccessor<dynamic>? itemText;

  /// Value accessor for select/enum items.
  final ItemValueAccessor<dynamic, dynamic>? itemValue;

  /// Unique key accessor for select/enum items.
  final ItemKeyAccessor<dynamic, String>? itemKey;

  /// Subtitle accessor for select items.
  final ItemTextAccessor<dynamic>? itemSubText;

  /// Image URL accessor for select items.
  final ItemTextAccessor<dynamic>? itemImageUrl;

  /// Deserializer function to create a typed filter struct (e.g. `(json) => StringFilter.fromJson(json)`).
  final dynamic Function(Map<String, dynamic> json)? fromJson;

  /// Function to extract the filter value from a parent filter object or item of type [T] (e.g. `(User u) => u.address.city`).
  final dynamic Function(T model)? map;

  /// Optional icon representing this field.
  final dynamic icon;

  /// Creates a [TFilterDef].
  const TFilterDef({
    required this.key,
    required this.label,
    required this.type,
    required this.operators,
    this.placeholder,
    this.helperText,
    this.tag,
    this.icon,
    this.numberTheme,
    this.dateFormat,
    this.formatType = TDateTimeFormatType.dateTime,
    this.items,
    this.onLoad,
    this.itemsPerPage,
    this.searchDelay,
    this.lazy = false,
    this.loadOnSearchOnly = false,
    this.visibleItemsCount,
    this.itemText,
    this.itemValue,
    this.itemKey,
    this.itemSubText,
    this.itemImageUrl,
    this.fromJson,
    dynamic Function(T model)? map,
    dynamic Function(T model)? getter,
    dynamic Function(T model)? prop,
  }) : map = map ?? getter ?? prop;

  /// Creates a copy of this [TFilterDef] with optional field overrides.
  TFilterDef<T> copyWith({
    String? key,
    String? label,
    TFilterType? type,
    List<TFilterOperator>? operators,
    String? placeholder,
    String? helperText,
    String? tag,
    dynamic icon,
    TNumberFieldTheme? numberTheme,
    DateFormat? dateFormat,
    TDateTimeFormatType? formatType,
    List<dynamic>? items,
    TLoadListener<dynamic>? onLoad,
    int? itemsPerPage,
    int? searchDelay,
    bool? lazy,
    bool? loadOnSearchOnly,
    int? visibleItemsCount,
    ItemTextAccessor<dynamic>? itemText,
    ItemValueAccessor<dynamic, dynamic>? itemValue,
    ItemKeyAccessor<dynamic, String>? itemKey,
    ItemTextAccessor<dynamic>? itemSubText,
    ItemTextAccessor<dynamic>? itemImageUrl,
    dynamic Function(Map<String, dynamic> json)? fromJson,
    dynamic Function(T model)? map,
    dynamic Function(T model)? getter,
    dynamic Function(T model)? prop,
  }) {
    return TFilterDef<T>(
      key: key ?? this.key,
      label: label ?? this.label,
      type: type ?? this.type,
      operators: operators ?? this.operators,
      placeholder: placeholder ?? this.placeholder,
      helperText: helperText ?? this.helperText,
      tag: tag ?? this.tag,
      icon: icon ?? this.icon,
      numberTheme: numberTheme ?? this.numberTheme,
      dateFormat: dateFormat ?? this.dateFormat,
      formatType: formatType ?? this.formatType,
      items: items ?? this.items,
      onLoad: onLoad ?? this.onLoad,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      searchDelay: searchDelay ?? this.searchDelay,
      lazy: lazy ?? this.lazy,
      loadOnSearchOnly: loadOnSearchOnly ?? this.loadOnSearchOnly,
      visibleItemsCount: visibleItemsCount ?? this.visibleItemsCount,
      itemText: itemText ?? this.itemText,
      itemValue: itemValue ?? this.itemValue,
      itemKey: itemKey ?? this.itemKey,
      itemSubText: itemSubText ?? this.itemSubText,
      itemImageUrl: itemImageUrl ?? this.itemImageUrl,
      fromJson: fromJson ?? this.fromJson,
      map: map ?? getter ?? prop ?? this.map,
    );
  }
}

/// Factory helper for creating filter field definitions.
abstract class TFilter {
  /// Defines a filter field directly from a model mapping accessor expression [map].
  ///
  /// Automatically wires the [map] expression, infers [TFilterType] from [V] if not explicitly specified,
  /// and uses [key] or camelCase of [label].
  ///
  /// Example:
  /// ```dart
  /// TFilter.map<User, String>('User City', (u) => u.address.city)
  /// TFilter.map<Order, double>('Order Total', (o) => o.summary.totalAmount)
  /// ```
  static TFilterDef<T> map<T, V>(
    String label,
    V Function(T model) map, {
    String? key,
    TFilterType? type,
    List<TFilterOperator>? operators,
    String? placeholder,
    String? helperText,
    String? tag,
    dynamic icon,
    TNumberFieldTheme? numberTheme,
    DateFormat? dateFormat,
    TDateTimeFormatType formatType = TDateTimeFormatType.dateTime,
    List<dynamic>? items,
    TLoadListener<dynamic>? onLoad,
    ItemTextAccessor<dynamic>? itemText,
    ItemValueAccessor<dynamic, dynamic>? itemValue,
    ItemKeyAccessor<dynamic, String>? itemKey,
    ItemTextAccessor<dynamic>? itemSubText,
    ItemTextAccessor<dynamic>? itemImageUrl,
    dynamic Function(Map<String, dynamic> json)? fromJson,
  }) {
    final effectiveKey = key ?? _toCamelCase(label);
    final inferredType = type ?? _inferFilterTypeFromGeneric<V>();

    return TFilterDef<T>(
      key: effectiveKey,
      label: label,
      type: inferredType,
      operators: operators ?? TFilterOperator.getOperatorsForType(inferredType),
      placeholder: placeholder,
      helperText: helperText,
      tag: tag,
      icon: icon,
      numberTheme: numberTheme,
      dateFormat: dateFormat,
      formatType: formatType,
      items: items,
      onLoad: onLoad,
      itemText: itemText,
      itemValue: itemValue,
      itemKey: itemKey,
      itemSubText: itemSubText,
      itemImageUrl: itemImageUrl,
      fromJson: fromJson,
      map: map,
    );
  }

  static TFilterType _inferFilterTypeFromGeneric<V>() {
    if (V == int || V == double || V == num || <V>[] is List<num>) {
      return TFilterType.number;
    }
    if (V == bool || <V>[] is List<bool>) {
      return TFilterType.boolean;
    }
    if (V == DateTime || <V>[] is List<DateTime>) {
      return TFilterType.dateTime;
    }
    if (<V>[] is List<Enum>) {
      return TFilterType.enumFilter;
    }
    return TFilterType.text;
  }

  /// Defines a text/string filter field (maps to [StringFilter]).
  static TFilterDef<T> text<T>(
    String label, {
    String? key,
    List<TFilterOperator>? operators,
    String? placeholder,
    String? helperText,
    String? tag,
    dynamic icon,
    StringFilter Function(Map<String, dynamic> json)? fromJson,
    dynamic Function(T model)? map,
    dynamic Function(T model)? getter,
    dynamic Function(T model)? prop,
  }) {
    final effectiveKey = key ?? _toCamelCase(label);
    return TFilterDef<T>(
      key: effectiveKey,
      label: label,
      type: TFilterType.text,
      operators: operators ?? TFilterOperator.textOperators,
      placeholder: placeholder,
      helperText: helperText,
      tag: tag,
      icon: icon,
      fromJson: fromJson ?? StringFilter.fromJson,
      map: map ?? getter ?? prop,
    );
  }

  /// Defines a numeric filter field (maps to [NumberFilter]).
  static TFilterDef<T> number<T>(
    String label, {
    String? key,
    List<TFilterOperator>? operators,
    String? placeholder,
    String? helperText,
    String? tag,
    dynamic icon,
    TNumberFieldTheme? theme,
    NumberFilter Function(Map<String, dynamic> json)? fromJson,
    dynamic Function(T model)? map,
    dynamic Function(T model)? getter,
    dynamic Function(T model)? prop,
  }) {
    final effectiveKey = key ?? _toCamelCase(label);
    return TFilterDef<T>(
      key: effectiveKey,
      label: label,
      type: TFilterType.number,
      operators: operators ?? TFilterOperator.numberOperators,
      placeholder: placeholder,
      helperText: helperText,
      tag: tag,
      icon: icon,
      numberTheme: theme,
      fromJson: fromJson ?? NumberFilter<num>.fromJson,
      map: map ?? getter ?? prop,
    );
  }

  /// Defines a date-time filter field (maps to [DateTimeFilter]).
  static TFilterDef<T> dateTime<T>(
    String label, {
    String? key,
    List<TFilterOperator>? operators,
    String? placeholder,
    String? helperText,
    String? tag,
    dynamic icon,
    DateFormat? format,
    TDateTimeFormatType formatType = TDateTimeFormatType.dateTime,
    DateTimeFilter Function(Map<String, dynamic> json)? fromJson,
    dynamic Function(T model)? map,
    dynamic Function(T model)? getter,
    dynamic Function(T model)? prop,
  }) {
    final effectiveKey = key ?? _toCamelCase(label);
    return TFilterDef<T>(
      key: effectiveKey,
      label: label,
      type: TFilterType.dateTime,
      operators: operators ?? TFilterOperator.dateTimeOperators,
      placeholder: placeholder,
      helperText: helperText,
      tag: tag,
      icon: icon,
      dateFormat: format,
      formatType: formatType,
      fromJson: fromJson ?? DateTimeFilter.fromJson,
      map: map ?? getter ?? prop,
    );
  }

  /// Defines a date-only filter field (maps to [DateOnlyFilter]).
  static TFilterDef<T> date<T>(
    String label, {
    String? key,
    List<TFilterOperator>? operators,
    String? placeholder,
    String? helperText,
    String? tag,
    dynamic icon,
    DateFormat? format,
    TDateTimeFormatType formatType = TDateTimeFormatType.date,
    DateOnlyFilter Function(Map<String, dynamic> json)? fromJson,
    dynamic Function(T model)? map,
    dynamic Function(T model)? getter,
    dynamic Function(T model)? prop,
  }) {
    final effectiveKey = key ?? _toCamelCase(label);
    return TFilterDef<T>(
      key: effectiveKey,
      label: label,
      type: TFilterType.date,
      operators: operators ?? TFilterOperator.dateTimeOperators,
      placeholder: placeholder,
      helperText: helperText,
      tag: tag,
      icon: icon,
      dateFormat: format,
      formatType: formatType,
      fromJson: fromJson ?? DateOnlyFilter.fromJson,
      map: map ?? getter ?? prop,
    );
  }

  /// Defines a boolean filter field (maps to [BoolFilter]).
  static TFilterDef<T> boolean<T>(
    String label, {
    String? key,
    List<TFilterOperator>? operators,
    String? helperText,
    String? tag,
    dynamic icon,
    BoolFilter Function(Map<String, dynamic> json)? fromJson,
    dynamic Function(T model)? map,
    dynamic Function(T model)? getter,
    dynamic Function(T model)? prop,
  }) {
    final effectiveKey = key ?? _toCamelCase(label);
    return TFilterDef<T>(
      key: effectiveKey,
      label: label,
      type: TFilterType.boolean,
      operators: operators ?? TFilterOperator.boolOperators,
      helperText: helperText,
      tag: tag,
      icon: icon,
      fromJson: fromJson ?? BoolFilter.fromJson,
      map: map ?? getter ?? prop,
    );
  }

  /// Defines a GUID/UUID filter field (maps to [GuidFilter]).
  ///
  /// Can be backed by raw text input, a local item list, or a server-side [onLoad] lookup.
  static TFilterDef<T> guid<T>(
    String label, {
    String? key,
    List<TFilterOperator>? operators,
    String? placeholder,
    String? helperText,
    String? tag,
    dynamic icon,
    List<dynamic>? items,
    dynamic onLoad,
    int? itemsPerPage,
    int? searchDelay,
    bool lazy = false,
    bool loadOnSearchOnly = false,
    int? visibleItemsCount,
    dynamic itemText,
    dynamic itemValue,
    dynamic itemKey,
    dynamic itemSubText,
    dynamic itemImageUrl,
    GuidFilter Function(Map<String, dynamic> json)? fromJson,
    dynamic Function(T model)? map,
    dynamic Function(T model)? getter,
    dynamic Function(T model)? prop,
  }) {
    final effectiveKey = key ?? _toCamelCase(label);
    final hasSource = items != null || onLoad != null;
    return TFilterDef<T>(
      key: effectiveKey,
      label: label,
      type: hasSource ? TFilterType.select : TFilterType.guid,
      operators: operators ?? TFilterOperator.guidOperators,
      placeholder: placeholder,
      helperText: helperText,
      tag: tag,
      icon: icon,
      items: items,
      onLoad: onLoad != null
          ? (options) async {
              final dynamic res = await (onLoad as Function)(options);
              if (res is TLoadResult) {
                return TLoadResult<dynamic>(
                  res.items,
                  res.totalItems,
                  nextCursor: res.nextCursor,
                  hasNextPage: res.hasNextPage,
                );
              }
              return TLoadResult<dynamic>(const [], 0);
            }
          : null,
      itemsPerPage: itemsPerPage,
      searchDelay: searchDelay,
      lazy: lazy,
      loadOnSearchOnly: loadOnSearchOnly,
      visibleItemsCount: visibleItemsCount,
      itemText: itemText != null ? (dynamic item) => (itemText as Function)(item).toString() : null,
      itemValue: itemValue != null ? (dynamic item) => (itemValue as Function)(item) : null,
      itemKey: itemKey != null
          ? (dynamic item) => (itemKey as Function)(item).toString()
          : (itemValue != null ? (dynamic item) => (itemValue as Function)(item).toString() : null),
      itemSubText: itemSubText != null ? (dynamic item) => (itemSubText as Function)(item).toString() : null,
      itemImageUrl: itemImageUrl != null ? (dynamic item) => (itemImageUrl as Function)(item).toString() : null,
      fromJson: fromJson ?? GuidFilter.fromJson,
      map: map ?? getter ?? prop,
    );
  }

  /// Defines an enum filter field (maps to [EnumFilter]).
  static TFilterDef<T> enumFilter<T>(
    String label, {
    required List<Enum> values,
    String? key,
    dynamic itemText,
    List<TFilterOperator>? operators,
    String? placeholder,
    String? helperText,
    String? tag,
    dynamic icon,
    EnumFilter Function(Map<String, dynamic> json)? fromJson,
    dynamic Function(T model)? map,
    dynamic Function(T model)? getter,
    dynamic Function(T model)? prop,
  }) {
    final effectiveKey = key ?? _toCamelCase(label);
    return TFilterDef<T>(
      key: effectiveKey,
      label: label,
      type: TFilterType.enumFilter,
      operators: operators ?? TFilterOperator.enumOperators,
      placeholder: placeholder,
      helperText: helperText,
      tag: tag,
      icon: icon,
      items: values,
      itemText: (dynamic item) => itemText != null ? (itemText as Function)(item).toString() : (item is Enum ? item.name : item.toString()),
      itemValue: (dynamic item) => item,
      itemKey: (dynamic item) => item is Enum ? item.name : item.toString(),
      fromJson: fromJson ?? ((json) => EnumFilter.fromJson(json, values: values)),
      map: map ?? getter ?? prop,
    );
  }

  /// Defines a dropdown select-backed filter field.
  ///
  /// Supports both static local [items] and async/server-side [onLoad] queries.
  static TFilterDef<T> select<T>(
    String label, {
    List<dynamic>? items,
    dynamic onLoad,
    int? itemsPerPage,
    int? searchDelay,
    bool lazy = false,
    bool loadOnSearchOnly = false,
    int? visibleItemsCount,
    dynamic itemText,
    dynamic itemValue,
    dynamic itemKey,
    dynamic itemSubText,
    dynamic itemImageUrl,
    String? key,
    List<TFilterOperator>? operators,
    String? placeholder,
    String? helperText,
    String? tag,
    dynamic icon,
    dynamic Function(Map<String, dynamic> json)? fromJson,
    dynamic Function(T model)? map,
    dynamic Function(T model)? getter,
    dynamic Function(T model)? prop,
  }) {
    final effectiveKey = key ?? _toCamelCase(label);
    return TFilterDef<T>(
      key: effectiveKey,
      label: label,
      type: TFilterType.select,
      operators: operators ?? TFilterOperator.enumOperators,
      placeholder: placeholder,
      helperText: helperText,
      tag: tag,
      icon: icon,
      items: items,
      onLoad: onLoad != null
          ? (options) async {
              final dynamic res = await (onLoad as Function)(options);
              if (res is TLoadResult) {
                return TLoadResult<dynamic>(
                  res.items,
                  res.totalItems,
                  nextCursor: res.nextCursor,
                  hasNextPage: res.hasNextPage,
                );
              }
              return TLoadResult<dynamic>(const [], 0);
            }
          : null,
      itemsPerPage: itemsPerPage,
      searchDelay: searchDelay,
      lazy: lazy,
      loadOnSearchOnly: loadOnSearchOnly,
      visibleItemsCount: visibleItemsCount,
      itemText: itemText != null ? (dynamic item) => (itemText as Function)(item).toString() : null,
      itemValue: itemValue != null ? (dynamic item) => (itemValue as Function)(item) : null,
      itemKey: itemKey != null
          ? (dynamic item) => (itemKey as Function)(item).toString()
          : (itemValue != null ? (dynamic item) => (itemValue as Function)(item).toString() : null),
      itemSubText: itemSubText != null ? (dynamic item) => (itemSubText as Function)(item).toString() : null,
      itemImageUrl: itemImageUrl != null ? (dynamic item) => (itemImageUrl as Function)(item).toString() : null,
      fromJson: fromJson,
      map: map ?? getter ?? prop,
    );
  }

  /// Defines a server-loaded select filter for entity IDs (GUID, int, long, string).
  static TFilterDef<T> serverSelect<T>(
    String label, {
    required dynamic onLoad,
    required dynamic itemText,
    required dynamic itemValue,
    dynamic itemKey,
    dynamic itemSubText,
    dynamic itemImageUrl,
    int? itemsPerPage = 7,
    int? searchDelay,
    bool lazy = false,
    bool loadOnSearchOnly = false,
    int? visibleItemsCount,
    String? key,
    List<TFilterOperator>? operators,
    String? placeholder,
    String? helperText,
    String? tag,
    dynamic icon,
    dynamic Function(Map<String, dynamic> json)? fromJson,
    dynamic Function(T model)? map,
    dynamic Function(T model)? getter,
    dynamic Function(T model)? prop,
  }) {
    final effectiveKey = key ?? _toCamelCase(label);
    return TFilterDef<T>(
      key: effectiveKey,
      label: label,
      type: TFilterType.select,
      operators: operators ?? TFilterOperator.guidOperators,
      placeholder: placeholder,
      helperText: helperText,
      tag: tag,
      icon: icon,
      onLoad: (options) async {
        final dynamic res = await (onLoad as Function)(options);
        if (res is TLoadResult) {
          return TLoadResult<dynamic>(
            res.items,
            res.totalItems,
            nextCursor: res.nextCursor,
            hasNextPage: res.hasNextPage,
          );
        }
        return TLoadResult<dynamic>(const [], 0);
      },
      itemsPerPage: itemsPerPage,
      searchDelay: searchDelay,
      lazy: lazy,
      loadOnSearchOnly: loadOnSearchOnly,
      visibleItemsCount: visibleItemsCount,
      itemText: (dynamic item) => (itemText as Function)(item).toString(),
      itemValue: (dynamic item) => (itemValue as Function)(item),
      itemKey: itemKey != null
          ? (dynamic item) => (itemKey as Function)(item).toString()
          : (dynamic item) => (itemValue as Function)(item).toString(),
      itemSubText: itemSubText != null ? (dynamic item) => (itemSubText as Function)(item).toString() : null,
      itemImageUrl: itemImageUrl != null ? (dynamic item) => (itemImageUrl as Function)(item).toString() : null,
      fromJson: fromJson,
      map: map ?? getter ?? prop,
    );
  }

  static String _toCamelCase(String text) {
    final words = text.trim().split(RegExp(r'[\s_\-]+'));
    if (words.isEmpty) return '';
    final first = words.first.toLowerCase();
    final rest = words.skip(1).map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}').join();
    return '$first$rest';
  }
}
