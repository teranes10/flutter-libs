import 'dart:async';
import 'package:flutter/material.dart';

/// Inherited scope providing the active menu [rootId] down the widget tree.
class TMenuScope extends InheritedWidget {
  final Object rootId;

  const TMenuScope({
    super.key,
    required this.rootId,
    required super.child,
  });

  static Object? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TMenuScope>()?.rootId;
  }

  @override
  bool updateShouldNotify(TMenuScope oldWidget) => rootId != oldWidget.rootId;
}

/// Tracks state for an active menu root.
class _MenuRootState {
  final Object rootId;
  Object? parentRootId;
  final Map<int, OverlayPortalController> activeByLevel = {};
  final Set<int> hoveredLevels = {};
  bool isTriggerHovered = false;
  Timer? closeTimer;

  _MenuRootState({required this.rootId, this.parentRootId});

  bool get isAnyHovered => isTriggerHovered || hoveredLevels.isNotEmpty;
}

/// Centralized controller for the shared overlay-menu engine.
///
/// Supports multiple independent and nested menu root trees by keying state per [rootId].
class TMenuOverlayController {
  static final Map<Object, _MenuRootState> _roots = {};
  static final Object _defaultRoot = Object();
  static bool isLocked = false;

  static Object get defaultRootId => _defaultRoot;

  static _MenuRootState _getOrCreateState(Object? rootId, {Object? parentRootId}) {
    final key = rootId ?? _defaultRoot;
    final state = _roots.putIfAbsent(key, () => _MenuRootState(rootId: key, parentRootId: parentRootId));
    if (parentRootId != null) {
      state.parentRootId = parentRootId;
    }
    return state;
  }

  static _MenuRootState? _getState(Object? rootId) {
    return _roots[rootId ?? _defaultRoot];
  }

  /// Check if the root or any of its descendants are hovered.
  static bool isBranchHovered(Object? rootId) {
    final key = rootId ?? _defaultRoot;
    final state = _roots[key];
    if (state == null) return false;
    if (state.isAnyHovered) return true;

    // Check descendant roots
    for (final child in _roots.values.where((r) => r.parentRootId == key)) {
      if (isBranchHovered(child.rootId)) return true;
    }
    return false;
  }

  static bool isAnyHovered([Object? rootId]) {
    if (rootId == null) {
      return _roots.values.any((r) => r.isAnyHovered);
    }
    return isBranchHovered(rootId);
  }

  /// Show a level controller for a given menu root.
  /// If [parentRootId] is null and [level] == 0, this is treated as a top-level root
  /// and closes any unrelated top-level menus.
  static void show(
    int level,
    OverlayPortalController controller, {
    Object? rootId,
    Object? parentRootId,
  }) {
    final effectiveRoot = rootId ?? _defaultRoot;
    final state = _getOrCreateState(effectiveRoot, parentRootId: parentRootId);

    // If opening a new top-level root menu, hide all unrelated root trees
    if (level == 0 && parentRootId == null) {
      hideAllExcept(effectiveRoot);
    }

    hideDeeperThan(level - 1, rootId: effectiveRoot);
    state.activeByLevel[level] = controller;
    controller.show();
  }

  /// Hides any levels deeper than [level] for the given [rootId], and hides
  /// any child roots opened from those levels.
  static void hideDeeperThan(int level, {Object? rootId}) {
    final key = rootId ?? _defaultRoot;
    final state = _roots[key];
    if (state == null) return;

    final levels = state.activeByLevel.keys.where((l) => l > level).toList();
    for (final l in levels) {
      final controller = state.activeByLevel[l];
      if (controller != null && controller.isShowing) {
        controller.hide();
      }
      state.activeByLevel.remove(l);
      state.hoveredLevels.remove(l);
    }

    // Hide child roots whose parent is this root
    if (levels.isNotEmpty) {
      final childRoots = _roots.values.where((r) => r.parentRootId == key).map((r) => r.rootId).toList();
      for (final childRoot in childRoots) {
        hideRoot(childRoot);
      }
    }
  }

