import 'dart:async';

import 'package:flutter/material.dart';
import 'package:te_widgets/layouts/widgets/sidebar/sidebar_config.dart';

class TSidebarOverlayController {
  static final List<OverlayEntry> _overlayStack = [];
  static final Map<int, OverlayEntry> _levelOverlays = {}; // Track overlays by level
  static Timer? _closeTimer;
  static Timer? _smoothCloseTimer;
  static bool _isMouseInOverlayArea = false;
  static int _mouseInAreaCount = 0;

  static void showOverlay(OverlayEntry overlay, {bool isNested = false}) {
    if (!isNested) hideAllOverlays();

    _overlayStack.add(overlay);
    _levelOverlays[1] = overlay;
    _closeTimer?.cancel();
    _smoothCloseTimer?.cancel();
  }

  static void showNestedOverlay(OverlayEntry overlay, int level) {
    _removeOverlaysDeeper(level);

    _overlayStack.add(overlay);
    _levelOverlays[level] = overlay;
    _closeTimer?.cancel();
    _smoothCloseTimer?.cancel();
  }

  static void hideAllOverlays({bool smooth = false}) {
    _closeTimer?.cancel();
    _smoothCloseTimer?.cancel();

    if (smooth) {
      _animateOutAllOverlays();
    } else {
      _removeAllOverlays();
      _resetState();
    }
  }

  static void scheduleHide({bool smooth = false}) {
    _closeTimer?.cancel();
    _smoothCloseTimer?.cancel();

    final delay = smooth ? TSidebarConstants.smoothHideDelay : const Duration(milliseconds: 300);

    if (smooth) {
      _smoothCloseTimer = Timer(delay, () {
        if (!_isMouseInOverlayArea && _mouseInAreaCount <= 0) {
          hideAllOverlays(smooth: true);
        }
      });
    } else {
      _closeTimer = Timer(delay, () {
        if (!_isMouseInOverlayArea && _mouseInAreaCount <= 0) {
          hideAllOverlays(smooth: true);
        }
      });
    }
  }

  static void setMouseInArea(bool inArea) {
    if (inArea) {
      _mouseInAreaCount++;
      _isMouseInOverlayArea = true;
      _closeTimer?.cancel();
      _smoothCloseTimer?.cancel();
    } else {
      _mouseInAreaCount = (_mouseInAreaCount - 1).clamp(0, 999);
      _isMouseInOverlayArea = _mouseInAreaCount > 0;

      if (!_isMouseInOverlayArea) {
        scheduleHide();
      }
    }
  }

  // Improved: Only remove overlays deeper than the specified level
  static void _removeOverlaysDeeper(int level) {
    final overlaysToRemove = <OverlayEntry>[];
    final levelsToRemove = <int>[];

    _levelOverlays.forEach((overlayLevel, overlay) {
      if (overlayLevel > level) {
        overlaysToRemove.add(overlay);
        levelsToRemove.add(overlayLevel);
      }
    });

    for (final overlay in overlaysToRemove) {
      overlay.remove();
      _overlayStack.remove(overlay);
    }

    for (final levelToRemove in levelsToRemove) {
      _levelOverlays.remove(levelToRemove);
    }
  }

  static void _animateOutAllOverlays() {
    // Create a copy of overlays for animation
    final overlaysToAnimate = List<OverlayEntry>.from(_overlayStack.reversed);

    // Start fade out animation
    for (int i = 0; i < overlaysToAnimate.length; i++) {
      final overlay = overlaysToAnimate[i];
      Timer(Duration(milliseconds: i * 75), () {
        try {
          overlay.remove();
        } catch (e) {
          // Overlay might already be removed
        }
      });
    }

    _overlayStack.clear();
    _levelOverlays.clear();
    _resetState();
  }

  static void _removeAllOverlays() {
    for (final overlay in _overlayStack) {
      try {
        overlay.remove();
      } catch (e) {
        // Overlay might already be removed
      }
    }
    _overlayStack.clear();
    _levelOverlays.clear();
  }

  static void _resetState() {
    _isMouseInOverlayArea = false;
    _mouseInAreaCount = 0;
  }
}
