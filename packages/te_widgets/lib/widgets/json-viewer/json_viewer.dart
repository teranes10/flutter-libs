import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/copy-button/copy_button.dart';

/// Interactive, collapsible JSON and map/object tree inspector for API payloads,
/// audit events, webhook logs, and database records.
class TJsonViewer extends StatefulWidget {
  /// The JSON data to inspect. Supports [Map], [List], JSON [String], or primitives.
  final dynamic data;

  /// Default expansion depth on initial load. Defaults to 2.
  final int initialDepth;

  /// Whether to show item count indicators for objects and arrays (e.g. `{ 4 }`, `[ 12 ]`).
  final bool showItemCount;

  /// Whether to show copy buttons for the entire JSON payload and individual nodes. Defaults to true.
  final bool showCopyButton;

  /// Optional search query to highlight matching keys and values.
  final String searchQuery;

  /// Indentation spacing in pixels per nesting level. Defaults to 16.0.
  final double indentPadding;

  const TJsonViewer({
    super.key,
    required this.data,
    this.initialDepth = 2,
    this.showItemCount = true,
    this.showCopyButton = true,
    this.searchQuery = '',
    this.indentPadding = 16.0,
  });

  @override
  State<TJsonViewer> createState() => _TJsonViewerState();
}

class _TJsonViewerState extends State<TJsonViewer> {
  late dynamic _parsedData;
  final Set<String> _expandedPaths = <String>{};

  @override
  void initState() {
    super.initState();
    _parseData();
    _initExpandedPaths('', _parsedData, 0);
  }

