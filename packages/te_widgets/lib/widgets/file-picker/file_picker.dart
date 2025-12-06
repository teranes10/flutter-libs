import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A file picker input with preview and validation.
///
/// `TFilePicker` provides file selection with:
/// - Single or multiple file selection
/// - File type filtering
/// - Extension filtering
/// - File preview with thumbnails
/// - Remove file capability
/// - Validation support
///
/// ## Basic Usage
///
/// ```dart
/// TFilePicker(
///   label: 'Upload Files',
///   allowMultiple: true,
///   onValueChanged: (files) => print('Selected: ${files?.length} files'),
/// )
/// ```
///
/// ## With File Type Filter
///
/// ```dart
/// TFilePicker(
///   label: 'Upload Images',
///   fileType: TFileType.image,
///   allowMultiple: true,
/// )
/// ```
///
/// ## With Extension Filter
///
/// ```dart
/// TFilePicker(
///   label: 'Upload Documents',
///   fileType: TFileType.custom,
///   allowedExtensions: ['pdf', 'doc', 'docx'],
/// )
/// ```
///
/// See also:
/// - [TFile] for file model
/// - [TFileType] for file type options
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
  final ValueNotifier<List<TFile>?>? valueNotifier;
  @override
  final ValueChanged<List<TFile>?>? onValueChanged;
  @override
  final List<String? Function(List<TFile>?)>? rules;
  @override
  final Duration? validationDebounce;

  /// Placeholder text when no files are selected.
  final String? placeholder;

  /// Whether to auto-focus the picker.
  final bool autoFocus;

  /// Whether to allow multiple file selection.
  final bool allowMultiple;

  /// Allowed file extensions (without dots).
  final List<String>? allowedExtensions;

  /// The type of files to allow.
  final TFileType fileType;

  /// Creates a file picker.
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
        child: wTheme.buildFilesField(
          states: states,
          files: currentValue ?? [],
          placeholder: widget.placeholder ?? widget.label,
          onRemove: (file) => _removeFile(file),
        ),
      ),
    );
  }
}
