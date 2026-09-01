import 'package:flutter/material.dart';
import '../../configs/theme/app_colors.dart';
import '../../configs/widget-theme/widget_theme.dart';
import '../../extensions/build_context_x.dart';
import '../button/button.dart';
import '../chip/chip.dart';
import '../modal/modal_service.dart';
import 'csv_column.dart';

/// Manages mapping between expected schema columns and actual CSV headers.
class TCsvHeaderMapping {
  /// Maps each [TCsvColumn.key] to the selected CSV header name (or null if unmapped).
  final Map<String, String?> mapping;

  TCsvHeaderMapping([Map<String, String?>? initial])
      : mapping = initial != null ? Map<String, String?>.from(initial) : <String, String?>{};

  /// Creates a copy of this mapping.
  TCsvHeaderMapping clone() => TCsvHeaderMapping(mapping);

  /// Automatically generates mapping between expected columns and CSV headers.
  static TCsvHeaderMapping autoMap({
    required List<TCsvColumn> expectedColumns,
    required List<String> csvHeaders,
  }) {
    final result = <String, String?>{};
    final usedHeaders = <String>{};

    // 1. Exact match (case-insensitive)
    for (final col in expectedColumns) {
      final match = csvHeaders.firstWhere(
        (h) => !usedHeaders.contains(h) && (h.trim().toLowerCase() == col.header.trim().toLowerCase() || h.trim().toLowerCase() == col.key.trim().toLowerCase()),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        result[col.key] = match;
        usedHeaders.add(match);
      }
    }

    // 2. Normalized match (strip underscores, spaces, hyphens)
    for (final col in expectedColumns) {
      if (result[col.key] != null) continue;
      final normalizedColHeader = _normalize(col.header);
      final normalizedColKey = _normalize(col.key);

      final match = csvHeaders.firstWhere(
        (h) {
          if (usedHeaders.contains(h)) return false;
          final normalizedH = _normalize(h);
          return normalizedH == normalizedColHeader || normalizedH == normalizedColKey;
        },
        orElse: () => '',
      );

      if (match.isNotEmpty) {
        result[col.key] = match;
        usedHeaders.add(match);
      }
    }

    // 3. Alias / Synonym match
    for (final col in expectedColumns) {
      if (result[col.key] != null) continue;
      for (final alias in col.aliases) {
        final normalizedAlias = _normalize(alias);
        final match = csvHeaders.firstWhere(
          (h) => !usedHeaders.contains(h) && (_normalize(h) == normalizedAlias || h.trim().toLowerCase().contains(alias.trim().toLowerCase())),
          orElse: () => '',
        );
        if (match.isNotEmpty) {
          result[col.key] = match;
          usedHeaders.add(match);
          break;
        }
      }
    }

    // 4. Set remaining unmapped columns to null
    for (final col in expectedColumns) {
      result.putIfAbsent(col.key, () => null);
    }

    return TCsvHeaderMapping(result);
  }

