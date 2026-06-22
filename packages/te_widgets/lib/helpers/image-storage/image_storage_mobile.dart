import 'dart:io' as io;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String?> storeImageWeb(String key, Uint8List bytes) {
  throw UnimplementedError();
}

Future<Uint8List?> loadImageWeb(String localRef) {
  throw UnimplementedError();
}

Future<String?> storeImageMobile(String key, Uint8List bytes) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = io.File('${dir.path}/$key');
  await file.writeAsBytes(bytes);
  return file.path;
}

Future<Uint8List?> loadImageMobile(String localRef) async {
  final file = io.File(localRef);
  if (await file.exists()) {
    return await file.readAsBytes();
  }
  return null;
}

/// Loads an image by its sha1 [key] directly from the documents directory,
/// without needing to have stored the full path separately.
Future<Uint8List?> loadImageMobileByKey(String key) async {
  final dir = await getApplicationDocumentsDirectory();
  return await loadImageMobile('${dir.path}/$key');
}
