import 'package:file_saver/file_saver.dart';
import 'package:pdf/widgets.dart';

extension PdfDocumentX on Document {
  Future<String> download({String fileName = "download"}) async {
    final bytes = await save();
    return FileSaver.instance.saveFile(name: fileName, bytes: bytes, fileExtension: "pdf", mimeType: MimeType.pdf);
  }
}
