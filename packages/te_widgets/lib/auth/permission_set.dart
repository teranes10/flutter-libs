/// Answers whether a permission string is granted.
abstract class TPermissionGranter {
  const TPermissionGranter();
  bool has(String permission);
}

/// Set-based granter.
///
/// - exact: `orders.edit`
/// - wildcard: `orders.*` (any depth under `orders.`), `*` (everything)
/// - deny: `!orders.delete` (always wins over grants)
class TPermissionSet extends TPermissionGranter {
  final Set<String> _grants = {};
  final Set<String> _denies = {};

  TPermissionSet([Iterable<String> permissions = const []]) {
    for (final p in permissions) {
      final s = p.trim();
      if (s.isEmpty) continue;
      s.startsWith('!') ? _denies.add(s.substring(1)) : _grants.add(s);
    }
  }

  @override
  bool has(String permission) => !_matches(_denies, permission) && _matches(_grants, permission);

  static bool _matches(Set<String> patterns, String permission) {
    if (patterns.isEmpty) return false;
    if (patterns.contains('*') || patterns.contains(permission)) return true;
    var i = permission.lastIndexOf('.');
    while (i > 0) {
      if (patterns.contains('${permission.substring(0, i)}.*')) return true;
      i = permission.lastIndexOf('.', i - 1);
    }
    return false;
  }
}