  /// Hides a specific root and all its descendant roots.
  static void hideRoot(Object? rootId) {
    final key = rootId ?? _defaultRoot;
    final state = _roots[key];
    if (state == null) return;

    state.closeTimer?.cancel();
    for (final controller in state.activeByLevel.values) {
      if (controller.isShowing) {
        controller.hide();
      }
    }
    state.activeByLevel.clear();
    state.hoveredLevels.clear();
    state.isTriggerHovered = false;

    // Recursively hide all child roots
    final childRoots = _roots.values.where((r) => r.parentRootId == key).map((r) => r.rootId).toList();
    for (final childRoot in childRoots) {
      hideRoot(childRoot);
    }

    _roots.remove(key);
  }

  /// Hides all roots except the given root and its ancestors/descendants.
  static void hideAllExcept(Object? rootId) {
    if (rootId == null) return;
    final allowedRoots = <Object>{};

    // Add current and all ancestors
    Object? current = rootId;
    while (current != null) {
      allowedRoots.add(current);
      current = _roots[current]?.parentRootId;
    }

    // Add all descendants of allowed roots
    void addDescendants(Object id) {
      for (final child in _roots.values.where((r) => r.parentRootId == id)) {
        if (allowedRoots.add(child.rootId)) {
          addDescendants(child.rootId);
        }
      }
    }

    for (final id in allowedRoots.toList()) {
      addDescendants(id);
    }

    final toHide = _roots.keys.where((k) => !allowedRoots.contains(k)).toList();
    for (final k in toHide) {
      hideRoot(k);
    }
  }

  /// Closes all active menus across the entire application.
  static void hideAll() {
    for (final state in _roots.values) {
      state.closeTimer?.cancel();
      for (final controller in state.activeByLevel.values) {
        if (controller.isShowing) {
          controller.hide();
        }
      }
    }
    _roots.clear();
  }

  /// Schedules hiding the given [rootId] (or all roots if null) after a debounce delay.
  static void scheduleHide({
    Object? rootId,
    Duration delay = const Duration(milliseconds: 125),
  }) {
    if (isLocked) return;

    if (rootId == null) {
      for (final state in _roots.values) {
        state.closeTimer?.cancel();
        state.closeTimer = Timer(delay, () {
          if (!isBranchHovered(state.rootId)) {
            hideRoot(state.rootId);
          }
        });
      }
      return;
    }

    final key = rootId;
    final state = _getState(key);
    if (state == null) return;

    state.closeTimer?.cancel();
    state.closeTimer = Timer(delay, () {
      if (!isBranchHovered(key)) {
        hideRoot(key);
      }
    });
  }

  static void setTriggerHovered(bool hovered, {Object? rootId}) {
    final key = rootId ?? _defaultRoot;
    final state = _getOrCreateState(key);
    state.isTriggerHovered = hovered;
    if (hovered) {
      state.closeTimer?.cancel();
      // Also cancel ancestor timers
      Object? parent = state.parentRootId;
      while (parent != null) {
        _roots[parent]?.closeTimer?.cancel();
        parent = _roots[parent]?.parentRootId;
      }
    } else {
      scheduleHide(rootId: key);
    }
  }

  static void setPanelHovered(int level, bool hovered, {Object? rootId}) {
    final key = rootId ?? _defaultRoot;
    final state = _getOrCreateState(key);
    if (hovered) {
      state.hoveredLevels.add(level);
      state.closeTimer?.cancel();
      // Also cancel ancestor timers
      Object? parent = state.parentRootId;
      while (parent != null) {
        _roots[parent]?.closeTimer?.cancel();
        parent = _roots[parent]?.parentRootId;
      }
    } else {
      state.hoveredLevels.remove(level);
      if (!isBranchHovered(key)) {
        scheduleHide(rootId: key);
      }
    }
  }

  static void disposeRoot(Object? rootId) {
    if (rootId == null) return;
    _roots[rootId]?.closeTimer?.cancel();
    _roots.remove(rootId);
  }

  /// Backwards-compatibility alias for older code
  static void setMouseInArea(bool inArea, {Object? rootId}) {
    setTriggerHovered(inArea, rootId: rootId);
  }
}
