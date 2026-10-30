import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:te_widgets/te_widgets.dart';

/// Where a [TFilePicker] gets its files from.
enum TFilePickerSource {
  /// The system file / gallery browser (default).
  files,

  /// Opens the camera directly and returns the captured photo
  /// (proof of delivery, damage evidence...).
  camera,

  /// Asks the user to choose between the camera and the file browser.
  filesOrCamera,
}

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
  final String? label, tag, helperText, info;
  @override
  final bool isRequired, disabled;
  @override
  final bool clearable;
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

  /// Whether to display selected files in gallery mode (100x100 TImage thumbnails with hover overlay).
  final bool isGalleryMode;

  /// Where files come from. Defaults to [TFilePickerSource.files].
  ///
  /// With [TFilePickerSource.camera] / [TFilePickerSource.filesOrCamera] a
  /// photo is captured with the device camera and downscaled to
  /// [maxImageDimension] / [imageQuality] before it is added.
  final TFilePickerSource source;

  /// Longest side (px) a captured photo is downscaled to. Keeps proof photos
  /// small on mobile networks. Defaults to 1600.
  final double maxImageDimension;

  /// JPEG quality (1-100) of captured photos. Defaults to 85.
  final int imageQuality;

  /// Test hook replacing the camera capture.
  @visibleForTesting
  static Future<XFile?> Function(double maxDimension, int quality)? debugCameraCapture;

  /// Callback invoked when files are added, providing the list of added files.
  final ValueChanged<List<TFile>>? onAdd;

  /// Callback invoked when files are removed, providing the list of removed files.
  final ValueChanged<List<TFile>>? onRemove;

  /// Creates a file picker.
  const TFilePicker({
    super.key,
    this.label,
    this.tag,
    this.helperText,
    this.info,
    this.isRequired = false,
    this.disabled = false,
    this.clearable = false,
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
    this.isGalleryMode = false,
    this.source = TFilePickerSource.files,
    this.maxImageDimension = 1600,
    this.imageQuality = 85,
    this.onAdd,
    this.onRemove,
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

  Future<void> _onTap() async {
    if (widget.disabled) return;

    switch (widget.source) {
      case TFilePickerSource.files:
        await _pickFiles();
      case TFilePickerSource.camera:
        await _capturePhoto();
      case TFilePickerSource.filesOrCamera:
        final choice = await showModalBottomSheet<TFilePickerSource>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  minTileHeight: 56,
                  leading: TIcon.raw(HugeIcons.strokeRoundedCamera01),
                  title: const Text('Take photo'),
                  onTap: () => Navigator.pop(context, TFilePickerSource.camera),
                ),
                ListTile(
                  minTileHeight: 56,
                  leading: TIcon.raw(HugeIcons.strokeRoundedFolderOpen),
                  title: const Text('Choose file'),
                  onTap: () => Navigator.pop(context, TFilePickerSource.files),
                ),
              ],
            ),
          ),
        );
        if (choice == TFilePickerSource.camera) {
          await _capturePhoto();
        } else if (choice == TFilePickerSource.files) {
          await _pickFiles();
        }
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final capture = TFilePicker.debugCameraCapture ??
          (double maxDimension, int quality) => ImagePicker().pickImage(
                source: ImageSource.camera,
                maxWidth: maxDimension,
                maxHeight: maxDimension,
                imageQuality: quality,
              );
      final photo = await capture(widget.maxImageDimension, widget.imageQuality);
      if (photo == null) return;

      final bytes = await photo.readAsBytes();
      _addFiles([TFile(name: photo.name.isEmpty ? 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg' : photo.name, bytes: bytes)]);
    } catch (e) {
      debugPrint('Error capturing photo, falling back to file picker: $e');
      if (mounted) {
        TToastService.warning(context, 'No camera device found');
      }
      await _pickFiles();
    }
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

      _addFiles(result.toFiles());
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  void _addFiles(List<TFile> files) {
    if (files.isEmpty) return;

    if (widget.allowMultiple) {
      final current = currentValue ?? [];
      final toAdd = files.where((file) => !current.any((f) => f == file)).toList();
      if (toAdd.isEmpty) return;

      final newValue = List<TFile>.from(current)..addAll(toAdd);
      setState(() => notifyValueChanged(newValue));
      widget.onAdd?.call(toAdd);
    } else {
      final file = files.first;
      if (currentValue?.length == 1 && currentValue!.first == file) return;

      final previous = currentValue ?? [];
      final newValue = [file];
      setState(() => notifyValueChanged(newValue));
      if (previous.isNotEmpty && !previous.any((f) => f == file)) {
        widget.onRemove?.call(List<TFile>.from(previous));
      }
      widget.onAdd?.call([file]);
    }
  }

  void _removeFiles(List<TFile> files) {
    if (files.isEmpty) return;
    final current = currentValue ?? [];
    final toRemove = files.where((file) => current.any((f) => f == file)).toList();
    if (toRemove.isEmpty) return;

    final newValue = List<TFile>.from(current);
    newValue.removeWhere((f) => toRemove.any((removed) => removed == f));

    setState(() => notifyValueChanged(newValue));
    widget.onRemove?.call(toRemove);
  }

  void _removeFile(TFile file) {
    _removeFiles([file]);
  }

  @override
  Widget build(BuildContext context) {
    return buildContainer(
      onTap: _onTap,
      expands: true,
      hasValue: hasValue,
      onClear: () {
        if (currentValue != null && currentValue!.isNotEmpty) {
          _removeFiles(List<TFile>.from(currentValue!));
        } else {
          setState(() => notifyValueChanged([]));
        }
      },
      beforePreWidget: TIcon.raw(widget.source == TFilePickerSource.files ? HugeIcons.strokeRoundedAttachment : HugeIcons.strokeRoundedCamera01,
          size: 16, color: colors.onSurfaceVariant),
      child: Focus(
        focusNode: focusNode,
        autofocus: widget.autoFocus,
        child: wTheme.buildFilesField(
          states: states,
          files: currentValue ?? [],
          placeholder: widget.placeholder ?? widget.label,
          onRemove: (file) => _removeFile(file),
          isGalleryMode: widget.isGalleryMode,
        ),
      ),
    );
  }
}
