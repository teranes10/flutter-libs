part of 'csv_editor.dart';

/// Table headers configuration and inline editable [TTable] rendering.
mixin _TCsvEditorTable on _TCsvEditorStateContract, _TCsvEditorActions {
  void duplicateRowById(String id) {
    final index = rows.indexWhere((r) => r.id == id);
    if (index != -1) {
      duplicateRow(index);
    }
  }

  void deleteRowById(String id) {
    final index = rows.indexWhere((r) => r.id == id);
    if (index != -1) {
      deleteRow(index);
    }
  }

  List<TTableHeader<TCsvRow, String>> buildTableHeaders(ColorScheme colors) {
    return [
      // Index & Status Column
      TTableHeader<TCsvRow, String>(
        '#',
        minWidth: 55,
        maxWidth: 70,
        alignment: Alignment.center,
        builder: (ctx, item, index) {
          final hasRowError = !item.data.isValid;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${index + 1}', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
              const SizedBox(width: 4),
              if (hasRowError)
                Tooltip(
                  message: item.data.errors.values.join('\n'),
                  child: Icon(Icons.error_outline_rounded, size: 16, color: colors.error),
                )
              else
                Icon(Icons.check_circle_outline_rounded, size: 16, color: colors.primary.withValues(alpha: 0.7)),
            ],
          );
        },
      ),

      // Dynamic Schema Columns
      ...widget.columns.map((col) {
        final headerTitle = col.header + (col.isRequired ? ' *' : '');

        if (col.type == TCsvColumnType.boolean) {
          return TTableHeader<TCsvRow, String>.toggle(
            headerTitle,
            (row) => row.getValue(col.key) == true,
            (row, val) => updateCellValue(row, col, val),
            alignment: col.alignment,
            minWidth: col.minWidth,
            maxWidth: col.maxWidth,
            flex: col.flex,
          );
        }

        if (col.type == TCsvColumnType.number) {
          return TTableHeader<TCsvRow, String>.numberField(
            headerTitle,
            (row) => row.getValue(col.key) is num ? row.getValue(col.key) as num : num.tryParse(row.getValue(col.key)?.toString() ?? ''),
            (row, val) => updateCellValue(row, col, val),
            flex: col.flex,
            minWidth: col.minWidth,
            maxWidth: col.maxWidth,
            alignment: col.alignment,
            placeholder: col.placeholder ?? '—',
          );
        }

        if (col.type == TCsvColumnType.integer) {
          return TTableHeader<TCsvRow, String>.numberField(
            headerTitle,
            (row) => row.getValue(col.key) is int ? row.getValue(col.key) as int : int.tryParse(row.getValue(col.key)?.toString() ?? ''),
            (row, val) => updateCellValue(row, col, val),
            flex: col.flex,
            minWidth: col.minWidth,
            maxWidth: col.maxWidth,
            alignment: col.alignment,
            placeholder: col.placeholder ?? '—',
          );
        }

        // Text field
        return TTableHeader<TCsvRow, String>.textField(
          headerTitle,
          (row) => row.getValue(col.key)?.toString(),
          (row, val) => updateCellValue(row, col, val),
          flex: col.flex,
          minWidth: col.minWidth,
          maxWidth: col.maxWidth,
          alignment: col.alignment,
          placeholder: col.placeholder ?? '—',
        );
      }),

      // Actions Column
      if (widget.allowDeleteRow || widget.allowDuplicateRow)
        TTableHeader<TCsvRow, String>.actions(
          (item) => [
            if (widget.allowDuplicateRow)
              TButtonGroupItem(
                icon: Icons.copy_rounded,
                tooltip: 'Duplicate Row',
                onTap: () => duplicateRowById(item.data.id),
              ),
            if (widget.allowDeleteRow)
              TButtonGroupItem(
                icon: Icons.delete_outline_rounded,
                color: colors.error,
                tooltip: 'Delete Row',
                onTap: () => deleteRowById(item.data.id),
              ),
          ],
          text: 'Actions',
          minWidth: 80,
          maxWidth: 100,
        ),
    ];
  }

  Widget buildInlineTable(ColorScheme colors, bool isDark) {
    final filtered = filteredRows;

    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.table_chart_outlined, size: 48, color: colors.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                'No CSV data loaded',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Import a CSV or initialize with template columns.',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 36, color: colors.onSurfaceVariant),
            const SizedBox(height: 8),
            Text('No rows matching current filter', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
          ],
        ),
      );
    }

    return TTable<TCsvRow, String>(
      headers: buildTableHeaders(colors),
      items: filtered,
      itemKey: (row) => row.id,
      itemsPerPage: widget.itemsPerPage > 0 ? widget.itemsPerPage : null,
      shrinkWrap: true,
      dense: theme.dense,
      editable: true,
      cellErrorBuilder: (row, col) => row.errors[col],
      rowColorBuilder: (item, index) {
        if (!item.data.isValid) {
          return colors.errorContainer.withValues(alpha: 0.15);
        }
        return null;
      },
    );
  }

  List<TCsvRow> get filteredRows {
    List<TCsvRow> list = rows;

    // Filter by tab
    if (activeFilterTab == 1) {
      list = list.where((r) => r.isValid).toList();
    } else if (activeFilterTab == 2) {
      list = list.where((r) => !r.isValid).toList();
    }

    // Filter by search
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      list = list.where((r) {
        for (final val in r.values.values) {
          if (val != null && val.toString().toLowerCase().contains(query)) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    return list;
  }
}
