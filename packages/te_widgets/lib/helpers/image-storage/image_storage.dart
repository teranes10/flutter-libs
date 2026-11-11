import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'image_storage_stub.dart' if (dart.library.html) 'image_storage_web.dart' if (dart.library.io) 'image_storage_mobile.dart';

abstract class TImageStorage {
  /// Stable cache key: two 32-bit FNV-1a hashes with different seeds (web-safe, no multiplication overflow).
  static String urlToKey(String url) {
    final bytes = utf8.encode(url);
    String fnv(int seed) {
      var h = seed;
      for (final b in bytes) {
        h = (h ^ b) & 0xFFFFFFFF;
        h = (h + (h << 1) + (h << 4) + (h << 7) + (h << 8) + (h << 24)) & 0xFFFFFFFF;
      }
      return h.toRadixString(16).padLeft(8, '0');
    }

    return fnv(0x811C9DC5) + fnv(0x01000193);
  }

  /// Downloads [remoteUrl] without storing it anywhere. Returns null on failure.
  static Future<Uint8List?> downloadBytes(String remoteUrl) async {
    try {
      final response = await http.get(Uri.parse(remoteUrl));
      if (response.statusCode >= 200 && response.statusCode < 300) return response.bodyBytes;
    } catch (e) {
      debugPrint('⚠️ [ImageDownloader] Failed to download $remoteUrl: $e');
    }
    return null;
  }

  static Future<String?> downloadAndCacheImage(String remoteUrl) async {
    final bytes = await downloadBytes(remoteUrl);
    if (bytes == null) return null; // Return null on failure
    return await storeImage(urlToKey(remoteUrl), bytes);
  }

  static Future<String?> storeImage(String key, Uint8List bytes) async {
    if (kIsWeb) {
      return await storeImageWeb(key, bytes);
    } else {
      return await storeImageMobile(key, bytes);
    }
  }

  static Future<Uint8List?> loadImage(String localRef) async {
    if (localRef.startsWith('db://')) {
      return await loadImageWeb(localRef);
    } else {
      return await loadImageMobile(localRef);
    }
  }

  static Future<Uint8List?> loadImageByKey(String key) async {
    if (kIsWeb) {
      return await loadImageWeb('db://$key');
    } else {
      return await loadImageMobileByKey(key);
    }
  }
}
