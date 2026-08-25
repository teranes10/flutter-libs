import 'dart:async';
import 'package:flutter/material.dart';

/// Centralized controller for the shared overlay-menu engine.
///
/// Tracks one active [OverlayPortalController] per nesting level, so
/// opening a submenu at level N automatically closes anything deeper, and
/// closes the whole stack once the pointer leaves every open panel.
class TMenuOverlayController {
  static final Map<int, OverlayPortalController> _activeByLevel = {};
  static final Set<int> _hoveredLevels = {};
  static bool _isTriggerHovered = false;
  static Timer? _closeTimer;
  static bool isLocked = false;

  static bool get isAnyHovered => _isTriggerHovered || _hoveredLevels.isNotEmpty;

  static void show(int level, OverlayPortalController controller) {
    hideDeeperThan(level - 1);
    _activeByLevel[level] = controller;
    controller.show();
  }

  static void hideDeeperThan(int level) {
    final levels = _activeByLevel.keys.where((l) => l > level).toList();
    for (final l in levels) {
      final controller = _activeByLevel[l];
      if (controller != null && controller.isShowing) {
        controller.hide();
      }
      _activeByLevel.remove(l);
      _hoveredLevels.remove(l);
    }
  }

  static void hideAll() {
    _closeTimer?.cancel();
    for (final controller in _activeByLevel.values) {
      if (controller.isShowing) {
        controller.hide();
      }
    }
    _activeByLevel.clear();
    _hoveredLevels.clear();
    _isTriggerHovered = false;
  }

  static void scheduleHide({Duration delay = const Duration(milliseconds: 125)}) {
    _closeTimer?.cancel();
    if (isLocked) return;
    _closeTimer = Timer(delay, () {
      if (!isAnyHovered) {
        hideAll();
      }
    });
  }

  static void setTriggerHovered(bool hovered) {
    _isTriggerHovered = hovered;
    if (hovered) {
      _closeTimer?.cancel();
    } else {
      scheduleHide();
    }
  }

  static void setPanelHovered(int level, bool hovered) {
    if (hovered) {
      _hoveredLevels.add(level);
      _closeTimer?.cancel();
    } else {
      _hoveredLevels.remove(level);
      if (!isAnyHovered) {
        scheduleHide();
      }
    }
  }

  /// Backwards-compatibility alias for older code
  static void setMouseInArea(bool inArea) {
    setTriggerHovered(inArea);
  }
}
