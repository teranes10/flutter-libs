import 'dart:async';
import 'package:flutter/material.dart';

/// Centralized controller for the shared overlay-menu engine.
///
/// Tracks one active [OverlayPortalController] per nesting level, so
/// opening a submenu at level N automatically closes anything deeper, and
/// closes the whole stack once the pointer leaves every open panel.
///
/// This is the single implementation that replaces the two near-identical
/// controllers that used to live in the dropdown (`TDropdownOverlayController`,
/// level tracking via a `Map<int, OverlayPortalController>`) and the sidebar
/// (`TSidebarOverlayController`, a hand-rolled stack of raw `OverlayEntry`s
/// with its own smooth-close animation). The smooth/staggered close the
/// sidebar had is dropped deliberately — `OverlayPortal.hide()` unmounts
/// synchronously, so replicating an exit animation on top of it would mean
/// re-introducing a bespoke `OverlayEntry` layer, which defeats the point
/// of sharing this engine. If you want it back, it'd need to live as a
/// wrapping "closing" state inside `TMenuOverlayPanel` itself.
class TMenuOverlayController {
  static final Map<int, OverlayPortalController> _activeByLevel = {};
  static Timer? _closeTimer;
  static bool _isMouseInOverlayArea = false;
  static int _mouseInAreaCount = 0;

  static void show(int level, OverlayPortalController controller) {
    hideDeeperThan(level - 1);
    _activeByLevel[level] = controller;
    controller.show();
  }

  static void hideDeeperThan(int level) {
    final levels = _activeByLevel.keys.where((l) => l > level).toList();
    for (final l in levels) {
      _activeByLevel[l]?.hide();
      _activeByLevel.remove(l);
    }
  }

  static void hideAll() {
    _closeTimer?.cancel();
    for (final controller in _activeByLevel.values) {
      controller.hide();
    }
    _activeByLevel.clear();
    _resetState();
  }

  static void scheduleHide({Duration delay = const Duration(milliseconds: 125)}) {
    _closeTimer?.cancel();
    _closeTimer = Timer(delay, () {
      if (!_isMouseInOverlayArea && _mouseInAreaCount <= 0) {
        hideAll();
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
      if (!_isMouseInOverlayArea) scheduleHide();
    }
  }

  static void _resetState() {
    _isMouseInOverlayArea = false;
    _mouseInAreaCount = 0;
  }
}
