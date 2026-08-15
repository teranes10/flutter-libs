import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:te_widgets/extensions/u_int8_list_x.dart';

/// Represents a file selected by [TFilePicker].
///
/// `TFile` encapsulates file data including:
/// - File name and extension
/// - Raw bytes content
/// - Platform-specific [File] object (if available)
class TFile {
  /// The name of the file (e.g., "document.pdf").
  final String name;

  /// The file extension (e.g., "pdf").
  final String extension;

  /// The raw bytes of the file.
  final Uint8List? bytes;

  /// The remote URL of the file (e.g. for existing images).
  final String? url;

  /// The platform-specific file object (optional).
  ///
  /// This may be null on web or if only bytes are available.
  final File? file;

  /// Creates a file instance.
  TFile({
    required this.name,
    this.bytes,
    this.url,
    this.file,
  }) : extension = name.split('.').last.toLowerCase();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TFile) return false;

    final sameName = name == other.name;
    final sameUrl = url == other.url;
    final sameBytes = (bytes == null && other.bytes == null) || (bytes != null && other.bytes != null && bytes!.listEquals(other.bytes!));
    final sameFile = (file != null && other.file != null) ? file!.path == other.file!.path : true;
    return sameName && sameBytes && sameFile && sameUrl;
  }

  @override
  int get hashCode {
    return Object.hash(name, url, bytes?.bytesHash(), file?.path);
  }
}
