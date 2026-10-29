/// What a widget does when its permission check fails.
enum TAuthMode {
  /// Render normally (no restriction).
  allow,

  /// Remove the widget from the tree.
  hide,

  /// Keep the widget visible but non-interactive.
  disable,
}

/// Kinds of widgets that can carry their own default [TAuthMode].
enum TAuthTarget { button, buttonGroup, tab, actionBar, bottomBar, navBar, sidebarItem, menuItem, tile, crudAction }

/// Library-wide defaults for how denied permissions are handled.
class TAuthConfig {
  /// Mode used when nothing more specific applies.
  final TAuthMode defaultDeniedMode;

  /// Per widget-kind defaults, e.g. `{TAuthTarget.sidebarItem: TAuthMode.hide}`.
  final Map<TAuthTarget, TAuthMode> targetModes;

  /// Treat permissions as denied while the controller is [TAuthController.loading].
  final bool failClosedWhileLoading;

  const TAuthConfig({
    this.defaultDeniedMode = TAuthMode.disable,
    this.targetModes = const {
      TAuthTarget.sidebarItem: TAuthMode.hide,
      TAuthTarget.tab: TAuthMode.hide,
      TAuthTarget.bottomBar: TAuthMode.hide,
      TAuthTarget.navBar: TAuthMode.hide,
    },
    this.failClosedWhileLoading = true,
  });

  /// Resolves the denied mode: widget override > target default > global default.
  TAuthMode resolve(TAuthTarget target, TAuthMode? override) => override ?? targetModes[target] ?? defaultDeniedMode;
}
