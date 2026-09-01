import 'package:flutter/material.dart';

/// Theme configuration for [TCsvEditor].
class TCsvEditorTheme {
  /// Padding around the editor container.
  final EdgeInsetsGeometry padding;

  /// Maximum height of the data table area.
  final double? tableMaxHeight;

  /// Height of the dropzone file input area.
  final double dropzoneHeight;

  /// Whether the inline table cells should use compact/dense padding.
  final bool dense;

  /// Custom background color for the dropzone upload area.
  final Color? dropzoneColor;

  /// Custom border color for the dropzone upload area.
  final Color? dropzoneBorderColor;

  const TCsvEditorTheme({
    this.padding = const EdgeInsets.all(16),
    this.tableMaxHeight,
    this.dropzoneHeight = 160,
    this.dense = true,
    this.dropzoneColor,
    this.dropzoneBorderColor,
  });

  TCsvEditorTheme copyWith({
    EdgeInsetsGeometry? padding,
    double? tableMaxHeight,
    double? dropzoneHeight,
    bool? dense,
    Color? dropzoneColor,
    Color? dropzoneBorderColor,
  }) {
    return TCsvEditorTheme(
      padding: padding ?? this.padding,
      tableMaxHeight: tableMaxHeight ?? this.tableMaxHeight,
      dropzoneHeight: dropzoneHeight ?? this.dropzoneHeight,
      dense: dense ?? this.dense,
      dropzoneColor: dropzoneColor ?? this.dropzoneColor,
      dropzoneBorderColor: dropzoneBorderColor ?? this.dropzoneBorderColor,
    );
  }
}
