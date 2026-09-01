import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

part 'csv_editor_actions.dart';
part 'csv_editor_banners.dart';
part 'csv_editor_table.dart';

/// A rich, interactive CSV upload, header mapping, and inline-editable data table.
///
/// `TCsvEditor` provides an all-in-one solution for CSV management:
/// - **File upload**: Drag & drop or browse `.csv`, `.tsv`, `.txt` files, or paste raw CSV text.
/// - **Header mapping**: Automatically matches CSV headers to expected schema columns,
///   with interactive visual re-mapping for mismatched column names.
/// - **Inline editing**: Type-aware table cells:
///   - Text: [TTextField]
///   - Number / Integer: [TNumberField]
///   - Boolean: [TSwitch] toggle via [TTableHeader.toggle]
/// - **Validation**: Real-time cell & row error detection (required fields, number parsing, custom rules).
/// - **Actions**: Add/delete/duplicate rows, download CSV starter template, export edited data to CSV,
///   and execute upload/save callbacks.
///
/// ## Basic Usage
/// ```dart
/// TCsvEditor(
///   title: 'Import Inventory',
///   columns: [
///     TCsvColumn.text(key: 'name', header: 'Product Name', isRequired: true),
///     TCsvColumn.number(key: 'price', header: 'Price (\$)', isRequired: true),
///     TCsvColumn.integer(key: 'stock', header: 'Stock Qty', defaultValue: 0),
///     TCsvColumn.boolean(key: 'active', header: 'Active / Available', defaultValue: true),
///   ],
///   onSave: (data) async {
///     print('Uploaded rows: ${data.length}');
///   },
/// )
/// ```
class TCsvEditor extends StatefulWidget {
  /// The schema of expected columns for the CSV data.
  final List<TCsvColumn> columns;

  /// Initial rows to populate the table (optional).
  final List<Map<String, dynamic>>? initialData;

  /// Callback fired when the user clicks the primary Save / Upload button.
  final Future<void> Function(List<Map<String, dynamic>> data)? onSave;

  /// Callback fired whenever the data in the table changes.
  final ValueChanged<List<Map<String, dynamic>>>? onDataChanged;

  /// Title displayed in the editor card header.
  final String? title;

  /// Subtitle or instruction text.
  final String? subtitle;

  /// Label for the primary save/upload button.
  final String saveButtonText;

  /// Icon for the primary save/upload button.
  final IconData saveButtonIcon;

  /// Whether to show the Download Template button.
  final bool showDownloadTemplate;

  /// Whether to show the Export CSV button.
  final bool showExport;

  /// Whether to allow adding new rows manually.
  final bool allowAddRow;

  /// Whether to allow deleting rows.
  final bool allowDeleteRow;

  /// Whether to allow duplicating rows.
  final bool allowDuplicateRow;

  /// Whether to allow raw CSV pasting.
  final bool allowPaste;

  /// Whether to automatically prompt the header mapping dialog when uploaded CSV headers differ.
  final bool autoPromptMappingOnDiff;

  /// Theme configuration for the editor.
  final TCsvEditorTheme? theme;

  /// Items per page for pagination (0 or null for all items in a scrollable view).
  final int itemsPerPage;

  const TCsvEditor({
    super.key,
    required this.columns,
    this.initialData,
    this.onSave,
    this.onDataChanged,
    this.title = 'CSV Data Editor',
    this.subtitle = 'Upload a CSV file or add rows manually to review and edit data.',
    this.saveButtonText = 'Upload Data',
    this.saveButtonIcon = Icons.cloud_upload_outlined,
    this.showDownloadTemplate = true,
    this.showExport = true,
    this.allowAddRow = true,
    this.allowDeleteRow = true,
    this.allowDuplicateRow = true,
    this.allowPaste = true,
    this.autoPromptMappingOnDiff = true,
    this.theme,
    this.itemsPerPage = 20,
  });

  @override
  State<TCsvEditor> createState() => _TCsvEditorState();
}

/// Abstract contract for state sharing across mixins.
abstract class _TCsvEditorStateContract extends State<TCsvEditor> {
  List<TCsvRow> get rows;
  String? get loadedFileName;
  set loadedFileName(String? val);
  int? get loadedFileSize;
  set loadedFileSize(int? val);
  List<String> get rawCsvHeaders;
  set rawCsvHeaders(List<String> val);
  List<List<String>> get rawCsvRows;
  set rawCsvRows(List<List<String>> val);
  TCsvHeaderMapping? get currentMapping;
  set currentMapping(TCsvHeaderMapping? val);
  bool get hasDiffHeaders;
  set hasDiffHeaders(bool val);
  String get searchQuery;
  set searchQuery(String val);
  int get activeFilterTab;
  set activeFilterTab(int val);
  TCsvEditorTheme get theme;
  void notifyChange();
}

class _TCsvEditorState extends _TCsvEditorStateContract with _TCsvEditorActions, _TCsvEditorBanners, _TCsvEditorTable {
  @override
  final List<TCsvRow> rows = [];

  @override
  String? loadedFileName;

  @override
  int? loadedFileSize;

  @override
  List<String> rawCsvHeaders = [];

  @override
  List<List<String>> rawCsvRows = [];

  @override
  TCsvHeaderMapping? currentMapping;

  @override
  bool hasDiffHeaders = false;

  @override
  String searchQuery = '';

  @override
  int activeFilterTab = 0; // 0: All, 1: Valid, 2: Errors

  @override
  TCsvEditorTheme get theme => widget.theme ?? const TCsvEditorTheme();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      for (final map in widget.initialData!) {
        final row = TCsvRow(values: map);
        row.validate(widget.columns);
        rows.add(row);
      }
    }
  }

  @override
  void notifyChange() {
    widget.onDataChanged?.call(rows.map((r) => r.toMap()).toList());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return TCard(
      title: widget.title,
      subtitle: widget.subtitle,
      icon: Icons.table_chart_outlined,
      padding: theme.padding,
      trailing: buildHeaderActions(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Upload Dropzone / Loaded File Banner
          if (rows.isEmpty) buildDropzone(colors, isDark) else buildLoadedFileBanner(colors, isDark),

          // 2. Diff Headers Banner
          if (hasDiffHeaders && rows.isNotEmpty) ...[
            const SizedBox(height: 12),
            buildDiffHeadersBanner(colors),
          ],

          // 3. Table Toolbar (Search, Filter Tabs, Add Row, Row Count)
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 16),
            buildTableToolbar(colors),
            const SizedBox(height: 12),
            buildInlineTable(colors, isDark),
          ],
        ],
      ),
    );
  }
}