  @override
  void didUpdateWidget(covariant TJsonViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _parseData();
      _expandedPaths.clear();
      _initExpandedPaths('', _parsedData, 0);
    }
  }

  void _parseData() {
    if (widget.data is String) {
      try {
        _parsedData = jsonDecode(widget.data as String);
      } catch (_) {
        _parsedData = widget.data;
      }
    } else {
      _parsedData = widget.data;
    }
  }

  void _initExpandedPaths(String path, dynamic node, int currentDepth) {
    if (currentDepth <= widget.initialDepth) {
      _expandedPaths.add(path);
    }
    if (node is Map) {
      for (final entry in node.entries) {
        final childPath = path.isEmpty ? entry.key.toString() : '$path.${entry.key}';
        _initExpandedPaths(childPath, entry.value, currentDepth + 1);
      }
    } else if (node is List) {
      for (int i = 0; i < node.length; i++) {
        final childPath = path.isEmpty ? '[$i]' : '$path[$i]';
        _initExpandedPaths(childPath, node[i], currentDepth + 1);
      }
    }
  }

  void _toggleExpand(String path) {
    setState(() {
      if (_expandedPaths.contains(path)) {
        _expandedPaths.remove(path);
      } else {
        _expandedPaths.add(path);
      }
    });
  }

  void _expandAll() {
    setState(() {
      _collectAllPaths('', _parsedData);
    });
  }

  void _collapseAll() {
    setState(() {
      _expandedPaths.clear();
      _expandedPaths.add('');
    });
  }

  void _collectAllPaths(String path, dynamic node) {
    _expandedPaths.add(path);
    if (node is Map) {
      for (final entry in node.entries) {
        final childPath = path.isEmpty ? entry.key.toString() : '$path.${entry.key}';
        _collectAllPaths(childPath, entry.value);
      }
    } else if (node is List) {
      for (int i = 0; i < node.length; i++) {
        final childPath = path.isEmpty ? '[$i]' : '$path[$i]';
        _collectAllPaths(childPath, node[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Controls header: Expand All, Collapse All, Copy Full JSON
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Text(
                'JSON Inspector',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _expandAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text('Expand All', style: TextStyle(fontSize: 11, color: theme.colorScheme.primary)),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _collapseAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text('Collapse All', style: TextStyle(fontSize: 11, color: theme.colorScheme.primary)),
                ),
              ),
              if (widget.showCopyButton) ...[
                const SizedBox(width: 8),
                TCopyButton(
                  text: _parsedData is String ? _parsedData : const JsonEncoder.withIndent('  ').convert(_parsedData),
                  tooltip: 'Copy JSON',
                ),
              ],
            ],
          ),
        ),

        // Tree content body
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
            border: Border(
              left: BorderSide(color: theme.dividerColor),
              right: BorderSide(color: theme.dividerColor),
              bottom: BorderSide(color: theme.dividerColor),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildNode('', _parsedData, isRoot: true, isDark: isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildNode(String path, dynamic value, {bool isRoot = false, required bool isDark, String? keyName}) {
    if (value is Map) {
      return _buildMapNode(path, value, isRoot: isRoot, isDark: isDark, keyName: keyName);
    } else if (value is List) {
      return _buildListNode(path, value, isRoot: isRoot, isDark: isDark, keyName: keyName);
    } else {
      return _buildLeafNode(keyName, value, isDark: isDark);
    }
  }

  Widget _buildMapNode(String path, Map map, {bool isRoot = false, required bool isDark, String? keyName}) {
    final isExpanded = _expandedPaths.contains(path);
    final count = map.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _toggleExpand(path),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                if (keyName != null) ...[
                  _highlightText('"$keyName"', isDark ? Colors.cyan.shade300 : Colors.indigo.shade700, isBold: true),
                  const Text(': ', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                ],
                Text(
                  '{',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                ),
                if (!isExpanded && widget.showItemCount)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      ' $count keys ',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                if (!isExpanded)
                  Text(
                    '}',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                  ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(left: widget.indentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...map.entries.map((entry) {
                  final childPath = path.isEmpty ? entry.key.toString() : '$path.${entry.key}';
                  return _buildNode(childPath, entry.value, isDark: isDark, keyName: entry.key.toString());
                }),
                Text(
                  '}',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildListNode(String path, List list, {bool isRoot = false, required bool isDark, String? keyName}) {
    final isExpanded = _expandedPaths.contains(path);
    final count = list.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _toggleExpand(path),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                if (keyName != null) ...[
                  _highlightText('"$keyName"', isDark ? Colors.cyan.shade300 : Colors.indigo.shade700, isBold: true),
                  const Text(': ', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                ],
                Text(
                  '[',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                ),
                if (!isExpanded && widget.showItemCount)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      ' $count items ',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                if (!isExpanded)
                  Text(
                    ']',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                  ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(left: widget.indentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...list.asMap().entries.map((entry) {
                  final childPath = path.isEmpty ? '[${entry.key}]' : '$path[${entry.key}]';
                  return _buildNode(childPath, entry.value, isDark: isDark, keyName: '[${entry.key}]');
                }),
                Text(
                  ']',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLeafNode(String? keyName, dynamic value, {required bool isDark}) {
    Color valueColor;
    String displayValue;

    if (value == null) {
      valueColor = Colors.grey.shade500;
      displayValue = 'null';
    } else if (value is bool) {
      valueColor = isDark ? Colors.purple.shade300 : Colors.purple.shade700;
      displayValue = value.toString();
    } else if (value is num) {
      valueColor = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
      displayValue = value.toString();
    } else {
      valueColor = isDark ? Colors.green.shade300 : Colors.green.shade800;
      displayValue = '"${value.toString().replaceAll('\n', '\\n')}"';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 20), // Spacing aligned with collapse icon
          if (keyName != null) ...[
            _highlightText(
              keyName.startsWith('[') ? keyName : '"$keyName"',
              isDark ? Colors.cyan.shade300 : Colors.indigo.shade700,
              isBold: true,
            ),
            const Text(': ', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ],
          _highlightText(displayValue, valueColor),
        ],
      ),
    );
  }

  Widget _highlightText(String text, Color baseColor, {bool isBold = false}) {
    final query = widget.searchQuery.trim().toLowerCase();
    if (query.isEmpty || !text.toLowerCase().contains(query)) {
      return Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          color: baseColor,
        ),
      );
    }

    // Split and highlight search query
    final lowerText = text.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(query, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(backgroundColor: Colors.amber, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      );
      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          color: baseColor,
        ),
        children: spans,
      ),
    );
  }
}
