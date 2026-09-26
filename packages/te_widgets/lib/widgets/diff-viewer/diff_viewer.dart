import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/badge/badge.dart';

/// The visual presentation mode for [TDiffViewer].
enum TDiffViewMode {
  /// Old and new text are displayed side by side in two aligned columns.
  sideBySide,

  /// Old and new text are merged into a single unified chronological flow.
  inline,
}

/// The status of a line diff.
enum TDiffLineType {
  unchanged,
  added,
  deleted,
}

/// A line in a diff comparison.
class TDiffLine {
  final String text;
  final TDiffLineType type;
  final int? oldLineNumber;
  final int? newLineNumber;

  const TDiffLine({
    required this.text,
    required this.type,
    this.oldLineNumber,
    this.newLineNumber,
  });
}

/// A line-by-line text and code difference viewer for audit logs, version histories,
/// database record comparisons, and config revisions.
class TDiffViewer extends StatefulWidget {
  /// The original / baseline text.
  final String oldText;

  /// The revised / updated text.
  final String newText;

  /// Optional title for the original text column. Defaults to "Original".
  final String oldTitle;

  /// Optional title for the revised text column. Defaults to "Modified".
  final String newTitle;

  /// The diff display mode: [TDiffViewMode.sideBySide] or [TDiffViewMode.inline]. Defaults to sideBySide.
  final TDiffViewMode mode;

  /// Whether to render line numbers. Defaults to true.
  final bool showLineNumbers;

  /// Text style for diff lines. Monospace is used by default.
  final TextStyle? textStyle;

  const TDiffViewer({
    super.key,
    required this.oldText,
    required this.newText,
    this.oldTitle = 'Original',
    this.newTitle = 'Modified',
    this.mode = TDiffViewMode.sideBySide,
    this.showLineNumbers = true,
    this.textStyle,
  });

  @override
  State<TDiffViewer> createState() => _TDiffViewerState();
}

class _TDiffViewerState extends State<TDiffViewer> {
  late TDiffViewMode _activeMode;
  late List<TDiffLine> _unifiedLines;
  late List<_SideBySideRow> _sideBySideRows;
  int _additions = 0;
  int _deletions = 0;

  @override
  void initState() {
    super.initState();
    _activeMode = widget.mode;
    _computeDiff();
  }

