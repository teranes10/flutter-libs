import 'dart:io';
import 'package:flutter/foundation.dart';

class TFile {
  final String name;
  final String extension;
  final Uint8List bytes;
  final File? file;

  TFile({
    required this.name,
    required this.bytes,
    this.file,
  }) : extension = name.split('.').last.toLowerCase();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TFile) return false;

    final sameName = name == other.name;
    final sameBytes = _listEquals(bytes, other.bytes);
    final sameFile = (file != null && other.file != null) ? file!.path == other.file!.path : true;
    return sameName && sameBytes && sameFile;
  }

  @override
  int get hashCode {
    return Object.hash(name, _bytesHash(bytes), file?.path);
  }

  static bool _listEquals(Uint8List a, Uint8List b) {
    if (a.lengthInBytes != b.lengthInBytes) return false;
    for (int i = 0; i < a.lengthInBytes; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static int _bytesHash(Uint8List bytes) {
    int hash = 0;
    for (final b in bytes) {
      hash = 0x1fffffff & (hash + b);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= (hash >> 6);
    }
    return hash;
  }
}
