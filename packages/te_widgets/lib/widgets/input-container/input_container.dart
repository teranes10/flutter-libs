import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A container widget styled according to [TInputFieldTheme] and [TInputSize].
///
/// `TInputContainer` matches standard input fields in height, border radius,
/// background color, borders, and hover/focus/disabled states.
///
/// ## Basic Usage
///
/// ```dart
/// TInputContainer(
///   size: TInputSize.sm,
///   child: Text('Content'),
/// )
/// ```
class TInputContainer extends StatefulWidget {
  /// The theme configuration for this input container.
  final TInputFieldTheme? theme;

  /// The size preset for the container.
  final TInputSize? size;

  /// The widget to display inside the container.
  final Widget? child;

  /// The width of the container. If null and [block] is true, expands to infinity; if [block] is false, wraps content.
  final double? width;

  /// The height of the container. If null, uses the theme's field height.
  final double? height;

  /// Whether the container should expand to fill available horizontal width.
  ///
  /// Defaults to true (matches input fields). When false, wraps the content.
  final bool block;

  /// Alignment of the child inside the container.
  final AlignmentGeometry alignment;

  /// Custom padding inside the container. If null, uses theme fieldPadding.
  final EdgeInsetsGeometry? padding;

  /// Whether the container is disabled.
  final bool disabled;

  /// Whether the container is in an error state.
  final bool hasError;

  /// Whether the container is focused / active.
  final bool isFocused;

  /// Callback when the container is tapped.
  final VoidCallback? onTap;

  /// Custom mouse cursor.
  final MouseCursor? cursor;

  const TInputContainer({
    super.key,
    this.theme,
    this.size,
    this.child,
    this.width,
    this.height,
    this.block = true,
    this.alignment = Alignment.center,
    this.padding,
    this.disabled = false,
    this.hasError = false,
    this.isFocused = false,
    this.onTap,
    this.cursor,
  });

  @override
  State<TInputContainer> createState() => _TInputContainerState();
}

class _TInputContainerState extends State<TInputContainer> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    var effectiveTheme = widget.theme ?? context.theme.inputFieldTheme;
    if (widget.size != null) {
      effectiveTheme = effectiveTheme.copyWith(size: widget.size);
    }

    final states = <WidgetState>{
      if (widget.isFocused) WidgetState.focused,
      if (widget.hasError) WidgetState.error,
      if (widget.disabled) WidgetState.disabled,
      if (_isHovering) WidgetState.hovered,
    };

    final effectiveHeight = widget.height ?? effectiveTheme.fieldHeight;
    final effectivePadding = widget.padding ?? effectiveTheme.fieldPadding;

    final inputBorder = effectiveTheme.buildInputBorder(states);
    final borderRadius = inputBorder is OutlineInputBorder
        ? inputBorder.borderRadius
        : BorderRadius.circular(effectiveTheme.borderRadius.resolve(states));

    final borderColor = effectiveTheme.borderColor.resolve(states);
    final borderWidth = effectiveTheme.borderWidth.resolve(states);

    final bool hasBorderSide = inputBorder.borderSide.style != BorderStyle.none &&
        effectiveTheme.decorationType != TInputDecorationType.none;

    final border = hasBorderSide
        ? (effectiveTheme.decorationType == TInputDecorationType.underline
            ? Border(bottom: BorderSide(color: borderColor, width: borderWidth))
            : Border.all(color: borderColor, width: borderWidth))
        : null;

    final backgroundColor = effectiveTheme.resolveBackgroundColor(context, states);

    final defaultCursor = widget.disabled
        ? SystemMouseCursors.basic
        : (widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer);

    return MouseRegion(
      cursor: widget.cursor ?? defaultCursor,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.disabled ? null : widget.onTap,
        child: Container(
          width: widget.width,
          height: effectiveHeight,
          constraints: BoxConstraints(
            minHeight: effectiveHeight,
            minWidth: widget.block ? double.infinity : 0,
          ),
          alignment: widget.alignment,
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: effectiveTheme.decorationType == TInputDecorationType.underline
                ? BorderRadius.zero
                : borderRadius,
            border: border,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
