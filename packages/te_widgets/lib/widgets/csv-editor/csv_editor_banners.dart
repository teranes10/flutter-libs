part of 'csv_editor.dart';

/// Header actions, upload dropzone, loaded file banner, diff headers banner, and toolbar.
mixin _TCsvEditorBanners on _TCsvEditorStateContract, _TCsvEditorActions {
  Widget buildHeaderActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (widget.showDownloadTemplate)
          TButton(
            text: 'Template',
            icon: Icons.download_rounded,
            type: TButtonType.tonal,
            size: TButtonSize.xs,
            onPressed: (_) => downloadTemplate(),
          ),
        if (widget.showExport && rows.isNotEmpty)
          TButton(
            text: 'Export CSV',
            icon: Icons.file_download_outlined,
            type: TButtonType.tonal,
            size: TButtonSize.xs,
            onPressed: (_) => exportCurrentData(),
          ),
        if (rows.isNotEmpty)
          TButton(
            text: 'Clear All',
            icon: Icons.delete_outline_rounded,
            type: TButtonType.softText,
            color: AppColors.danger,
            size: TButtonSize.xs,
            onPressed: (_) => clearAllRows(),
          ),
        if (widget.onSave != null && rows.isNotEmpty)
          TButton(
            text: widget.saveButtonText,
            icon: widget.saveButtonIcon,
            type: TButtonType.solid,
            size: TButtonSize.xs,
            onPressed: handleSave,
          ),
      ],
    );
  }

  Widget buildDropzone(ColorScheme colors, bool isDark) {
    return InkWell(
      onTap: pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: theme.dropzoneHeight,
        decoration: BoxDecoration(
          color: theme.dropzoneColor ?? (isDark ? colors.surfaceContainerHigh : colors.surfaceContainerLow),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dropzoneBorderColor ?? colors.outlineVariant.withValues(alpha: 0.8),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_upload_rounded, size: 32, color: colors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                'Click or Drag & Drop CSV File here',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Supports .csv, .tsv, .txt files with comma or semicolon delimiters',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TButton(
                    text: 'Browse File',
                    icon: Icons.folder_open_rounded,
                    type: TButtonType.tonal,
                    size: TButtonSize.xs,
                    onPressed: (_) => pickFile(),
                  ),
                  if (widget.allowPaste) ...[
                    const SizedBox(width: 8),
                    TButton(
                      text: 'Paste CSV Text',
                      icon: Icons.paste_rounded,
                      type: TButtonType.softText,
                      size: TButtonSize.xs,
                      onPressed: (_) => openPasteModal(),
                    ),
                  ],
                  if (widget.allowAddRow) ...[
                    const SizedBox(width: 8),
                    TButton(
                      text: 'Add Row Manually',
                      icon: Icons.add,
                      type: TButtonType.softText,
                      size: TButtonSize.xs,
                      onPressed: (_) => addNewRow(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoadedFileBanner(ColorScheme colors, bool isDark) {
    final validCount = rows.where((r) => r.isValid).length;
    final errorCount = rows.length - validCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: TAlignedRow(
        left: [
          Icon(Icons.insert_drive_file_outlined, color: colors.primary, size: 20),
          Text(
            loadedFileName ?? 'Manual Dataset',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colors.onSurface),
          ),
          TChip(
            text: '${rows.length} rows',
            type: TVariant.tonal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          if (loadedFileSize != null)
            TChip(
              text: TFormatter.fileSize(loadedFileSize!),
              type: TVariant.tonal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
          if (errorCount > 0)
            TChip(
              text: '$errorCount invalid',
              color: AppColors.danger,
              type: TVariant.tonal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
        ],
        right: [
          if (rawCsvHeaders.isNotEmpty)
            TButton(
              text: 'Map Headers',
              icon: Icons.alt_route_rounded,
              type: TButtonType.tonal,
              size: TButtonSize.xs,
              onPressed: (_) => openMappingDialog(),
            ),
          TButton(
            text: 'Replace File',
            icon: Icons.replay_rounded,
            type: TButtonType.softText,
            size: TButtonSize.xs,
            onPressed: (_) => pickFile(),
          ),
          if (widget.allowPaste)
            TButton(
              text: 'Paste CSV',
              icon: Icons.paste_rounded,
              type: TButtonType.softText,
              size: TButtonSize.xs,
              onPressed: (_) => openPasteModal(),
            ),
        ],
      ),
    );
  }

  Widget buildDiffHeadersBanner(ColorScheme colors) {
    final mappedCount = currentMapping?.mapping.values.where((v) => v != null && v.isNotEmpty).length ?? 0;
    final totalExpected = widget.columns.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'CSV headers differ from expected schema. ($mappedCount of $totalExpected columns mapped)',
              style: TextStyle(fontSize: 12, color: colors.onPrimaryContainer, fontWeight: FontWeight.w500),
            ),
          ),
          TButton(
            text: 'Review Mapping',
            icon: Icons.tune_rounded,
            type: TButtonType.tonal,
            size: TButtonSize.xxs,
            onPressed: (_) => openMappingDialog(),
          ),
        ],
      ),
    );
  }

  Widget buildTableToolbar(ColorScheme colors) {
    final validCount = rows.where((r) => r.isValid).length;
    final errorCount = rows.length - validCount;

    return TAlignedRow(
      left: [
        if (widget.allowAddRow)
          TButton(
            text: 'Add Row',
            icon: Icons.add,
            type: TButtonType.tonal,
            size: TButtonSize.xs,
            onPressed: (_) => addNewRow(),
          ),
      ],
      right: [
        // Filter tabs
        TTabs<int>(
          inline: true,
          selectedValue: activeFilterTab,
          onTabChanged: (val) {
            setState(() {
              activeFilterTab = val;
            });
          },
          tabs: [
            TTab<int>(
              value: 0,
              text: 'All (${rows.length})',
            ),
            TTab<int>(
              value: 1,
              text: 'Valid ($validCount)',
            ),
            TTab<int>(
              value: 2,
              text: 'Errors ($errorCount)',
              isActive: errorCount > 0,
            ),
          ],
        ),
        // Search field
        SizedBox(
          width: 220,
          child: TTextField(
            theme: context.theme.textFieldTheme.copyWith(
              labelPosition: TLabelPosition.aboveField,
              decorationType: TInputDecorationType.outline,
              size: TInputSize.xs,
            ),
            placeholder: 'Search rows...',
            value: searchQuery,
            clearable: true,
            onValueChanged: (val) {
              setState(() {
                searchQuery = val ?? '';
              });
            },
          ),
        ),
      ],
    );
  }
}
