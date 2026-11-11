import 'package:flutter/foundation.dart';
import 'package:te_widgets/te_widgets.dart';
import 'dart:io';

extension PlatformFileListX on List<PlatformFile> {
  Future<List<TFile>> toFiles() async {
    final out = <TFile>[];
    for (final f in this) {
      final bytes = await f.readAsBytes();
      out.add(TFile(
        name: f.name,
        bytes: bytes,
        file: !kIsWeb && f.path != null ? File(f.path!) : null,
      ));
    }
    return out;
  }
}
