import 'dart:async';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A specialized confirmation popover anchored directly to a trigger action.
///
/// Designed to replace bulky modal confirmation dialogs for table row deletions,
/// inline toggles, and sensitive actions.
class TPopConfirm extends StatefulWidget {
  /// The action trigger (e.g. Delete button, icon button).
  final Widget child;

  /// Primary question / title prompt (e.g. "Delete this row?").
  final String title;

  /// Optional explanatory description.
  final String? description;

  /// Asynchronous or synchronous callback executed upon confirmation.
  final FutureOr<void> Function() onConfirm;

  /// Optional callback executed when user cancels.
  final VoidCallback? onCancel;

  /// Confirmation button label (default 'Confirm').
  final String confirmText;

  /// Cancel button label (default 'Cancel').
  final String cancelText;

  /// Confirmation button semantic type.
  final TButtonType confirmType;

  /// Confirmation button color override.
  final Color? confirmColor;

  /// Leading icon in the popconfirm card.
  final dynamic icon;

  /// Color of the leading icon.
  final Color? iconColor;

  /// Alignment of the popover relative to the child.
  final TPopupAlignment alignment;

  /// Width of the popconfirm card.
  final double width;

  const TPopConfirm({
    super.key,
    required this.child,
    required this.title,
    this.description,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmType = TButtonType.solid,
    this.confirmColor,
    this.icon = HugeIcons.strokeRoundedHelpCircle,
    this.iconColor,
    this.alignment = TPopupAlignment.topCenter,
    this.width = 275.0,
  });

  /// Destructive confirmation preset (red delete button, warning icon).
  const TPopConfirm.danger({
    super.key,
    required this.child,
    required this.title,
    this.description,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    this.confirmType = TButtonType.solid,
    this.confirmColor = AppColors.danger,
    this.icon = HugeIcons.strokeRoundedAlert02,
    this.iconColor = AppColors.danger,
    this.alignment = TPopupAlignment.topCenter,
    this.width = 260.0,
  });

  @override
  State<TPopConfirm> createState() => _TPopconfirmState();
}

class _TPopconfirmState extends State<TPopConfirm> {
  final TPopoverController _controller = TPopoverController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TPopover(
      controller: _controller,
      alignment: widget.alignment,
      width: widget.width,
      padding: const EdgeInsets.all(12.0),
      builder: (popContext, close) {
        return StatefulBuilder(
          builder: (innerContext, setInnerState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      TIcon.raw(widget.icon, size: 18, color: widget.iconColor ?? colors.primary),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: colors.onSurface),
                      ),
                    ),
                  ],
                ),
                if (widget.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.description!,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w300, color: colors.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TButton(
                      text: widget.cancelText,
                      baseTheme: TWidgetTheme.surfaceTheme(colors),
                      size: TButtonSize.xs,
                      onTap: () {
                        widget.onCancel?.call();
                        close();
                      },
                    ),
                    const SizedBox(width: 6),
                    TButton(
                      text: widget.confirmText,
                      type: widget.confirmType,
                      color: widget.confirmColor ?? colors.primary,
                      size: TButtonSize.xs,
                      loading: _isLoading,
                      onTap: () async {
                        setInnerState(() => _isLoading = true);
                        try {
                          await widget.onConfirm();
                          close();
                        } finally {
                          if (mounted) {
                            setInnerState(() => _isLoading = false);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
      child: widget.child,
    );
  }
}
