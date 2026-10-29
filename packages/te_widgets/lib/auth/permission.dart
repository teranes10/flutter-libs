/// A permission requirement: one string, any-of, or all-of a list.
class TPermission {
  final List<String> keys;
  final bool requireAll;

  const TPermission(String key)
      : keys = const [],
        requireAll = true,
        _single = key;

  const TPermission.any(this.keys)
      : requireAll = false,
        _single = null;

  const TPermission.all(this.keys)
      : requireAll = true,
        _single = null;

  final String? _single;

  /// Accepts a [String], a [TPermission] or null.
  static TPermission? from(Object? value) => switch (value) {
        null => null,
        TPermission p => p,
        String s => TPermission(s),
        _ => throw ArgumentError('permission must be a String or TPermission, got ${value.runtimeType}'),
      };

  bool evaluate(bool Function(String) has) {
    final single = _single;
    if (single != null) return has(single);
    if (keys.isEmpty) return true;
    return requireAll ? keys.every(has) : keys.any(has);
  }
}
