import 'dart:ui' show Color;

import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

extension PdfColorX on Color {
  PdfColor toPdfColor() {
    int r = (this.r * 255.0).round() & 0xff;
    int g = (this.g * 255.0).round() & 0xff;
    int b = (this.b * 255.0).round() & 0xff;
    int a = (this.a * 255.0).round() & 0xff;

    return PdfColor(
      r / 255.0,
      g / 255.0,
      b / 255.0,
      a / 255.0,
    );
  }
}

extension PdfDocumentX on Document {
  Future<String> download({String fileName = "download"}) async {
    final bytes = await save();
    return FileSaver.instance.saveFile(name: fileName, bytes: bytes, fileExtension: "pdf", mimeType: MimeType.pdf);
  }
}
