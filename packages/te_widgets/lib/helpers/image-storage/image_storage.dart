import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'image_storage_stub.dart' if (dart.library.html) 'image_storage_web.dart' if (dart.library.io) 'image_storage_mobile.dart';

abstract class TImageStorage {
  static final Dio _dio = Dio();

  static String urlToKey(String url) => sha1.convert(utf8.encode(url)).toString();

  /// Downloads [remoteUrl] without storing it anywhere. Returns null on failure.
  static Future<Uint8List?> downloadBytes(String remoteUrl) async {
    try {
      final response = await _dio.get<List<int>>(remoteUrl, options: Options(responseType: ResponseType.bytes));
      if (response.data != null) return Uint8List.fromList(response.data!);
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
