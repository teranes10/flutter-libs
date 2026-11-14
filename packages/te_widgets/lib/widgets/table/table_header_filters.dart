part of 'table_header.dart';

/// Implementation of [TTableHeader.autoGenerateFilterDefs].
List<TFilterDef<T>> autoGenerateTableFilterDefs<T, K>(
  List<TTableHeader<T, K>> headers, {
  List<T>? sampleItems,
}) {
  final defs = <TFilterDef<T>>[];

  for (final header in headers) {
    if (!header.filterable || header.map == null) continue;

    if (header.filterDef != null) {
      final def = header.filterDef!;
      final effectiveLabel = def.label.isNotEmpty ? def.label : header.text;
      final effectiveKey = def.key.isNotEmpty ? def.key : (header.key ?? _toCamelCase(header.text));
      defs.add(def.copyWith(
        label: effectiveLabel,
        key: effectiveKey,
        getter: def.map ?? (x) => header.map?.call(x),
      ));
      continue;
    }

    final key = header.key ?? _toCamelCase(header.text);
    TFilterType type = header.filterType ?? TFilterType.text;

    // If filterType was not explicitly provided on header, infer from sample items
    if (header.filterType == null && sampleItems != null && sampleItems.isNotEmpty) {
      dynamic sampleVal;
      for (final item in sampleItems) {
        try {
          sampleVal = header.map!(item);
          if (sampleVal != null) break;
        } catch (_) {}
      }

      if (sampleVal is int || sampleVal is double || sampleVal is num) {
        type = TFilterType.number;
      } else if (sampleVal is bool) {
        type = TFilterType.boolean;
      } else if (sampleVal is DateTime) {
        type = TFilterType.dateTime;
      } else if (sampleVal is Enum) {
        type = TFilterType.enumFilter;
      } else {
        type = TFilterType.text;
      }
    }

    switch (type) {
      case TFilterType.text:
        defs.add(TFilter.text<T>(
          header.text,
          key: key,
          getter: (x) => header.map?.call(x),
          operators: header.filterOperators,
        ));
      case TFilterType.number:
        defs.add(TFilter.number<T>(
          header.text,
          key: key,
          getter: (x) => header.map?.call(x),
          operators: header.filterOperators,
        ));
      case TFilterType.dateTime:
        defs.add(TFilter.dateTime<T>(
          header.text,
          key: key,
          getter: (x) => header.map?.call(x),
          operators: header.filterOperators,
        ));
      case TFilterType.date:
        defs.add(TFilter.date<T>(
          header.text,
          key: key,
          getter: (x) => header.map?.call(x),
          operators: header.filterOperators,
        ));
      case TFilterType.boolean:
        defs.add(TFilter.boolean<T>(
          header.text,
          key: key,
          getter: (x) => header.map?.call(x),
          operators: header.filterOperators,
        ));
      case TFilterType.enumFilter:
        if (header.filterItems != null && header.filterItems is List<Enum>) {
          defs.add(TFilter.enumFilter<T>(
            header.text,
            key: key,
            values: header.filterItems as List<Enum>,
            getter: (x) => header.map?.call(x),
            operators: header.filterOperators,
          ));
        } else {
          defs.add(TFilter.text<T>(
            header.text,
            key: key,
            getter: (x) => header.map?.call(x),
            operators: header.filterOperators,
          ));
        }
      case TFilterType.select:
        if (header.filterItems != null) {
          defs.add(TFilter.select<T>(
            header.text,
            key: key,
            items: header.filterItems,
            itemText: (x) => x.toString(),
            itemValue: (x) => x,
            getter: (x) => header.map?.call(x),
            operators: header.filterOperators,
          ));
        } else {
          defs.add(TFilter.text<T>(
            header.text,
            key: key,
            getter: (x) => header.map?.call(x),
            operators: header.filterOperators,
          ));
        }
      case TFilterType.guid:
        defs.add(TFilter.guid<T>(
          header.text,
          key: key,
          items: header.filterItems,
          getter: (x) => header.map?.call(x),
          operators: header.filterOperators,
        ));
    }
  }

  return defs;
}

String _toCamelCase(String text) {
  final words = text.trim().split(RegExp(r'[\s_\-]+'));
  if (words.isEmpty) return '';
  final first = words.first.toLowerCase();
  final rest = words.skip(1).map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}').join();
  return '$first$rest';
}
