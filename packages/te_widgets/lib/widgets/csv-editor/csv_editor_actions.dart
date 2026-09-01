part of 'csv_editor.dart';

/// Actions, file I/O, parsing, mapping, and mutation handlers for [_TCsvEditorState].
mixin _TCsvEditorActions on _TCsvEditorStateContract {
  // ---------------------------------------------------------------------------
  // CSV Upload & Parsing
  // ---------------------------------------------------------------------------

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'tsv', 'txt'],
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
      processCsvContent(content, fileName: file.name, fileSize: file.size);
    } catch (e) {
      if (mounted) TToastService.error(context, 'Error reading CSV file: $e');
    }
  }

  void processCsvContent(String content, {String? fileName, int? fileSize}) {
    final parsed = TCsvParser.parse(content);
    if (parsed.isEmpty) {
      if (mounted) TToastService.warning(context, 'The CSV file is empty.');
      return;
    }

    final headers = parsed.first;
    final dataRows = parsed.skip(1).toList();

    if (dataRows.isEmpty) {
      if (mounted) TToastService.warning(context, 'The CSV file contains only headers and no data rows.');
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
        TToastService.success(context, 'Loaded ${dataRows.length} rows from ${fileName ?? "CSV"}.');
      }
    }
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
    final pasted = await TModalService.show<String>(
      context,
      (mContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Paste your raw CSV / TSV text below including header row.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          TTextField(
            textController: textController,
            rows: 8,
            placeholder: 'Name,Price,InStock\nItem 1,19.99,true\nItem 2,24.50,false',
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
      title: 'Paste Raw CSV Text',
      width: 600,
      showCloseButton: true,
    );

    if (pasted != null && pasted.trim().isNotEmpty) {
      processCsvContent(pasted, fileName: 'Pasted Data (${DateTime.now().hour}:${DateTime.now().minute})');
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

  Future<void> downloadTemplate() async {
    final template = TCsvParser.generateTemplate(widget.columns);
    final bytes = utf8.encode(template);

    await FileSaver.instance.saveFile(
      name: "template_${DateTime.now().millisecondsSinceEpoch}",
      bytes: Uint8List.fromList(bytes),
      fileExtension: "csv",
      mimeType: MimeType.csv,
    );

    if (mounted) {
      TToastService.success(context, 'Template downloaded.');
    }
  }

  Future<void> exportCurrentData() async {
    if (rows.isEmpty) {
      TToastService.warning(context, 'No data to export.');
      return;
    }

    final headers = widget.columns.map((c) => c.header).toList();
    final dataRows = rows.map((row) {
      return widget.columns.map((c) => c.formatValue(row.getValue(c.key))).toList();
    }).toList();

    final csvString = TCsvParser.toCsv(headers, dataRows);
    final bytes = utf8.encode(csvString);

    await FileSaver.instance.saveFile(
      name: "csv_export_${DateTime.now().millisecondsSinceEpoch}",
      bytes: Uint8List.fromList(bytes),
      fileExtension: "csv",
      mimeType: MimeType.csv,
    );

    if (mounted) {
      TToastService.success(context, 'Exported ${rows.length} rows to CSV.');
    }
  }

  // ---------------------------------------------------------------------------
  // Save / Upload Action
  // ---------------------------------------------------------------------------

  Future<void> handleSave(TButtonPressOptions options) async {
    if (rows.isEmpty) {
      TToastService.warning(context, 'Please add or upload CSV data first.');
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
