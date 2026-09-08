part of 'csv_editor.dart';

/// Actions, file I/O, parsing, mapping, and mutation handlers for [_TCsvEditorState].
mixin _TCsvEditorActions on _TCsvEditorStateContract {
  // ---------------------------------------------------------------------------
  // Data Upload & Parsing
  // ---------------------------------------------------------------------------

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        if (mounted) TToastService.error(context, 'Unable to read file content.');
        return;
      }

      final content = utf8.decode(bytes, allowMalformed: true);
      processContent(content, fileName: file.name, fileSize: file.size);
    } catch (e) {
      if (mounted) TToastService.error(context, 'Error reading file: $e');
    }
  }

  void processContent(String content, {String? fileName, int? fileSize, String? delimiter}) {
    final parsed = TCsvParser.parseGeneric(content, delimiter: delimiter);
    if (parsed.isEmpty) {
      if (mounted) TToastService.warning(context, 'The file is empty.');
      return;
    }

    final headers = parsed.headers;
    final dataRows = parsed.rows;

    if (dataRows.isEmpty) {
      if (mounted) TToastService.warning(context, 'The file contains only headers and no data records.');
      return;
    }

    final areIdentical = TCsvHeaderMapping.areAllHeadersIdentical(widget.columns, headers);
    final autoMapping = TCsvHeaderMapping.autoMap(
      expectedColumns: widget.columns,
      csvHeaders: headers,
    );

    setState(() {
      loadedFileName = fileName ?? 'Uploaded File';
      loadedFileSize = fileSize;
      detectedFormat = parsed.format;
      effectiveDelimiter = parsed.delimiter ?? ',';
      rawCsvHeaders = headers;
      rawCsvRows = dataRows;
      currentMapping = autoMapping;
      hasDiffHeaders = !areIdentical;
    });

    applyMapping(autoMapping);

    if (hasDiffHeaders && widget.autoPromptMappingOnDiff && mounted) {
      // Prompt mapping dialog if headers differ
      openMappingDialog();
    } else {
      if (mounted) {
        final formatName = parsed.format.shortLabel;
        TToastService.success(context, 'Loaded ${dataRows.length} rows from $formatName file.');
      }
    }
  }

  /// Backward compatible alias for [processContent].
  void processCsvContent(String content, {String? fileName, int? fileSize}) =>
      processContent(content, fileName: fileName, fileSize: fileSize);

  void applyMapping(TCsvHeaderMapping mapping) {
    setState(() {
      currentMapping = mapping;
      rows.clear();

      for (final rawRow in rawCsvRows) {
        final mappedValues = mapping.mapRow(
          expectedColumns: widget.columns,
          csvHeaders: rawCsvHeaders,
          csvRow: rawRow,
        );

        final row = TCsvRow(values: mappedValues);
        row.validate(widget.columns);
        rows.add(row);
      }
    });

    notifyChange();
  }

  Future<void> openMappingDialog() async {
    if (rawCsvHeaders.isEmpty) return;

    final updatedMapping = await TCsvHeaderMapperModal.show(
      context,
      expectedColumns: widget.columns,
      csvHeaders: rawCsvHeaders,
      sampleRows: rawCsvRows,
      initialMapping: currentMapping ??
          TCsvHeaderMapping.autoMap(
            expectedColumns: widget.columns,
            csvHeaders: rawCsvHeaders,
          ),
    );

    if (updatedMapping != null) {
      applyMapping(updatedMapping);
      if (mounted) {
        TToastService.success(context, 'Headers mapped successfully.');
      }
    }
  }

  Future<void> openPasteModal() async {
    final textController = TextEditingController();
    final pasted = await TModalService.show<String>(
      context,
      (mContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Paste your raw CSV, TSV, Semicolon, Pipe delimited text, or JSON array below.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          TTextField(
            textController: textController,
            rows: 9,
            placeholder:
                '// CSV / Delimited Example:\nSKU,Name,Price,InStock\nSKU-1,Product 1,19.99,true\n\n// OR JSON Example:\n[\n  {"sku": "SKU-1", "name": "Product 1", "price": 19.99, "in_stock": true}\n]',
            autoFocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TButton(
                text: 'Cancel',
                type: TButtonType.softText,
                onPressed: (_) => Navigator.of(mContext.context).pop(),
              ),
              const SizedBox(width: 8),
              TButton(
                text: 'Parse Data',
                type: TButtonType.solid,
                icon: Icons.check,
                onPressed: (_) {
                  Navigator.of(mContext.context).pop(textController.text);
                },
              ),
            ],
          ),
        ],
      ),
      title: 'Paste Data (CSV / TSV / JSON)',
      width: 650,
      showCloseButton: true,
    );

    if (pasted != null && pasted.trim().isNotEmpty) {
      processContent(pasted, fileName: 'Pasted Data (${DateTime.now().hour}:${DateTime.now().minute})');
    }
  }

  // ---------------------------------------------------------------------------
  // Data Modifications
  // ---------------------------------------------------------------------------

  void addNewRow() {
    final defaultValues = <String, dynamic>{};
    for (final col in widget.columns) {
      defaultValues[col.key] = col.defaultValue;
    }

    final newRow = TCsvRow(values: defaultValues);
    newRow.validate(widget.columns);

    setState(() {
      rows.add(newRow);
    });

    notifyChange();
  }

  void duplicateRow(int index) {
    if (index < 0 || index >= rows.length) return;
    final clone = rows[index].clone();
    clone.validate(widget.columns);

    setState(() {
      rows.insert(index + 1, clone);
    });

    notifyChange();
  }

  void deleteRow(int index) {
    if (index < 0 || index >= rows.length) return;
    setState(() {
      rows.removeAt(index);
    });

    notifyChange();
  }

  void clearAllRows() {
    setState(() {
      rows.clear();
      loadedFileName = null;
      loadedFileSize = null;
      rawCsvHeaders.clear();
      rawCsvRows.clear();
      currentMapping = null;
      hasDiffHeaders = false;
      detectedFormat = widget.defaultExportFormat;
    });

    notifyChange();
  }

  void updateCellValue(TCsvRow row, TCsvColumn col, dynamic newValue) {
    final parsed = col.parseValue(newValue);
    row.setValue(col.key, parsed);
    row.validate(widget.columns);
    setState(() {});
    notifyChange();
  }

  // ---------------------------------------------------------------------------
  // Export & Template Downloads
  // ---------------------------------------------------------------------------

  Future<void> downloadTemplate({TCsvFileFormat? format, String? delimiter}) async {
    final targetFormat = format ?? widget.defaultExportFormat;
    final effectiveDelim = delimiter ?? targetFormat.delimiter ?? ',';
    final template = TCsvParser.generateTemplate(
      widget.columns,
      format: targetFormat,
      delimiter: effectiveDelim,
    );

    final bytes = utf8.encode(template);
    final ext = targetFormat.extension;
    final mime = targetFormat.mimeType;

    await FileSaver.instance.saveFile(
      name: "template_${targetFormat.shortLabel.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}",
      bytes: Uint8List.fromList(bytes),
      fileExtension: ext,
      mimeType: mime,
    );

    if (mounted) {
      TToastService.success(context, '${targetFormat.shortLabel} template downloaded.');
    }
  }

  Future<void> downloadJsonTemplate() async => downloadTemplate(format: TCsvFileFormat.json);
  Future<void> downloadCsvTemplate({String delimiter = ','}) async => downloadTemplate(format: TCsvFileFormat.csv, delimiter: delimiter);
  Future<void> downloadTsvTemplate() async => downloadTemplate(format: TCsvFileFormat.tsv, delimiter: '\t');
  Future<void> downloadSemicolonTemplate() async => downloadTemplate(format: TCsvFileFormat.semicolon, delimiter: ';');
  Future<void> downloadPipeTemplate() async => downloadTemplate(format: TCsvFileFormat.pipe, delimiter: '|');

  Future<void> exportCurrentData({TCsvFileFormat? format, String? delimiter}) async {
    if (rows.isEmpty) {
      TToastService.warning(context, 'No data to export.');
      return;
    }

    final targetFormat = format ?? widget.defaultExportFormat;
    final dataMaps = rows.map((r) => r.toMap()).toList();

    if (targetFormat == TCsvFileFormat.json) {
      await exportToJson();
      return;
    }

    final effectiveDelim = delimiter ?? targetFormat.delimiter ?? ',';
    final outputString = TCsvParser.toCsvFromMaps(
      dataMaps,
      columns: widget.columns,
      delimiter: effectiveDelim,
    );

    final bytes = utf8.encode(outputString);
    final ext = targetFormat.extension;
    final mime = targetFormat.mimeType;

    await FileSaver.instance.saveFile(
      name: "export_${targetFormat.shortLabel.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}",
      bytes: Uint8List.fromList(bytes),
      fileExtension: ext,
      mimeType: mime,
    );

    if (mounted) {
      TToastService.success(context, 'Exported ${rows.length} rows as ${targetFormat.shortLabel}.');
    }
  }

  Future<void> exportToJson({bool pretty = true}) async {
    if (rows.isEmpty) {
      TToastService.warning(context, 'No data to export.');
      return;
    }

    final dataMaps = rows.map((r) => r.toMap()).toList();
    final jsonString = TCsvParser.toJson(dataMaps, pretty: pretty);
    final bytes = utf8.encode(jsonString);

    await FileSaver.instance.saveFile(
      name: "json_export_${DateTime.now().millisecondsSinceEpoch}",
      bytes: Uint8List.fromList(bytes),
      fileExtension: "json",
      mimeType: MimeType.json,
    );

    if (mounted) {
      TToastService.success(context, 'Exported ${rows.length} records as JSON.');
    }
  }

  Future<void> exportToCsv({String delimiter = ','}) async =>
      exportCurrentData(format: TCsvFileFormat.csv, delimiter: delimiter);

  Future<void> exportToTsv() async =>
      exportCurrentData(format: TCsvFileFormat.tsv, delimiter: '\t');

  Future<void> exportToSemicolon() async =>
      exportCurrentData(format: TCsvFileFormat.semicolon, delimiter: ';');

  Future<void> exportToPipe() async =>
      exportCurrentData(format: TCsvFileFormat.pipe, delimiter: '|');

  // ---------------------------------------------------------------------------
  // Save / Upload Action
  // ---------------------------------------------------------------------------

  Future<void> handleSave(TButtonPressOptions options) async {
    if (rows.isEmpty) {
      TToastService.warning(context, 'Please add or upload data first.');
      options.stopLoading();
      return;
    }

    // Check errors
    final totalErrors = rows.where((r) => !r.isValid).length;
    if (totalErrors > 0) {
      TToastService.error(context, 'Please resolve $totalErrors validation error(s) before uploading.');
      setState(() {
        activeFilterTab = 2; // Switch to Errors tab to highlight them
      });
      options.stopLoading();
      return;
    }

    if (widget.onSave != null) {
      try {
        final data = rows.map((r) => r.toMap()).toList();
        await widget.onSave!(data);
        if (mounted) {
          TToastService.success(context, 'Successfully processed ${rows.length} records.');
        }
      } catch (e) {
        if (mounted) {
          TToastService.error(context, 'Upload failed: $e');
        }
      } finally {
        options.stopLoading();
      }
    } else {
      options.stopLoading();
    }
  }
}
