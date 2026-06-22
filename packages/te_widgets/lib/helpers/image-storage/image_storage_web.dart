// ignore_for_file: uri_does_not_exist, undefined_class, deprecated_member_use, undefined_prefixed_name, unused_import
import 'dart:async';
import 'dart:html' as html;
import 'dart:indexed_db' as idb;
import 'dart:typed_data';

const String _dbName = 'te_widgets_image_cache';
const String _storeName = 'images';

Future<idb.Database?> _getWebDb() async {
  return await html.window.indexedDB?.open(_dbName, version: 1, onUpgradeNeeded: (event) {
    final db = event.target.result as idb.Database;
    if (db.objectStoreNames?.contains(_storeName) != true) {
      db.createObjectStore(_storeName);
    }
  });
}

Future<String?> storeImageWeb(String key, Uint8List bytes) async {
  final db = await _getWebDb();
  if (db != null) {
    final tx = db.transaction(_storeName, 'readwrite');
    final store = tx.objectStore(_storeName);
    final blob = html.Blob([bytes]);
    await store.put(blob, key);
    await tx.completed;
    return 'db://$key';
  }
  return null;
}

Future<Uint8List?> loadImageWeb(String localRef) async {
  final key = localRef.replaceFirst('db://', '');
  final db = await _getWebDb();
  if (db != null) {
    final tx = db.transaction(_storeName, 'readonly');
    final store = tx.objectStore(_storeName);
    final dynamic data = await store.getObject(key);
    await tx.completed;
    if (data is html.Blob) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(data);
      await reader.onLoadEnd.first;
      return Uint8List.fromList(reader.result as List<int>);
    }
  }
  return null;
}

Future<String?> storeImageMobile(String key, Uint8List bytes) {
  throw UnimplementedError();
}

Future<Uint8List?> loadImageMobile(String localRef) {
  throw UnimplementedError();
}

Future<Uint8List?> loadImageMobileByKey(String key) {
  throw UnimplementedError();
}
