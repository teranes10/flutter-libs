import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/configs/theme/app_colors.dart';
import 'package:te_widgets/enum/size.dart';
import 'package:te_widgets/extensions/build_context_x.dart';
import 'package:te_widgets/helpers/popup_position.dart';
import 'package:te_widgets/widgets/button/button.dart';
import 'package:te_widgets/widgets/icon/icon.dart';
import 'package:te_widgets/widgets/menu/menu_root_trigger.dart';

/// Controller to programmatically show, hide, or toggle a [TPopover].
class TPopoverController extends ChangeNotifier {
  final OverlayPortalController _portalController = OverlayPortalController();

  /// Whether the popover overlay is currently showing.
  bool get isShowing => _portalController.isShowing;

  /// Shows the popover.
  void show() {
    if (!_portalController.isShowing) {
      _portalController.show();
      notifyListeners();
    }
  }

  /// Hides the popover.
  void hide() {
    if (_portalController.isShowing) {
      _portalController.hide();
      notifyListeners();
    }
  }

  /// Toggles visibility of the popover.
  void toggle() {
    if (_portalController.isShowing) {
      hide();
    } else {
      show();
    }
  }
}

/// A floating, anchored popup card attached to a target [child] trigger.
///
/// Supports customizable alignment relative to trigger, title bar with close button,
/// outside-tap dismissal, keyboard (Esc) handling, and custom content builders.
class TPopover extends StatefulWidget {
  /// The target trigger widget.
  final Widget child;

  /// Static widget content inside the popover card.
  final Widget? content;

  /// Dynamic builder providing the [close] callback.
  final Widget Function(BuildContext context, VoidCallback close)? builder;

  /// Optional header title text.
  final String? title;

  /// Optional custom title widget.
  final Widget? titleWidget;

  /// Whether to display a close button in the header.
  final bool showCloseButton;

  /// Alignment of the popover relative to its target trigger.
  final TPopupAlignment alignment;

  /// Trigger gesture mode (tap or hover).
  final TMenuTriggerMode triggerMode;

  /// Gap distance in pixels between the trigger and the popover.
  final double offset;

  /// Whether tapping outside dismisses the popover.
  final bool barrierDismissible;

  /// Optional fixed width for the popover card.
  final double? width;

  /// Minimum width constraint.
  final double minWidth;

  /// Maximum width constraint.
  final double maxWidth;

  /// Optional minimum height constraint.
  final double? minHeight;

  /// Optional maximum height constraint.
  final double? maxHeight;

  /// Inner padding of the popover card.
  final EdgeInsetsGeometry padding;

  /// Border radius of the popover card.
  final BorderRadiusGeometry? borderRadius;

  /// Background color override.
  final Color? backgroundColor;

  /// Border color override.
  final Color? borderColor;

  /// Elevation shadow depth.
  final double elevation;

  /// Optional controller to programmatically manage the popover.
  final TPopoverController? controller;

  /// Callback fired when popover opens.
  final VoidCallback? onOpen;

  /// Callback fired when popover closes.
  final VoidCallback? onClose;

  const TPopover({
    super.key,
    required this.child,
    this.content,
    this.builder,
    this.title,
    this.titleWidget,
    this.showCloseButton = false,
    this.alignment = TPopupAlignment.bottomLeft,
    this.triggerMode = TMenuTriggerMode.tap,
    this.offset = 8.0,
    this.barrierDismissible = true,
    this.width,
    this.minWidth = 160.0,
    this.maxWidth = 360.0,
    this.minHeight,
    this.maxHeight,
    this.padding = const EdgeInsets.all(14.0),
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 8.0,
    this.controller,
    this.onOpen,
    this.onClose,
  }) : assert(content != null || builder != null, 'Either content or builder must be provided to TPopover');

  @override
  State<TPopover> createState() => _TPopoverState();
}

