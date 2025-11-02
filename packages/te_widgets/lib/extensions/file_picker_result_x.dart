import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:te_widgets/te_widgets.dart';
import 'dart:io';

extension FilePickerResultX on FilePickerResult {
  List<TFile> toFiles() {
    return files.map((f) {
      final bytes = f.bytes;
      if (bytes == null) {
        throw Exception('File bytes not found for "${f.name}". Make sure to use `withData: true` in FilePicker.');
      }

      return TFile(
        name: f.name,
        bytes: bytes,
        file: !kIsWeb && f.path != null ? File(f.path!) : null,
      );
    }).toList();
  }
}
