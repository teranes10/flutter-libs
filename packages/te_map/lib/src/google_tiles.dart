import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;

import 'map_config.dart';

/// Session for the official Google Map Tiles API (2D tiles).
class TGoogleTileSession {
  final String token;
  final DateTime expiry;

  const TGoogleTileSession(this.token, this.expiry);

  bool get isExpired => DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 10)));

  static final Map<String, Future<TGoogleTileSession?>> _cache = {};

  /// Creates (or reuses a cached) session. Returns null when the API is unavailable
  /// (key invalid, Map Tiles API not enabled, offline...).
  static Future<TGoogleTileSession?> obtain({
    required String apiKey,
    String language = 'en-US',
    String region = 'US',
    String mapType = 'roadmap',
  }) async {
    final cacheKey = '$apiKey|$language|$region|$mapType';
    final cached = _cache[cacheKey];
    if (cached != null) {
      final session = await cached;
      if (session != null && !session.isExpired) return session;
      _cache.removeWhere((k, _) => k == cacheKey);
    }

    final future = _create(apiKey, language, region, mapType);
    _cache[cacheKey] = future;
    final session = await future;
    if (session == null) _cache.removeWhere((k, _) => k == cacheKey);
    return session;
  }

  static Future<TGoogleTileSession?> _create(String apiKey, String language, String region, String mapType) async {
    try {
      final response = await http.post(
        Uri.parse('${TMapConfig.tilesApiBase}/createSession').replace(queryParameters: {'key': apiKey}),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mapType': mapType,
          'language': language.contains('-') ? language : '$language-${region.toUpperCase()}',
          'region': region,
        }),
      );
      if (response.statusCode != 200) {
        debugPrint('te_map: Google Map Tiles session failed (${response.statusCode}): ${response.body}');
        return null;
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final token = json['session'] as String?;
      if (token == null) return null;
      final seconds = int.tryParse('${json['expiry']}') ?? 0;
      return TGoogleTileSession(
        token,
        seconds > 0 ? DateTime.fromMillisecondsSinceEpoch(seconds * 1000) : DateTime.now().add(const Duration(days: 6)),
      );
    } catch (e) {
      debugPrint('te_map: Google Map Tiles session failed: $e');
      return null;
    }
  }
}

/// Tile layer backed by the Google Map Tiles API. Falls back to OpenStreetMap
/// tiles when no session can be created.
class TGoogleTileLayer extends StatefulWidget {
  final String apiKey;
  final String language;
  final String region;
  final bool darkMode;
  final int keepBuffer;
  final String packageName;

  const TGoogleTileLayer({
    super.key,
    required this.apiKey,
    required this.darkMode,
    this.language = 'en-US',
    this.region = 'US',
    this.keepBuffer = 5,
    this.packageName = 'com.te_widgets.app',
  });

  @override
  State<TGoogleTileLayer> createState() => _TGoogleTileLayerState();
}

class _TGoogleTileLayerState extends State<TGoogleTileLayer> {
  late Future<TGoogleTileSession?> _session = _load();

  Future<TGoogleTileSession?> _load() => TGoogleTileSession.obtain(apiKey: widget.apiKey, language: widget.language, region: widget.region);

  @override
  void didUpdateWidget(TGoogleTileLayer old) {
    super.didUpdateWidget(old);
    if (old.apiKey != widget.apiKey || old.language != widget.language || old.region != widget.region) _session = _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TGoogleTileSession?>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const SizedBox.shrink();
        final session = snapshot.data;
        if (session == null) {
          return buildTileLayer(
            mapType: MapTileType.osm,
            darkMode: widget.darkMode,
            keepBuffer: widget.keepBuffer,
            packageName: widget.packageName,
          );
        }
        return tintForTheme(
          TileLayer(
            urlTemplate: '${TMapConfig.tilesApiBase}/2dtiles/{z}/{x}/{y}?session=${session.token}&key=${widget.apiKey}',
            userAgentPackageName: widget.packageName,
            keepBuffer: widget.keepBuffer,
          ),
          widget.darkMode,
        );
      },
    );
  }
}
