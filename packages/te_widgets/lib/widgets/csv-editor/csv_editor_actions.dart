part of 'csv_editor.dart';

/// Actions, file I/O, parsing, mapping, and mutation handlers for [_TCsvEditorState].
mixin _TCsvEditorActions on _TCsvEditorStateContract {
  // ---------------------------------------------------------------------------
  // Data Upload & Parsing
  // ---------------------------------------------------------------------------

  Future<void> pickFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
      );
      if (file == null) return;

      setState(() {
        isLoading = true;
        loadingFileName = file.name;
      });
      final bytes = await file.readAsBytes();
      await loadBytes(bytes, fileName: file.name);
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        TToastService.error(context, 'Error reading file: $e');
      }
    }
  }

  void _setProgress(double value) {
    if (mounted) setState(() => loadProgress = value.clamp(0.0, 1.0));
  }

  /// Decodes [bytes] (encoding auto-detected) and loads them as CSV / JSON.
  Future<void> loadBytes(Uint8List bytes, {String? fileName}) async {
    setState(() {
      isLoading = true;
      loadProgress = 0;
      loadingFileName = fileName;
    });
    try {
      // Let the progress state paint before the work starts.
      await WidgetsBinding.instance.endOfFrame;
      final decoded = TCsvEncoding.decode(bytes);
      await _loadText(decoded.text, fileName: fileName, fileSize: bytes.length, encoding: decoded.encoding);
    } catch (e) {
      if (mounted) TToastService.error(context, 'Could not read file: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Loads raw text (e.g. pasted data) as CSV / JSON.
  Future<void> processContent(String content, {String? fileName, int? fileSize, String? delimiter, TCsvEncoding? encoding}) async {
    setState(() {
      isLoading = true;
      loadProgress = 0;
      loadingFileName = fileName;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await _loadText(content, fileName: fileName, fileSize: fileSize, delimiter: delimiter, encoding: encoding);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Parses in time slices (so the progress bar keeps moving, also on web where
  /// isolates aren't available) and then builds the table rows the same way.
  Future<void> _loadText(String content, {String? fileName, int? fileSize, String? delimiter, TCsvEncoding? encoding}) async {
    final parsed = await TCsvParser.parseGenericAsync(content, delimiter: delimiter, onProgress: (p) => _setProgress(p * 0.6));
    if (!mounted) return;
    await applyParsed(parsed, fileName: fileName, fileSize: fileSize, encoding: encoding);
  }

  /// Backward compatible alias for [processContent].
  Future<void> processCsvContent(String content, {String? fileName, int? fileSize}) =>
      processContent(content, fileName: fileName, fileSize: fileSize);

  Future<void> applyParsed(TCsvParseResult parsed, {String? fileName, int? fileSize, TCsvEncoding? encoding}) async {
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
      detectedEncoding = encoding ?? TCsvEncoding.utf8;
      detectedJsonStyle = parsed.jsonStyle;
      rawCsvHeaders = headers;
      rawCsvRows = dataRows;
      currentMapping = autoMapping;
      hasDiffHeaders = !areIdentical;
    });

    await applyMappingAsync(autoMapping, onProgress: (p) => _setProgress(0.6 + 0.4 * p));
    if (!mounted) return;

    if (hasDiffHeaders && widget.autoPromptMappingOnDiff && mounted) {
      // Prompt mapping dialog if headers differ
      unawaited(openMappingDialog());
    } else {
      if (mounted) {
        final detail = parsed.format == TCsvFileFormat.json
            ? 'JSON, ${parsed.jsonStyle?.label.toLowerCase()}'
            : '${parsed.format == TCsvFileFormat.custom ? 'delimiter "${parsed.delimiter}"' : parsed.format.shortLabel}, ${detectedEncoding.label}';
        TToastService.success(context, 'Loaded ${dataRows.length} rows ($detail).');
      }
    }
  }

  Future<void> applyMappingAsync(TCsvHeaderMapping mapping, {void Function(double progress)? onProgress}) async {
    final built = <TCsvRow>[];
    final total = rawCsvRows.length;
    final watch = Stopwatch()..start();

    for (var i = 0; i < total; i++) {
      final row = TCsvRow(
        values: mapping.mapRow(expectedColumns: widget.columns, csvHeaders: rawCsvHeaders, csvRow: rawCsvRows[i]),
      );
      row.validate(widget.columns);
      built.add(row);

      if (watch.elapsedMilliseconds >= 10) {
        onProgress?.call(i / total);
        await Future<void>.delayed(const Duration(milliseconds: 1));
        watch.reset();
      }
    }
    if (!mounted) return;

    setState(() {
      currentMapping = mapping;
      rows
        ..clear()
        ..addAll(built);
    });
    notifyChange();
  }

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
    final pasted = await TModalService.showAdaptive<String>(
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
                icon: HugeIcons.strokeRoundedTick01,
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
      await processContent(pasted, fileName: 'Pasted Data (${DateTime.now().hour}:${DateTime.now().minute})');
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

  Future<void> openTemplateDialog() async {
    final request = await TModalService.showAdaptive<_TCsvExportRequest>(
      context,
      (mContext) => _TCsvExportDialog(
        initialFileName: 'template',
        initialDelimiter: ',',
        initialEncoding: TCsvEncoding.utf8,
        initialJsonStyle: TJsonStyle.arrayOfObjects,
        startOnJson: widget.defaultExportFormat == TCsvFileFormat.json,
        note: 'Includes the expected columns and one sample row.',
        actionText: 'Download',
        onExport: (r) => Navigator.of(mContext.context).pop(r),
        onCancel: () => Navigator.of(mContext.context).pop(),
      ),
      title: 'Download Template',
      width: 480,
      showCloseButton: true,
    );
    if (request != null) await downloadTemplate(request);
  }

  Future<void> downloadTemplate(_TCsvExportRequest r) async {
    final text = TCsvParser.generateTemplate(
      widget.columns,
      format: r.isJson ? TCsvFileFormat.json : TCsvFileFormat.csv,
      delimiter: r.delimiter,
      jsonStyle: r.jsonStyle,
      jsonIndent: r.jsonIndent,
      wrapperKey: r.wrapperKey,
    );

    await FileSaver.instance.saveFile(
      name: r.fileName,
      bytes: (r.isJson ? TCsvEncoding.utf8 : r.encoding).encode(text),
      fileExtension: r.isJson ? 'json' : 'csv',
      mimeType: r.isJson ? MimeType.json : MimeType.csv,
    );

    if (mounted) TToastService.success(context, '${r.isJson ? 'JSON' : 'CSV'} template downloaded.');
  }

  Future<void> openExportDialog() async {
    if (rows.isEmpty) {
      TToastService.warning(context, 'No data to export.');
      return;
    }

    final baseName = (loadedFileName ?? 'export').replaceFirst(RegExp(r'\.[A-Za-z0-9]{1,5}$'), '');
    final style = detectedJsonStyle != null && detectedJsonStyle!.exportable ? detectedJsonStyle! : TJsonStyle.arrayOfObjects;

    final request = await TModalService.showAdaptive<_TCsvExportRequest>(
      context,
      (mContext) => _TCsvExportDialog(
        initialFileName: baseName,
        initialDelimiter: effectiveDelimiter,
        initialEncoding: detectedEncoding,
        initialJsonStyle: style,
        startOnJson: detectedFormat == TCsvFileFormat.json,
        note: '${rows.length} rows will be exported.',
        onExport: (r) => Navigator.of(mContext.context).pop(r),
        onCancel: () => Navigator.of(mContext.context).pop(),
      ),
      title: 'Export Data',
      width: 480,
      showCloseButton: true,
    );

    if (request == null) return;
    request.isJson ? await exportJson(request) : await exportCsv(request);
  }

  Future<void> exportCsv(_TCsvExportRequest r) async {
    final text = TCsvParser.toCsvFromMaps(
      rows.map((row) => row.toMap()).toList(),
      columns: widget.columns,
      delimiter: r.delimiter,
    );

    // Always saved with a .csv extension, whatever the delimiter.
    await FileSaver.instance.saveFile(
      name: r.fileName,
      bytes: r.encoding.encode(text),
      fileExtension: 'csv',
      mimeType: MimeType.csv,
    );

    if (mounted) TToastService.success(context, 'Exported ${rows.length} rows as CSV (${r.encoding.label}).');
  }

  Future<void> exportJson(_TCsvExportRequest r) async {
    final text = TCsvParser.toJsonStyled(
      rows.map((row) => row.toMap()).toList(),
      style: r.jsonStyle,
      indent: r.jsonIndent,
      wrapperKey: r.wrapperKey,
      keys: widget.columns.map((c) => c.key).toList(),
    );

    await FileSaver.instance.saveFile(
      name: r.fileName,
      bytes: TCsvEncoding.utf8.encode(text),
      fileExtension: 'json',
      mimeType: MimeType.json,
    );

    if (mounted) TToastService.success(context, 'Exported ${rows.length} records as JSON.');
  }

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
        await uploadAndReplaceImageUrls();
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