  @override
  void didUpdateWidget(covariant TDiffViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.oldText != oldWidget.oldText || widget.newText != oldWidget.newText) {
      _computeDiff();
    }
    if (widget.mode != oldWidget.mode) {
      _activeMode = widget.mode;
    }
  }

  void _computeDiff() {
    final oldLines = widget.oldText.split('\n');
    final newLines = widget.newText.split('\n');

    final lcs = _computeLcs(oldLines, newLines);

    _unifiedLines = [];
    _sideBySideRows = [];
    _additions = 0;
    _deletions = 0;

    int oldIdx = 0;
    int newIdx = 0;
    int lcsIdx = 0;

    int oldLineNum = 1;
    int newLineNum = 1;

    while (oldIdx < oldLines.length || newIdx < newLines.length) {
      if (lcsIdx < lcs.length &&
          oldIdx < oldLines.length &&
          newIdx < newLines.length &&
          oldLines[oldIdx] == lcs[lcsIdx] &&
          newLines[newIdx] == lcs[lcsIdx]) {
        // Unchanged line
        final line = TDiffLine(
          text: oldLines[oldIdx],
          type: TDiffLineType.unchanged,
          oldLineNumber: oldLineNum++,
          newLineNumber: newLineNum++,
        );
        _unifiedLines.add(line);
        _sideBySideRows.add(_SideBySideRow(left: line, right: line));
        oldIdx++;
        newIdx++;
        lcsIdx++;
      } else {
        // Process deletions from old
        while (oldIdx < oldLines.length && (lcsIdx >= lcs.length || oldLines[oldIdx] != lcs[lcsIdx])) {
          final delLine = TDiffLine(
            text: oldLines[oldIdx],
            type: TDiffLineType.deleted,
            oldLineNumber: oldLineNum++,
          );
          _unifiedLines.add(delLine);
          _deletions++;

          // Check if there is an adjacent addition for side-by-side row pairing
          if (newIdx < newLines.length && (lcsIdx >= lcs.length || newLines[newIdx] != lcs[lcsIdx])) {
            final addLine = TDiffLine(
              text: newLines[newIdx],
              type: TDiffLineType.added,
              newLineNumber: newLineNum++,
            );
            _unifiedLines.add(addLine);
            _additions++;
            _sideBySideRows.add(_SideBySideRow(left: delLine, right: addLine));
            newIdx++;
          } else {
            _sideBySideRows.add(_SideBySideRow(left: delLine, right: null));
          }
          oldIdx++;
        }

        // Process additions from new
        while (newIdx < newLines.length && (lcsIdx >= lcs.length || newLines[newIdx] != lcs[lcsIdx])) {
          final addLine = TDiffLine(
            text: newLines[newIdx],
            type: TDiffLineType.added,
            newLineNumber: newLineNum++,
          );
          _unifiedLines.add(addLine);
          _additions++;
          _sideBySideRows.add(_SideBySideRow(left: null, right: addLine));
          newIdx++;
        }
      }
    }
  }

  List<String> _computeLcs(List<String> a, List<String> b) {
    final m = a.length;
    final n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = math.max(dp[i - 1][j], dp[i][j - 1]);
        }
      }
    }

    final result = <String>[];
    int i = m;
    int j = n;
    while (i > 0 && j > 0) {
      if (a[i - 1] == b[j - 1]) {
        result.add(a[i - 1]);
        i--;
        j--;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }

    return result.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            child: Row(
              children: [
                const Icon(Icons.difference_outlined, size: 16),
                const SizedBox(width: 8),
                Text(
                  _activeMode == TDiffViewMode.sideBySide
                      ? '${widget.oldTitle} ⟷ ${widget.newTitle}'
                      : 'Unified Diff (${widget.oldTitle} → ${widget.newTitle})',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const Spacer(),
                // Additions / Deletions count badges
                TBadge.standalone(
                  label: '+$_additions',
                  color: Colors.green.shade700,
                  textColor: Colors.white,
                ),
                const SizedBox(width: 6),
                TBadge.standalone(
                  label: '-$_deletions',
                  color: Colors.red.shade700,
                  textColor: Colors.white,
                ),
                const SizedBox(width: 14),
                // Mode switcher
                SegmentedButton<TDiffViewMode>(
                  segments: const [
                    ButtonSegment(
                      value: TDiffViewMode.sideBySide,
                      label: Text('Split', style: TextStyle(fontSize: 11)),
                    ),
                    ButtonSegment(
                      value: TDiffViewMode.inline,
                      label: Text('Unified', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                  selected: {_activeMode},
                  onSelectionChanged: (val) => setState(() => _activeMode = val.first),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Diff Canvas
          Expanded(
            child: _activeMode == TDiffViewMode.sideBySide
                ? _buildSideBySideView(theme, isDark, colors)
                : _buildInlineView(theme, isDark, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBySideView(ThemeData theme, bool isDark, ColorScheme colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 800,
        child: ListView.builder(
          itemCount: _sideBySideRows.length,
          itemBuilder: (context, index) {
            final row = _sideBySideRows[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildLineCell(row.left, isDark, isLeft: true)),
                Container(width: 1, color: theme.dividerColor),
                Expanded(child: _buildLineCell(row.right, isDark, isLeft: false)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInlineView(ThemeData theme, bool isDark, ColorScheme colors) {
    return ListView.builder(
      itemCount: _unifiedLines.length,
      itemBuilder: (context, index) {
        final line = _unifiedLines[index];
        return _buildUnifiedLineRow(line, isDark);
      },
    );
  }

  Widget _buildLineCell(TDiffLine? line, bool isDark, {required bool isLeft}) {
    if (line == null) {
      return Container(
        height: 24,
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.shade100,
      );
    }

    final isDeleted = line.type == TDiffLineType.deleted;
    final isAdded = line.type == TDiffLineType.added;

    Color? bgColor;
    if (isDeleted) {
      bgColor = isDark ? Colors.red.withValues(alpha: 0.18) : Colors.red.withValues(alpha: 0.08);
    } else if (isAdded) {
      bgColor = isDark ? Colors.green.withValues(alpha: 0.18) : Colors.green.withValues(alpha: 0.08);
    }

    final lineNum = isLeft ? line.oldLineNumber : line.newLineNumber;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLineNumbers)
            SizedBox(
              width: 36,
              child: Text(
                lineNum?.toString() ?? '',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            isDeleted ? '-' : (isAdded ? '+' : ' '),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDeleted ? Colors.red : (isAdded ? Colors.green : Colors.transparent),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              line.text,
              style: (widget.textStyle ??
                  TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade900,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedLineRow(TDiffLine line, bool isDark) {
    final isDeleted = line.type == TDiffLineType.deleted;
    final isAdded = line.type == TDiffLineType.added;

    Color? bgColor;
    if (isDeleted) {
      bgColor = isDark ? Colors.red.withValues(alpha: 0.18) : Colors.red.withValues(alpha: 0.08);
    } else if (isAdded) {
      bgColor = isDark ? Colors.green.withValues(alpha: 0.18) : Colors.green.withValues(alpha: 0.08);
    }

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLineNumbers) ...[
            SizedBox(
              width: 34,
              child: Text(
                line.oldLineNumber?.toString() ?? '',
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 34,
              child: Text(
                line.newLineNumber?.toString() ?? '',
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            isDeleted ? '-' : (isAdded ? '+' : ' '),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDeleted ? Colors.red : (isAdded ? Colors.green : Colors.transparent),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              line.text,
              style: (widget.textStyle ??
                  TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade900,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideBySideRow {
  final TDiffLine? left;
  final TDiffLine? right;

  const _SideBySideRow({this.left, this.right});
}
