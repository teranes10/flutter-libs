import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Turns a stream of hardware key events into complete barcode scans.
///
/// Keyboard-wedge scanners (Zebra, Honeywell, Bluetooth guns...) "type" the
/// barcode very fast and finish with Enter (or Tab). A human types far
/// slower, so keys arriving more than [maxKeyGap] apart restart the buffer.
///
/// Pure logic, no widgets: unit-testable and reusable outside [TScanListener].
class TScanBuffer {
  /// Maximum gap between two keys of the same scan.
  final Duration maxKeyGap;

  /// Shortest accepted barcode (shorter bursts are discarded as typing noise).
  final int minLength;

  /// Keys that end a scan.
  final Set<LogicalKeyboardKey> terminators;

  final StringBuffer _buffer = StringBuffer();
  Duration? _lastKeyAt;

  /// Creates a scan buffer.
  TScanBuffer({
    this.maxKeyGap = const Duration(milliseconds: 100),
    this.minLength = 3,
    Set<LogicalKeyboardKey>? terminators,
  }) : terminators = terminators ??
            {
              LogicalKeyboardKey.enter,
              LogicalKeyboardKey.numpadEnter,
              LogicalKeyboardKey.tab,
            };

  /// Feeds a key event. Returns the completed barcode when [event] is a
  /// terminator ending a valid scan, otherwise `null`.
  String? feed(KeyEvent event) {
    if (event is! KeyDownEvent) return null;

    final last = _lastKeyAt;
    if (last != null && event.timeStamp - last > maxKeyGap) {
      _buffer.clear();
    }
    _lastKeyAt = event.timeStamp;

    if (terminators.contains(event.logicalKey)) {
      final code = _buffer.toString();
      _buffer.clear();
      return code.length >= minLength ? code : null;
    }

    final char = event.character;
    if (char != null && char.isNotEmpty && char.codeUnitAt(0) >= 0x20) {
      _buffer.write(char);
    }
    return null;
  }

  /// Drops any partially collected scan.
  void reset() {
    _buffer.clear();
    _lastKeyAt = null;
  }
}

/// Captures hardware (keyboard-wedge) barcode scans anywhere in its subtree.
///
/// Wrap a task screen with it so the operator can scan at any time without
/// focusing an input field. While a text field is being edited the scanner's
/// Enter is left to that field (e.g. `TTextField.scan`) unless
/// [captureWhileEditing] is true, so a scan is never delivered twice.
///
/// ```dart
/// TScanListener(
///   onScan: (code) => ref.read(scanProvider.notifier).handle(code),
///   child: const PickScreen(),
/// )
/// ```
class TScanListener extends StatefulWidget {
  /// The wrapped screen content.
  final Widget child;

  /// Called with the scanned barcode text.
  final ValueChanged<String> onScan;

  /// Enables / disables capturing (e.g. while a dialog is open).
  final bool enabled;

  /// Also capture while a text field has focus.
  final bool captureWhileEditing;

  /// Maximum gap between keys of one scan. See [TScanBuffer.maxKeyGap].
  final Duration maxKeyGap;

  /// Shortest accepted barcode. See [TScanBuffer.minLength].
  final int minLength;

  /// Creates a scan listener.
  const TScanListener({
    super.key,
    required this.child,
    required this.onScan,
    this.enabled = true,
    this.captureWhileEditing = false,
    this.maxKeyGap = const Duration(milliseconds: 100),
    this.minLength = 3,
  });

  @override
  State<TScanListener> createState() => _TScanListenerState();
}

class _TScanListenerState extends State<TScanListener> {
  late TScanBuffer _buffer;

  @override
  void initState() {
    super.initState();
    _buffer = TScanBuffer(maxKeyGap: widget.maxKeyGap, minLength: widget.minLength);
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void didUpdateWidget(covariant TScanListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxKeyGap != widget.maxKeyGap || oldWidget.minLength != widget.minLength) {
      _buffer = TScanBuffer(maxKeyGap: widget.maxKeyGap, minLength: widget.minLength);
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool get _isEditing {
    final focusContext = FocusManager.instance.primaryFocus?.context;
    return focusContext?.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _onKey(KeyEvent event) {
    if (!widget.enabled || !mounted) return false;
    if (!widget.captureWhileEditing && _isEditing) {
      _buffer.reset();
      return false;
    }

    final code = _buffer.feed(event);
    if (code != null) {
      widget.onScan(code);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
