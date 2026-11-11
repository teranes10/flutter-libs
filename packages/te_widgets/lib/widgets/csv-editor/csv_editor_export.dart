part of 'csv_editor.dart';

/// Options chosen in the export dialog.
class _TCsvExportRequest {
  final bool isJson;
  final String fileName;
  final String delimiter;
  final TCsvEncoding encoding;
  final TJsonStyle jsonStyle;
  final TJsonIndent jsonIndent;
  final String wrapperKey;

  const _TCsvExportRequest({
    required this.isJson,
    required this.fileName,
    required this.delimiter,
    required this.encoding,
    required this.jsonStyle,
    required this.jsonIndent,
    required this.wrapperKey,
  });
}

/// Export dialog content: separate CSV / JSON tabs.
class _TCsvExportDialog extends StatefulWidget {
  final String initialFileName;
  final String initialDelimiter;
  final TCsvEncoding initialEncoding;
  final TJsonStyle initialJsonStyle;
  final bool startOnJson;
  final String note;
  final String actionText;
  final ValueChanged<_TCsvExportRequest> onExport;
  final VoidCallback onCancel;

  const _TCsvExportDialog({
    required this.initialFileName,
    required this.initialDelimiter,
    required this.initialEncoding,
    required this.initialJsonStyle,
    required this.startOnJson,
    required this.note,
    this.actionText = 'Export',
    required this.onExport,
    required this.onCancel,
  });

  @override
  State<_TCsvExportDialog> createState() => _TCsvExportDialogState();
}

class _TCsvExportDialogState extends State<_TCsvExportDialog> {
  static const _custom = 'custom';
  static final _delimiterItems = [...TCsvDelimiter.allCandidates, _custom];

  late bool _json = widget.startOnJson;
  late final _csvName = TextEditingController(text: widget.initialFileName);
  late final _jsonName = TextEditingController(text: widget.initialFileName);
  late final _customDelimiter =
      TextEditingController(text: TCsvDelimiter.allCandidates.contains(widget.initialDelimiter) ? '' : widget.initialDelimiter);
  late final _wrapperKey = TextEditingController(text: 'data');

  late String _delimiter = TCsvDelimiter.allCandidates.contains(widget.initialDelimiter) ? widget.initialDelimiter : _custom;
  late TCsvEncoding _encoding = widget.initialEncoding;
  late TJsonStyle _style = widget.initialJsonStyle;
  TJsonIndent _indent = TJsonIndent.two;

  @override
  void dispose() {
    _csvName.dispose();
    _jsonName.dispose();
    _customDelimiter.dispose();
    _wrapperKey.dispose();
    super.dispose();
  }

  String get _effectiveDelimiter => _delimiter == _custom ? (_customDelimiter.text.isEmpty ? ',' : _customDelimiter.text[0]) : _delimiter;

  void _submit() {
    final raw = (_json ? _jsonName : _csvName).text.trim();
    final name = raw.replaceFirst(RegExp(r'\.(csv|tsv|txt|psv|json)$', caseSensitive: false), '');
    widget.onExport(_TCsvExportRequest(
      isJson: _json,
      fileName: name.isEmpty ? 'export' : name,
      delimiter: _effectiveDelimiter,
      encoding: _encoding,
      jsonStyle: _style,
      jsonIndent: _indent,
      wrapperKey: _wrapperKey.text.trim(),
    ));
  }

  Widget _select<T>({
    required String label,
    required List<T> items,
    required T value,
    required String Function(T) text,
    required String Function(T) id,
    required ValueChanged<T> onChanged,
  }) {
    return TSelect<T, T, String>(
      label: label,
      items: items,
      value: value,
      itemText: text,
      itemKey: id,
      itemValue: (item) => item,
      filterable: false,
      onValueChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  Widget _fileName(TextEditingController c, String ext) {
    return TTextField(
      label: 'File name',
      textController: c,
      placeholder: 'export',
      postWidget: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(ext, style: TextStyle(color: context.colors.onSurfaceVariant, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _csvTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        // Always saved with a .csv extension, whatever the delimiter.
        _fileName(_csvName, '.csv'),
        _select<String>(
          label: 'Delimiter',
          items: _delimiterItems,
          value: _delimiter,
          text: (d) => d == _custom ? 'Custom…' : TCsvDelimiter.nameOf(d),
          id: (d) => d,
          onChanged: (v) => setState(() => _delimiter = v),
        ),
        if (_delimiter == _custom)
          TTextField(
            label: 'Custom delimiter',
            textController: _customDelimiter,
            placeholder: 'Single character',
            onValueChanged: (_) => setState(() {}),
          ),
        _select<TCsvEncoding>(
          label: 'Encoding',
          items: TCsvEncoding.values,
          value: _encoding,
          text: (e) => e.label,
          id: (e) => e.name,
          onChanged: (v) => setState(() => _encoding = v),
        ),
      ],
    );
  }

  Widget _jsonTab() {
    final styles = TJsonStyle.values.where((s) => s.exportable).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        _fileName(_jsonName, '.json'),
        _select<TJsonStyle>(
          label: 'Structure',
          items: styles,
          value: styles.contains(_style) ? _style : TJsonStyle.arrayOfObjects,
          text: (s) => s.label,
          id: (s) => s.name,
          onChanged: (v) => setState(() => _style = v),
        ),
        if (_style == TJsonStyle.wrapped) TTextField(label: 'Property name', textController: _wrapperKey, placeholder: 'data'),
        if (_style != TJsonStyle.lines)
          _select<TJsonIndent>(
            label: 'Formatting',
            items: TJsonIndent.values,
            value: _indent,
            text: (i) => i.label,
            id: (i) => i.name,
            onChanged: (v) => setState(() => _indent = v),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TTabs<bool>(
          inline: true,
          fill: true,
          style: TTabStyle.segmented,
          selectedValue: _json,
          onTabChanged: (v) => setState(() => _json = v),
          tabs: const [
            TTab<bool>(value: false, text: 'CSV', icon: HugeIcons.strokeRoundedTable),
            TTab<bool>(value: true, text: 'JSON', icon: HugeIcons.strokeRoundedBraces),
          ],
        ),
        const SizedBox(height: 20),
        _json ? _jsonTab() : _csvTab(),
        const SizedBox(height: 16),
        Text(widget.note, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 10,
          children: [
            TButton(text: 'Cancel', type: TButtonType.softText, onPressed: (_) => widget.onCancel()),
            TButton(
              text: 'Export',
              icon: HugeIcons.strokeRoundedDownload01,
              type: TButtonType.solid,
              onPressed: (_) => _submit(),
            ),
          ],
        ),
      ],
    );
  }
}
