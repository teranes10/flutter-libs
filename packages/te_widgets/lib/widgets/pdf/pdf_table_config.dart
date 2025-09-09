import 'package:flutter/material.dart' show ColorScheme;
import 'package:pdf/widgets.dart';
import 'package:te_widgets/widgets/pdf/pdf_config.dart';

class TPdfTableDecoration {
  final TextStyle? headerStyle;
  final TextStyle? cellStyle;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry cellPadding;
  final AlignmentGeometry headerAlignment;
  final AlignmentGeometry cellAlignment;
  final TableBorder? border;

  const TPdfTableDecoration({
    this.headerStyle,
    this.cellStyle,
    this.headerPadding = const EdgeInsets.symmetric(vertical: 7.5, horizontal: 7.5),
    this.cellPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 7.5),
    this.headerAlignment = Alignment.topLeft,
    this.cellAlignment = Alignment.topLeft,
    this.border,
  });

  TextStyle getHeaderStyle(ColorScheme theme) {
    return headerStyle ?? TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: theme.onSurfaceVariant.toPdfColor());
  }

  TextStyle getCellStyle(ColorScheme theme) {
    return cellStyle ?? TextStyle(fontWeight: FontWeight.normal, fontSize: 10, color: theme.onSurface.toPdfColor());
  }

  TableBorder getBorder(ColorScheme theme) {
    final borderSide = BorderSide(color: theme.outlineVariant.toPdfColor(), width: 0.1);
    return TableBorder(
      horizontalInside: borderSide,
      bottom: borderSide,
    );
  }
}
