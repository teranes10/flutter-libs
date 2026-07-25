import 'dart:async';
import 'package:flutter/material.dart';

/// Manages a stack of overlays, providing centralized control for
/// showing, hiding, and nesting overlays.
class TDropdownOverlayController {
  static final Map<int, OverlayPortalController> _activeOverlaysByLevel = {};
  static Timer? _closeTimer;
  static bool _isMouseInOverlayArea = false;
  static int _mouseInAreaCount = 0;

  static void showOverlay(int level, OverlayPortalController controller) {
    hideOverlaysDeeperThan(level - 1);
    _activeOverlaysByLevel[level] = controller;
    controller.show();
  }

  static void hideOverlaysDeeperThan(int level) {
    final levelsToHide = _activeOverlaysByLevel.keys.where((l) => l > level).toList();
    for (final l in levelsToHide) {
      _activeOverlaysByLevel[l]?.hide();
      _activeOverlaysByLevel.remove(l);
    }
  }

  static void hideAllOverlays() {
    _closeTimer?.cancel();
    for (final controller in _activeOverlaysByLevel.values) {
      controller.hide();
    }
    _activeOverlaysByLevel.clear();
    _resetState();
  }

  static void scheduleHide({Duration delay = const Duration(milliseconds: 125)}) {
    _closeTimer?.cancel();

    _closeTimer = Timer(delay, () {
      if (!_isMouseInOverlayArea && _mouseInAreaCount <= 0) {
        hideAllOverlays();
      }
    });
  }

  static void setMouseInArea(bool inArea) {
    if (inArea) {
      _mouseInAreaCount++;
      _isMouseInOverlayArea = true;
      _closeTimer?.cancel();
    } else {
      _mouseInAreaCount = (_mouseInAreaCount - 1).clamp(0, 999);
      _isMouseInOverlayArea = _mouseInAreaCount > 0;
      if (!_isMouseInOverlayArea) {
        scheduleHide();
      }
    }
  }

  static void _resetState() {
    _isMouseInOverlayArea = false;
    _mouseInAreaCount = 0;
  }
}
