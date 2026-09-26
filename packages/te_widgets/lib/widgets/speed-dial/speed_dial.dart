import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A child action item in a [TSpeedDial].
class TSpeedDialChild {
  /// The icon displayed inside this action button.
  final IconData icon;

  /// Optional label text displayed beside the button.
  final String? label;

  /// Callback when this child action is clicked.
  final VoidCallback onTap;

  /// Background color for this action button.
  final Color? backgroundColor;

  /// Foreground icon/text color.
  final Color? foregroundColor;

  const TSpeedDialChild({
    required this.icon,
    required this.onTap,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });
}

/// An expandable floating action speed-dial menu for multi-action triggers,
/// batch exports, creating entities, and quick shortcuts.
class TSpeedDial extends StatefulWidget {
  /// List of child actions revealed when the dial expands.
  final List<TSpeedDialChild> children;

  /// Main collapsed icon. Defaults to [Icons.add].
  final IconData icon;

  /// Main expanded icon. Defaults to [Icons.close].
  final IconData activeIcon;

  /// Background color for the main button.
  final Color? backgroundColor;

  /// Foreground icon color.
  final Color? foregroundColor;

  /// Optional tooltip for the main button.
  final String? tooltip;

  /// Optional color of the modal background scrim when open. Defaults to null (no background).
  final Color? overlayColor;

  /// Spacing between action buttons in pixels. Defaults to 12.0.
  final double spacing;

  const TSpeedDial({
    super.key,
    required this.children,
    this.icon = Icons.add,
    this.activeIcon = Icons.close,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.overlayColor,
    this.spacing = 12.0,
  });

  @override
  State<TSpeedDial> createState() => _TSpeedDialState();
}

class _TSpeedDialState extends State<TSpeedDial> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animCtrl.forward();
      } else {
        _animCtrl.reverse();
      }
    });
  }

  void _close() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _animCtrl.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mainBg = widget.backgroundColor ?? colors.primary;
    final mainFg = widget.foregroundColor ?? colors.onPrimary;

    final actionColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Children Actions (Reversed so index 0 is closest to main button)
        ...widget.children.reversed.map((child) {
          return ScaleTransition(
            scale: _expandAnimation,
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: _animCtrl,
              child: IgnorePointer(
                ignoring: !_isOpen,
                child: Padding(
                  padding: EdgeInsets.only(bottom: widget.spacing),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (child.label != null) ...[
                        Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(6),
                          color: theme.cardColor,
                          child: InkWell(
                            onTap: () {
                              _close();
                              child.onTap();
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text(
                                child.label!,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      FloatingActionButton.small(
                        heroTag: null,
                        backgroundColor: child.backgroundColor ?? theme.cardColor,
                        foregroundColor: child.foregroundColor ?? colors.primary,
                        onPressed: () {
                          _close();
                          child.onTap();
                        },
                        child: Icon(child.icon, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        // Primary Toggle FAB
        FloatingActionButton(
          heroTag: null,
          tooltip: widget.tooltip,
          backgroundColor: mainBg,
          foregroundColor: mainFg,
          onPressed: _toggle,
          child: AnimatedBuilder(
            animation: _animCtrl,
            builder: (context, _) {
              return Transform.rotate(
                angle: _animCtrl.value * (math.pi / 2),
                child: Icon(
                  _animCtrl.value > 0.5 ? widget.activeIcon : widget.icon,
                  size: 24,
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.overlayColor == null) {
      return actionColumn;
    }

    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: AnimatedBuilder(
                animation: _animCtrl,
                builder: (context, _) => Container(
                  color: widget.overlayColor!.withValues(
                    alpha: widget.overlayColor!.a * _animCtrl.value,
                  ),
                ),
              ),
            ),
          ),
        actionColumn,
      ],
    );
  }
}
