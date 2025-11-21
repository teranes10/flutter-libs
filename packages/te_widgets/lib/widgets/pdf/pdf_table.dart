import 'package:flutter/material.dart' show BuildContext;
import 'package:pdf/widgets.dart';
import 'package:te_widgets/te_widgets.dart';

class TTableHelper {
  static from<T, K>(
    BuildContext context,
    List<TTableHeader<T, K>> headers,
    List<T> items, {
    TPdfTableDecoration decoration = const TPdfTableDecoration(),
  }) {
    final colors = context.colors;
    final effectiveHeaders = headers.where((header) => header.map != null);
    final tHeaders = effectiveHeaders.map((header) => header.text).toList();
    final tData = items.map((item) => effectiveHeaders.map((header) => header.getValue(item)).toList()).toList();

    return TableHelper.fromTextArray(
      headers: tHeaders,
      data: tData,
      border: decoration.getBorder(colors),
      headerStyle: decoration.getHeaderStyle(colors),
      cellStyle: decoration.getCellStyle(colors),
      headerAlignment: decoration.headerAlignment,
      cellAlignment: decoration.cellAlignment,
      headerPadding: decoration.headerPadding,
      cellPadding: decoration.cellPadding,
    );
  }
}
