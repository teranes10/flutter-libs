import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TFilePicker extends StatefulWidget
    with TInputFieldMixin, TInputValueMixin<List<TFile>>, TFocusMixin, TInputValidationMixin<List<TFile>> {
  @override
  final String? label, tag, helperText;
  @override
  final bool isRequired, disabled;
  @override
  final TFilePickerTheme? theme;
  @override
  final VoidCallback? onTap;
  @override
  final FocusNode? focusNode;
  @override
  final List<TFile>? value;
  @override
  final ValueNotifier<List<TFile>>? valueNotifier;
  @override
  final ValueChanged<List<TFile>>? onValueChanged;
  @override
  final List<String? Function(List<TFile>?)>? rules;
  @override
  final Duration? validationDebounce;

  // FileSelector specific properties
  final String? placeholder;
  final bool autoFocus;
  final bool allowMultiple;
  final List<String>? allowedExtensions;
  final TFileType fileType;

  const TFilePicker({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.isRequired = false,
    this.disabled = false,
    this.theme,
    this.onTap,
    this.focusNode,
    this.value,
    this.valueNotifier,
    this.onValueChanged,
    this.rules,
    this.validationDebounce,
    this.placeholder,
    this.autoFocus = false,
    this.allowMultiple = false,
    this.allowedExtensions,
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
  TFilePickerTheme get wTheme => widget.theme ?? context.theme.filePickerTheme;

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
    return buildContainer(
      onTap: _pickFiles,
      isMultiline: true,
      preWidget: Icon(Icons.attach_file_rounded, size: 16, color: colors.onSurfaceVariant),
      child: Focus(
        focusNode: focusNode,
        autofocus: widget.autoFocus,
        child: Wrap(
          spacing: wTheme.tagSpacing,
          runSpacing: wTheme.tagRunSpacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if ((currentValue == null || currentValue!.isEmpty) && (widget.placeholder != null || widget.label != null))
              Text(widget.placeholder ?? widget.label ?? '', style: wTheme.getHintStyle(colors)),
            ...(currentValue ?? []).map((file) => wTheme.buildTagChip(colors, file, () => _removeFile(file))),
          ],
        ),
      ),
    );
  }
}
