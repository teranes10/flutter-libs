import 'package:flutter/material.dart' show ColorScheme;
import 'package:te_widgets/te_widgets.dart';
import 'package:pdf/widgets.dart';

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

  TextStyle getHeaderStyle(ColorScheme colors) {
    return headerStyle ?? TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: colors.onSurfaceVariant.toPdfColor());
  }

  TextStyle getCellStyle(ColorScheme colors) {
    return cellStyle ?? TextStyle(fontWeight: FontWeight.normal, fontSize: 10, color: colors.onSurface.toPdfColor());
  }

  TableBorder getBorder(ColorScheme colors) {
    final borderSide = BorderSide(color: colors.outlineVariant.toPdfColor(), width: 0.1);
    return TableBorder(
      horizontalInside: borderSide,
      bottom: borderSide,
    );
  }
}
