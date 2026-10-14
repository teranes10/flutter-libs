import 'package:flutter/services.dart';

/// Central haptic + sound feedback for eyes-off, hands-busy workflows
/// (scan confirmations, quantity steps, errors).
///
/// Widgets must call this helper instead of using [HapticFeedback] directly so
/// that apps can disable or tune feedback in one place.
abstract final class TFeedback {
  /// Globally enables or disables all feedback (e.g. from a user setting).
  static bool enabled = true;

  /// Also plays a short system sound for [success], [warning] and [error].
  static bool soundEnabled = true;

  /// Light tick for selection changes (toggle, tab change, chip select).
  static Future<void> selection() async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Soft impact for incremental steps (quantity +/-).
  static Future<void> step() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Confirms a successful scan/validation/commit.
  static Future<void> success() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
    if (soundEnabled) await SystemSound.play(SystemSoundType.click);
  }

  /// Signals something the operator should double check (e.g. near expiry).
  static Future<void> warning() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
    if (soundEnabled) await SystemSound.play(SystemSoundType.alert);
  }

  /// Signals a rejected action (wrong item/location, validation failure).
  static Future<void> error() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.heavyImpact();
    if (soundEnabled) await SystemSound.play(SystemSoundType.alert);
  }
}