  static String _normalize(String s) {
    return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// Checks if all CSV headers match the expected column headers exactly in name.
  static bool areAllHeadersIdentical(List<TCsvColumn> expectedColumns, List<String> csvHeaders) {
    if (expectedColumns.length != csvHeaders.length) return false;
    for (int i = 0; i < expectedColumns.length; i++) {
      if (expectedColumns[i].header.trim().toLowerCase() != csvHeaders[i].trim().toLowerCase() &&
          expectedColumns[i].key.trim().toLowerCase() != csvHeaders[i].trim().toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  /// Returns whether all required columns have been mapped to a CSV header.
  bool isComplete(List<TCsvColumn> expectedColumns) {
    for (final col in expectedColumns) {
      if (col.isRequired && (mapping[col.key] == null || mapping[col.key]!.isEmpty)) {
        return false;
      }
    }
    return true;
  }

  /// Returns the list of required columns that are currently unmapped.
  List<TCsvColumn> getUnmappedRequired(List<TCsvColumn> expectedColumns) {
    return expectedColumns.where((col) => col.isRequired && (mapping[col.key] == null || mapping[col.key]!.isEmpty)).toList();
  }

  /// Maps a single raw CSV row into a typed map according to this mapping.
  Map<String, dynamic> mapRow({
    required List<TCsvColumn> expectedColumns,
    required List<String> csvHeaders,
    required List<String> csvRow,
  }) {
    final rowMap = <String, dynamic>{};

    for (final col in expectedColumns) {
      final mappedHeader = mapping[col.key];
      if (mappedHeader != null && mappedHeader.isNotEmpty) {
        final headerIndex = csvHeaders.indexOf(mappedHeader);
        if (headerIndex >= 0 && headerIndex < csvRow.length) {
          final rawCell = csvRow[headerIndex];
          rowMap[col.key] = col.parseValue(rawCell);
          continue;
        }
      }
      rowMap[col.key] = col.defaultValue;
    }

    return rowMap;
  }
}

/// Modal / Widget for mapping CSV headers to expected schema columns.
class TCsvHeaderMapperModal extends StatefulWidget {
  final List<TCsvColumn> expectedColumns;
  final List<String> csvHeaders;
  final List<List<String>> sampleRows;
  final TCsvHeaderMapping initialMapping;
  final ValueChanged<TCsvHeaderMapping> onConfirm;

  const TCsvHeaderMapperModal({
    super.key,
    required this.expectedColumns,
    required this.csvHeaders,
    required this.sampleRows,
    required this.initialMapping,
    required this.onConfirm,
  });

  /// Shows the mapper dialog.
  static Future<TCsvHeaderMapping?> show(
    BuildContext context, {
    required List<TCsvColumn> expectedColumns,
    required List<String> csvHeaders,
    required List<List<String>> sampleRows,
    required TCsvHeaderMapping initialMapping,
  }) {
    return TModalService.show<TCsvHeaderMapping>(
      context,
      (mContext) => TCsvHeaderMapperModal(
        expectedColumns: expectedColumns,
        csvHeaders: csvHeaders,
        sampleRows: sampleRows,
        initialMapping: initialMapping,
        onConfirm: (mapping) {
          Navigator.of(mContext.context).pop(mapping);
        },
      ),
      width: 720,
      title: 'Map CSV Headers',
      showCloseButton: true,
    );
  }

  @override
  State<TCsvHeaderMapperModal> createState() => _TCsvHeaderMapperModalState();
}

class _TCsvHeaderMapperModalState extends State<TCsvHeaderMapperModal> {
  late TCsvHeaderMapping _currentMapping;

  @override
  void initState() {
    super.initState();
    _currentMapping = widget.initialMapping.clone();
  }

  void _autoMatch() {
    setState(() {
      _currentMapping = TCsvHeaderMapping.autoMap(
        expectedColumns: widget.expectedColumns,
        csvHeaders: widget.csvHeaders,
      );
    });
  }

  void _clearMapping() {
    setState(() {
      for (final col in widget.expectedColumns) {
        _currentMapping.mapping[col.key] = null;
      }
    });
  }

  String _getPreview(String? headerName) {
    if (headerName == null || headerName.isEmpty) return 'No preview';
    final index = widget.csvHeaders.indexOf(headerName);
    if (index == -1) return 'No preview';

    final samples = widget.sampleRows
        .take(3)
        .where((row) => index < row.length && row[index].trim().isNotEmpty)
        .map((row) => row[index])
        .toList();

    if (samples.isEmpty) return 'Empty in sample rows';
    return samples.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unmappedRequired = _currentMapping.getUnmappedRequired(widget.expectedColumns);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Instructions & Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Match each expected field to the corresponding column in your CSV file.',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
            ),
            Row(
              children: [
                TButton(
                  text: 'Auto Match',
                  icon: Icons.auto_awesome_rounded,
                  type: TButtonType.tonal,
                  size: TButtonSize.xs,
                  onPressed: (_) => _autoMatch(),
                ),
                const SizedBox(width: 8),
                TButton(
                  text: 'Clear',
                  icon: Icons.clear_all_rounded,
                  type: TButtonType.softText,
                  size: TButtonSize.xs,
                  onPressed: (_) => _clearMapping(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Unmapped required warning banner
        if (unmappedRequired.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.errorContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: colors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Required fields unmapped: ${unmappedRequired.map((c) => c.header).join(', ')}',
                    style: TextStyle(fontSize: 12, color: colors.onErrorContainer, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

        // Mapping Table / List
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.expectedColumns.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.2)),
              itemBuilder: (context, index) {
                final col = widget.expectedColumns[index];
                final selectedHeader = _currentMapping.mapping[col.key];
                final isUnmappedRequired = col.isRequired && (selectedHeader == null || selectedHeader.isEmpty);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Expected Column Info
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(col.type.icon, size: 16, color: colors.primary),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    col.header,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isUnmappedRequired ? colors.error : colors.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (col.isRequired) ...[
                                  const SizedBox(width: 6),
                                  TChip(
                                    text: 'Required',
                                    type: TVariant.tonal,
                                    color: isUnmappedRequired ? AppColors.danger : AppColors.secondary,
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Type: ${col.type.label} • Key: ${col.key}',
                              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),

                      // Middle: Arrow icon
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.arrow_forward_rounded, size: 16, color: colors.onSurfaceVariant),
                      ),

                      // Right: CSV Header Dropdown & Sample Preview
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonFormField<String?>(
                              initialValue: selectedHeader,
                              isExpanded: true,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isUnmappedRequired ? colors.error : colors.outlineVariant,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isUnmappedRequired ? colors.error : colors.outlineVariant.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              hint: Text('-- Do not import --', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('-- Do not import --', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                                ),
                                ...widget.csvHeaders.map((header) {
                                  return DropdownMenuItem<String?>(
                                    value: header,
                                    child: Text(header, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _currentMapping.mapping[col.key] = val;
                                });
                              },
                            ),
                            if (selectedHeader != null && selectedHeader.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Preview: ${_getPreview(selectedHeader)}',
                                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant, fontStyle: FontStyle.italic),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Footer Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TButton(
              text: 'Cancel',
              type: TButtonType.softText,
              onPressed: (_) => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 10),
            TButton(
              text: 'Apply Mapping',
              icon: Icons.check_circle_outline_rounded,
              type: TButtonType.solid,
              onPressed: (_) {
                widget.onConfirm(_currentMapping);
              },
            ),
          ],
        ),
      ],
    );
  }
}
