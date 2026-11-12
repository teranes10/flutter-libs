/// Global configuration for [TImage].
class TImageConfig {
  /// Base URL prepended to relative image paths (e.g. paths stored in a DB).
  /// Null by default, meaning urls are used as-is.
  static String? baseUrl;

  /// Optional custom resolver. Takes precedence over [baseUrl].
  static String? Function(String url)? resolveUrl;

  static final _absolute = RegExp(r'^([a-zA-Z][a-zA-Z0-9+.-]*:|//)');

  /// Resolves [url]: absolute urls (http, https, file, data, blob, asset...) are returned unchanged,
  /// relative paths get [baseUrl] prepended when set.
  static String? resolve(String? url) {
    if (url == null || url.isEmpty) return url;
    final custom = resolveUrl;
    if (custom != null) return custom(url);
    final base = baseUrl;
    if (base == null || base.isEmpty || _absolute.hasMatch(url)) return url;
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return url.startsWith('/') ? '$b$url' : '$b/$url';
  }
}
