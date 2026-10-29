import 'package:flutter/widgets.dart';

import 'auth_mode.dart';
import 'permission.dart';
import 'permission_set.dart';

/// Outcome of a permission check, already resolved to an action.
class TAuthResult {
  final TAuthMode mode;
  const TAuthResult(this.mode);

  static const allowed = TAuthResult(TAuthMode.allow);

  bool get isAllowed => mode == TAuthMode.allow;
  bool get isHidden => mode == TAuthMode.hide;
  bool get isDisabled => mode == TAuthMode.disable;
}

/// Holds the externally supplied permission list and resolves checks.
///
/// Provide it with [TAuthScope]; call [update] after login/logout/refresh and
/// every dependent widget rebuilds.
class TAuthController extends ChangeNotifier {
  TPermissionGranter? _granter;
  bool _loading;

  /// Defaults for denied handling.
  final TAuthConfig config;

  /// With no [permissions] and no [granter] the controller is *unconfigured*
  /// and allows everything. Once a list is supplied (even an empty one), any
  /// permission not in it is denied.
  TAuthController({Iterable<String>? permissions, TPermissionGranter? granter, this.config = const TAuthConfig(), bool loading = false})
      : _granter = granter ?? (permissions == null ? null : TPermissionSet(permissions)),
        _loading = loading;

  /// Whether a permission list has been supplied.
  bool get isConfigured => _granter != null;

  bool get loading => _loading;

  /// Replaces the permission list and marks loading finished.
  void update(Iterable<String> permissions) {
    _granter = TPermissionSet(permissions);
    _loading = false;
    notifyListeners();
  }

  void setGranter(TPermissionGranter granter) {
    _granter = granter;
    _loading = false;
    notifyListeners();
  }

  void setLoading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }

  bool has(Object permission) {
    final g = _granter;
    return g == null || TPermission.from(permission)!.evaluate(g.has);
  }

  /// Checks [permission] (String or [TPermission]); null permission is always allowed.
  TAuthResult check(Object? permission, {required TAuthTarget target, TAuthMode? onDenied}) {
    final p = TPermission.from(permission);
    if (p == null) return TAuthResult.allowed;
    final g = _granter;
    if (g == null) return TAuthResult.allowed;
    final granted = _loading ? !config.failClosedWhileLoading : p.evaluate(g.has);
    return granted ? TAuthResult.allowed : TAuthResult(config.resolve(target, onDenied));
  }
}

/// Provides a [TAuthController] to the subtree. No scope = everything allowed.
class TAuthScope extends InheritedNotifier<TAuthController> {
  const TAuthScope({super.key, required TAuthController controller, required super.child}) : super(notifier: controller);

  static TAuthController? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TAuthScope>()?.notifier;
}

extension TAuthContextX on BuildContext {
  /// The nearest [TAuthController], or null when no scope is installed.
  TAuthController? get auth => TAuthScope.maybeOf(this);

  /// Resolves [permission] for a widget kind; allowed when no scope exists.
  TAuthResult authResolve(Object? permission, {required TAuthTarget target, TAuthMode? onDenied}) =>
      TAuthScope.maybeOf(this)?.check(permission, target: target, onDenied: onDenied) ?? TAuthResult.allowed;
}
