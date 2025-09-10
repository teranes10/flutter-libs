import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TFilePicker extends StatefulWidget
    with TInputFieldMixin, TInputValueMixin<List<TFile>>, TFocusMixin, TInputValidationMixin<List<TFile>> {
  @override
  final String? label, tag, placeholder, helperText, message;
  @override
  final bool isRequired, disabled;
  @override
  final TInputSize? size;
  @override
  final Color? color;
  @override
  final BoxDecoration? boxDecoration;
  @override
  final Widget? preWidget, postWidget;
  @override
  final List<String? Function(List<TFile>?)>? rules;
  @override
  final List<String>? errors;
  @override
  final List<TFile>? value;
  @override
  final ValueNotifier<List<TFile>>? valueNotifier;
  @override
  final ValueChanged<List<TFile>>? onValueChanged;
  @override
  final Duration? validationDebounce;
  @override
  final bool? skipValidation;
  @override
  final FocusNode? focusNode;
  @override
  final VoidCallback? onTap;

  // FileSelector specific properties
  final TFilePickerDecoration decoration;
  final bool allowMultiple;
  final List<String>? allowedExtensions;
  final int? maxFiles;
  final TFileType fileType;

  const TFilePicker({
    super.key,
    this.label,
    this.tag,
    this.placeholder = "Select files...",
    this.helperText,
    this.message,
    this.value,
    this.isRequired = false,
    this.disabled = false,
    this.size = TInputSize.md,
    this.color,
    this.boxDecoration,
    this.preWidget,
    this.postWidget,
    this.rules,
    this.errors,
    this.valueNotifier,
    this.onValueChanged,
    this.validationDebounce,
    this.skipValidation,
    this.focusNode,
    this.onTap,
    this.allowMultiple = false,
    this.maxFiles,
    this.allowedExtensions,
    this.decoration = const TFilePickerDecoration(),
    this.fileType = TFileType.any,
  });

  @override
  State<TFilePicker> createState() => _TFilePickerState();
}

class _TFilePickerState extends State<TFilePicker>
    with
        TInputFieldStateMixin<TFilePicker>,
        TInputValueStateMixin<List<TFile>, TFilePicker>,
        TFocusStateMixin<TFilePicker>,
        TInputValidationStateMixin<List<TFile>, TFilePicker> {
  @override
  void onExternalValueChanged(List<TFile>? value) {
    super.onExternalValueChanged(value);
    setState(() {});
  }

  Future<void> _pickFiles() async {
    if (widget.disabled) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: true,
        type: widget.fileType.toFilePickerType(),
        allowMultiple: widget.allowMultiple,
        allowedExtensions: widget.allowedExtensions,
      );

      if (result == null) return;

      for (final file in result.toFiles()) {
        _addFile(file);
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  void _addFile(TFile file) {
    // Check max files
    if (widget.maxFiles != null && currentValue != null && currentValue!.length >= widget.maxFiles!) return;

    //Check if file already exists (by path)
    if (currentValue?.any((f) => f == file) == true) return;

    if (widget.allowMultiple) {
      final newValue = List<TFile>.from(currentValue ?? []);
      newValue.add(file);

      setState(() => notifyValueChanged(newValue));
    } else {
      setState(() => notifyValueChanged([file]));
    }
  }

  void _removeFile(TFile file) {
    final newValue = List<TFile>.from(currentValue ?? []);
    newValue.removeWhere((f) => f == file);

    setState(() => notifyValueChanged(newValue));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final exTheme = context.exTheme;

    return GestureDetector(
      onTap: _pickFiles,
      child: buildContainer(
        theme,
        exTheme,
        isMultiline: true,
        preWidget: Icon(Icons.attach_file_rounded, size: 16, color: theme.onSurfaceVariant),
        child: Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...(currentValue ?? []).map((file) => widget.decoration.buildFileChip(theme, widget.size, file, () => _removeFile(file))),
          ],
        ),
      ),
    );
  }
}
