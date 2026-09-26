import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/configs/theme/app_colors.dart';
import 'package:te_widgets/extensions/build_context_x.dart';

/// A segmented PIN / OTP verification code input field.
///
/// Automatically handles digit entry, backspace navigation, clipboard paste,
/// obscure masking, and completed state detection.
class TPinField extends StatefulWidget {
  /// Number of segments / digits (default 6).
  final int length;

  /// Width of each segment box (default 48.0).
  final double boxWidth;

  /// Height of each segment box (default 54.0).
  final double boxHeight;

  /// Horizontal spacing between segment boxes (default 10.0).
  final double spacing;

  /// Border radius of segment boxes (default 8.0).
  final double borderRadius;

  /// Whether to obscure the input text (like a password/PIN).
  final bool obscureText;

  /// Mask character used when [obscureText] is true (default '•').
  final String obscureCharacter;

  /// Whether this field is disabled.
  final bool enabled;

  /// Whether to autofocus the first segment box.
  final bool autoFocus;

  /// Error text displayed below the field.
  final String? errorText;

  /// Callback fired whenever any digit changes.
  final ValueChanged<String>? onChanged;

  /// Callback fired as soon as all digits are filled.
  final ValueChanged<String>? onCompleted;

  const TPinField({
    super.key,
    this.length = 6,
    this.boxWidth = 48.0,
    this.boxHeight = 54.0,
    this.spacing = 10.0,
    this.borderRadius = 8.0,
    this.obscureText = false,
    this.obscureCharacter = '•',
    this.enabled = true,
    this.autoFocus = false,
    this.errorText,
    this.onChanged,
    this.onCompleted,
  }) : assert(length > 1, 'TPinField length must be at least 2');

  @override
  State<TPinField> createState() => _TPinFieldState();
}

class _TPinFieldState extends State<TPinField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (index) {
      final node = FocusNode();
      node.addListener(() {
        if (node.hasFocus && mounted) {
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        }
      });
      return node;
    });

    if (widget.autoFocus && _focusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentPin {
    return _controllers.map((c) => c.text).join();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handles pasting multiple digits into one field
      _handlePaste(value);
      return;
    }

    widget.onChanged?.call(_currentPin);

    if (value.isNotEmpty) {
      // Advance to next box
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    if (_currentPin.length == widget.length) {
      widget.onCompleted?.call(_currentPin);
    }
  }

  void _handlePaste(String pastedText) {
    final cleaned = pastedText.replaceAll(RegExp(r'\s+'), '');
    for (int i = 0; i < widget.length; i++) {
      if (i < cleaned.length) {
        _controllers[i].text = cleaned[i];
      }
    }
    widget.onChanged?.call(_currentPin);

    // Focus last populated box or unfocus if all full
    if (cleaned.length >= widget.length) {
      _focusNodes.last.unfocus();
      widget.onCompleted?.call(_currentPin);
    } else {
      _focusNodes[cleaned.length].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: widget.spacing,
          runSpacing: widget.spacing,
          alignment: WrapAlignment.center,
          children: List.generate(widget.length, (index) {
            final isFocused = _focusNodes[index].hasFocus;
            final isFilled = _controllers[index].text.isNotEmpty;

            Color borderColor;
            if (hasError) {
              borderColor = AppColors.danger;
            } else if (isFocused) {
              borderColor = colors.primary;
            } else if (isFilled) {
              borderColor = colors.outlineVariant;
            } else {
              borderColor = colors.outlineVariant.withValues(alpha: 0.5);
            }

            final bgColor = isDark
                ? (isFocused ? colors.surfaceContainerHighest : colors.surfaceContainerHigh)
                : (isFocused ? colors.surface : colors.surfaceContainerLow);

            return KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                // Handle backspace when field is already empty to jump back
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    _controllers[index].text.isEmpty &&
                    index > 0) {
                  _controllers[index - 1].clear();
                  _focusNodes[index - 1].requestFocus();
                  widget.onChanged?.call(_currentPin);
                }
              },
              child: Container(
                width: widget.boxWidth,
                height: widget.boxHeight,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: borderColor,
                    width: isFocused || hasError ? 2.0 : 1.0,
                  ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  enabled: widget.enabled,
                  obscureText: widget.obscureText,
                  obscuringCharacter: widget.obscureCharacter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) => _onDigitChanged(index, val),
                ),
              ),
            );
          }),
        ),

        // Error Message
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}
