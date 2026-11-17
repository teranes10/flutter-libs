import 'dart:typed_data';

import '../../helpers/image-storage/image_storage.dart';

/// Persists the user's glass background image through [TImageStorage] (IndexedDB on web, a file elsewhere).
class TGlassImageStore {
  TGlassImageStore._();

  static const _key = 'te_glass_background';

  /// Stored image bytes, or null when none (or storage is unavailable).
  static Future<Uint8List?> load() async {
    try {
      return await TImageStorage.loadImageByKey(_key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(Uint8List bytes) => TImageStorage.storeImage(_key, bytes);

  static Future<void> clear() async {
    try {
      await TImageStorage.deleteImage(_key);
    } catch (_) {}
  }
}