class _TPopoverState extends State<TPopover> {
  late TPopoverController _controller;
  bool _internalController = false;
  Timer? _hoverTimer;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TPopoverController();
      _internalController = true;
    }
  }

  @override
  void didUpdateWidget(TPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_internalController) {
        _controller.dispose();
      }
      if (widget.controller != null) {
        _controller = widget.controller!;
        _internalController = false;
      } else {
        _controller = TPopoverController();
        _internalController = true;
      }
    }
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    if (_internalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _show() {
    if (!_controller.isShowing) {
      _controller.show();
      widget.onOpen?.call();
    }
  }

  void _hide() {
    if (_controller.isShowing) {
      _controller.hide();
      widget.onClose?.call();
    }
  }

  void _toggle() {
    if (_controller.isShowing) {
      _hide();
    } else {
      _show();
    }
  }

  void _onEnter() {
    if (widget.triggerMode == TMenuTriggerMode.hover) {
      _isHovered = true;
      _hoverTimer?.cancel();
      _hoverTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted && _isHovered) {
          _show();
        }
      });
    }
  }

  void _onExit() {
    if (widget.triggerMode == TMenuTriggerMode.hover) {
      _isHovered = false;
      _hoverTimer?.cancel();
      _hoverTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted && !_isHovered) {
          _hide();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveBg = widget.backgroundColor ?? (isDark ? colors.surfaceContainerHigh : colors.surface);
    final effectiveBorder = widget.borderColor ?? colors.outlineVariant.withValues(alpha: 0.7);
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(10.0);

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _controller._portalController,
      overlayChildBuilder: (context, layoutInfo) {
        final double minW = widget.width ?? widget.minWidth;
        final double maxW = widget.width ?? widget.maxWidth;

        final constraints = TPopupConstraints.calculate(
          context,
          targetSize: layoutInfo.childSize,
          transform: layoutInfo.childPaintTransform,
          inputConstraints: BoxConstraints(
            minWidth: minW,
            maxWidth: maxW,
            minHeight: widget.minHeight ?? 0,
            maxHeight: widget.maxHeight ?? double.infinity,
          ),
          popupAlignment: widget.alignment,
        );

        return Stack(
          children: [
            // Barrier dismiss layer
            if (widget.barrierDismissible)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hide,
                ),
              ),

            // Popover card positioned relative to target
            CustomSingleChildLayout(
              delegate: PopupPositionDelegate(
                constraints: constraints,
                alignment: widget.alignment,
                offset: widget.offset,
              ),
              child: MouseRegion(
                onEnter: (_) {
                  if (widget.triggerMode == TMenuTriggerMode.hover) {
                    _isHovered = true;
                    _hoverTimer?.cancel();
                  }
                },
                onExit: (_) {
                  if (widget.triggerMode == TMenuTriggerMode.hover) {
                    _onExit();
                  }
                },
                child: KeyboardListener(
                  focusNode: FocusNode()..requestFocus(),
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
                      _hide();
                    }
                  },
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      constraints: constraints.contentBox,
                      decoration: BoxDecoration(
                        color: effectiveBg,
                        borderRadius: effectiveRadius,
                        border: Border.all(color: effectiveBorder),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: isDark ? 0.35 : 0.12),
                            blurRadius: widget.elevation * 2,
                            offset: Offset(0, widget.elevation / 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: effectiveRadius,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Optional Header
                            if (widget.title != null || widget.titleWidget != null || widget.showCloseButton) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: widget.titleWidget ??
                                          Text(
                                            widget.title ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                    ),
                                    if (widget.showCloseButton)
                                      InkWell(
                                        onTap: _hide,
                                        borderRadius: BorderRadius.circular(4),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(Icons.close_rounded, size: 16, color: colors.onSurfaceVariant),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.5)),
                            ],

                            // Content Body
                            Padding(
                              padding: widget.padding,
                              child: widget.builder != null ? widget.builder!(context, _hide) : widget.content!,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onEnter(),
        onExit: (_) => _onExit(),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.triggerMode == TMenuTriggerMode.tap ? _toggle : null,
          child: widget.child,
        ),
      ),
    );
  }
}

/// A specialized confirmation popover anchored directly to a trigger action.
///
/// Designed to replace bulky modal confirmation dialogs for table row deletions,
/// inline toggles, and sensitive actions.
class TPopconfirm extends StatefulWidget {
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

  const TPopconfirm({
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
    this.icon = Icons.help_outline_rounded,
    this.iconColor,
    this.alignment = TPopupAlignment.topCenter,
    this.width = 260.0,
  });

  /// Destructive confirmation preset (red delete button, warning icon).
  const TPopconfirm.danger({
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
    this.icon = Icons.warning_amber_rounded,
    this.iconColor = AppColors.danger,
    this.alignment = TPopupAlignment.topCenter,
    this.width = 260.0,
  });

  @override
  State<TPopconfirm> createState() => _TPopconfirmState();
}

class _TPopconfirmState extends State<TPopconfirm> {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.icon != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: TIcon(
                          icon: widget.icon,
                          size: 16,
                          color: widget.iconColor ?? colors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: colors.onSurface,
                            ),
                          ),
                          if (widget.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TButton(
                      text: widget.cancelText,
                      type: TButtonType.softText,
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
