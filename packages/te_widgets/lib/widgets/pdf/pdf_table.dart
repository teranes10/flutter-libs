import 'package:flutter/material.dart' show BuildContext;
import 'package:pdf/widgets.dart';
import 'package:te_widgets/configs/theme/theme_extension.dart';
import 'package:te_widgets/widgets/pdf/pdf_table_config.dart';
import 'package:te_widgets/widgets/table/table_configs.dart';

class TTableHelper {
  static from<T>(
    BuildContext context,
    List<TTableHeader<T>> headers,
    List<T> items, {
    TPdfTableDecoration decoration = const TPdfTableDecoration(),
  }) {
    final theme = context.theme;
    final effectiveHeaders = headers.where((header) => header.map != null || header is Map<String, dynamic> && header.value != null);
    final tHeaders = effectiveHeaders.map((header) => header.text).toList();
    final tData = items.map((item) => effectiveHeaders.map((header) => header.getValue(item)).toList()).toList();

    return TableHelper.fromTextArray(
      headers: tHeaders,
      data: tData,
      border: decoration.getBorder(theme),
      headerStyle: decoration.getHeaderStyle(theme),
      cellStyle: decoration.getCellStyle(theme),
      headerAlignment: decoration.headerAlignment,
      cellAlignment: decoration.cellAlignment,
      headerPadding: decoration.headerPadding,
      cellPadding: decoration.cellPadding,
    );
  }
}
