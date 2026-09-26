import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';

/// A button that copies text to the clipboard with animated state feedback.
///
/// `TCopyButton` automatically updates its icon and tooltip upon being clicked,
/// displaying a confirmation checkmark for a configurable duration (default: 2s),
/// and optionally triggering a [TToastService] toast notification.
///
/// ## Basic Usage
///
/// ```dart
/// // Icon-only copy button
/// TCopyButton(text: 'https://example.com/share')
///
/// // Button with label and toast notification
/// TCopyButton(
///   text: apiKey,
///   label: 'Copy Key',
///   copiedLabel: 'Copied!',
///   showToast: true,
/// )
/// ```
class TCopyButton extends StatefulWidget {
  /// The text content to be copied to the clipboard.
  final String text;

  /// Optional label text displayed on the button.
  final String? label;

  /// Optional label text displayed while in the copied state.
  final String? copiedLabel;

  /// Normal icon displayed before copying. Defaults to [Icons.copy_rounded].
  final dynamic icon;

  /// Success icon displayed after copying. Defaults to [Icons.check_rounded].
  final dynamic copiedIcon;

  /// Visual button type. Defaults to [TButtonType.softText].
  final TButtonType type;

  /// Button sizing metrics. Defaults to [TButtonSize.xs].
  final TButtonSize size;

  /// Primary color for the button.
  final Color? color;

  /// Accent color used when in the copied state. Defaults to [ColorScheme.primary].
  final Color? copiedColor;

  /// Tooltip message before copying. Defaults to 'Copy to clipboard'.
  final String? tooltip;

  /// Tooltip message while in the copied state. Defaults to 'Copied!'.
  final String? copiedTooltip;

  /// Whether to show a success toast notification via [TToastService].
  final bool showToast;

  /// Toast message displayed if [showToast] is true.
  final String toastMessage;

  /// Duration to hold the copied state before reverting to the default state.
  final Duration resetDuration;

  /// Optional callback invoked when the text is copied.
  final VoidCallback? onCopied;

  /// Creates a copy button.
  const TCopyButton({
    super.key,
    required this.text,
    this.label,
    this.copiedLabel,
    this.icon,
    this.copiedIcon,
    this.type = TButtonType.softText,
    this.size = TButtonSize.xs,
    this.color,
    this.copiedColor,
    this.tooltip = 'Copy to clipboard',
    this.copiedTooltip = 'Copied!',
    this.showToast = false,
    this.toastMessage = 'Copied to clipboard',
    this.resetDuration = const Duration(seconds: 2),
    this.onCopied,
  });

  @override
  State<TCopyButton> createState() => _TCopyButtonState();
}

class _TCopyButtonState extends State<TCopyButton> {
  bool _isCopied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));

    if (!mounted) return;

    setState(() {
      _isCopied = true;
    });

    widget.onCopied?.call();

    if (widget.showToast) {
      TToastService.success(context, widget.toastMessage);
    }

    _resetTimer?.cancel();
    _resetTimer = Timer(widget.resetDuration, () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCopiedColor = widget.copiedColor ?? context.themeOrNull?.success ?? AppColors.success;
    final effectiveIcon = _isCopied ? (widget.copiedIcon ?? Icons.check_rounded) : (widget.icon ?? Icons.copy_rounded);
    final effectiveLabel = _isCopied ? (widget.copiedLabel ?? widget.label) : widget.label;
    final effectiveTooltip = _isCopied ? widget.copiedTooltip : widget.tooltip;

    return TButton(
      type: widget.type,
      size: widget.size,
      color: _isCopied ? effectiveCopiedColor : widget.color,
      icon: effectiveIcon,
      text: effectiveLabel,
      tooltip: effectiveTooltip,
      onTap: _handleCopy,
    );
  }
}

/// A wrapper widget that pairs text or a custom widget with an inline [TCopyButton].
///
/// `TCopyable` makes IDs, codes, GUIDs, hashes, and URLs easily copyable with hover
/// visibility or always-visible copy controls.
///
/// ## Basic Usage
///
/// ```dart
/// // Copyable code/hash text
/// TCopyable.text('api_live_9f8231ab40')
///
/// // Monospace badge format
/// TCopyable.text(
///   order.id,
///   monospace: true,
///   showButtonAlways: true,
/// )
/// ```
class TCopyable extends StatefulWidget {
  /// The string copied to the clipboard.
  final String text;

  /// Custom child widget to display instead of default text rendering.
  final Widget? child;

  /// Text style for default text rendering.
  final TextStyle? style;

  /// Whether to display in an inline monospace code block container.
  final bool monospace;

  /// Whether the copy button is always visible, or only shown on hover.
  final bool showButtonAlways;

  /// Sizing for the inline copy button.
  final TButtonSize buttonSize;

  /// Optional label for the copy button.
  final String? buttonLabel;

  /// Whether to show a toast message when copied.
  final bool showToast;

  /// Tooltip text for the copy button.
  final String tooltip;

  /// Creates a copyable container around [child].
  const TCopyable({
    super.key,
    required this.text,
    required this.child,
    this.style,
    this.monospace = false,
    this.showButtonAlways = false,
    this.buttonSize = TButtonSize.xxs,
    this.buttonLabel,
    this.showToast = false,
    this.tooltip = 'Copy to clipboard',
  });

  /// Creates a copyable text widget with optional monospace styling.
  const TCopyable.text(
    this.text, {
    super.key,
    this.style,
    this.monospace = false,
    this.showButtonAlways = false,
    this.buttonSize = TButtonSize.xxs,
    this.buttonLabel,
    this.showToast = false,
    this.tooltip = 'Copy to clipboard',
  }) : child = null;

  @override
  State<TCopyable> createState() => _TCopyableState();
}

class _TCopyableState extends State<TCopyable> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final defaultStyle = TextStyle(
      fontSize: 13.0,
      fontFamily: widget.monospace ? 'monospace' : null,
      color: colors.onSurface,
    );

    final effectiveStyle = defaultStyle.merge(widget.style);

    final textNode = widget.child ??
        Text(
          widget.text,
          style: effectiveStyle,
          overflow: TextOverflow.ellipsis,
        );

    final showButton = widget.showButtonAlways || _isHovered;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        textNode,
        if (showButton) ...[
          const SizedBox(width: 4.0),
          TCopyButton(
            text: widget.text,
            label: widget.buttonLabel,
            size: widget.buttonSize,
            showToast: widget.showToast,
            tooltip: widget.tooltip,
          ),
        ],
      ],
    );

    if (widget.monospace) {
      content = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: content,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: content,
    );
  }
}
