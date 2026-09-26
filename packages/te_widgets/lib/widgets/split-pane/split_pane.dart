import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Controller for [TSplitPane] to programmatically control split ratio and collapse states.
class TSplitPaneController extends ChangeNotifier {
  double? _ratio;
  double? _leadingExtent;
  bool _isLeadingCollapsed = false;
  bool _isTrailingCollapsed = false;
  double? _savedRatio;
  final double? _initialRatio;

  TSplitPaneController({double? initialRatio})
      : _ratio = initialRatio,
        _initialRatio = initialRatio;

  /// Current split ratio (0.0 to 1.0) representing the proportion of the leading pane.
  double? get ratio => _ratio;

  /// Pixel extent of leading pane, if set in fixed pixels.
  double? get leadingExtent => _leadingExtent;

  /// Whether the leading pane is currently collapsed.
  bool get isLeadingCollapsed => _isLeadingCollapsed;

  /// Whether the trailing pane is currently collapsed.
  bool get isTrailingCollapsed => _isTrailingCollapsed;

  /// Set the split ratio directly (clamped between 0.0 and 1.0).
  void setRatio(double ratio) {
    _ratio = ratio.clamp(0.0, 1.0);
    _leadingExtent = null;
    _isLeadingCollapsed = _ratio == 0.0;
    _isTrailingCollapsed = _ratio == 1.0;
    notifyListeners();
  }

  /// Set the pixel extent for the leading pane.
  void setLeadingExtent(double extent) {
    _leadingExtent = math.max(0.0, extent);
    _isLeadingCollapsed = _leadingExtent == 0.0;
    _isTrailingCollapsed = false;
    notifyListeners();
  }

  /// Collapse the leading pane.
  void collapseLeading() {
    if (_isLeadingCollapsed) return;
    _savedRatio = _ratio ?? 0.5;
    _isLeadingCollapsed = true;
    _isTrailingCollapsed = false;
    _ratio = 0.0;
    _leadingExtent = 0.0;
    notifyListeners();
  }

  /// Collapse the trailing pane.
  void collapseTrailing() {
    if (_isTrailingCollapsed) return;
    _savedRatio = _ratio ?? 0.5;
    _isTrailingCollapsed = true;
    _isLeadingCollapsed = false;
    _ratio = 1.0;
    _leadingExtent = null;
    notifyListeners();
  }

  /// Expand and restore previously collapsed pane.
  void expand() {
    if (!_isLeadingCollapsed && !_isTrailingCollapsed) return;
    _isLeadingCollapsed = false;
    _isTrailingCollapsed = false;
    _ratio = _savedRatio ?? _initialRatio ?? 0.5;
    _leadingExtent = null;
    notifyListeners();
  }

  /// Toggle collapse for leading pane.
  void toggleLeadingCollapse() {
    if (_isLeadingCollapsed) {
      expand();
    } else {
      collapseLeading();
    }
  }

  /// Toggle collapse for trailing pane.
  void toggleTrailingCollapse() {
    if (_isTrailingCollapsed) {
      expand();
    } else {
      collapseTrailing();
    }
  }

  /// Reset the split pane to its initial configuration.
  void reset() {
    _isLeadingCollapsed = false;
    _isTrailingCollapsed = false;
    _ratio = _initialRatio ?? 0.5;
    _leadingExtent = null;
    notifyListeners();
  }
}

/// A responsive, draggable resizable two-pane container for admin consoles, master-detail views,
/// side-by-side comparisons, and IDE layouts.
class TSplitPane extends StatefulWidget {
  /// The leading (left or top) widget pane.
  final Widget leading;

  /// The trailing (right or bottom) widget pane.
  final Widget trailing;

  /// Split orientation: [Axis.horizontal] for left/right panes, [Axis.vertical] for top/bottom panes.
  final Axis axis;

  /// Optional external controller for programmatically resizing or collapsing panes.
  final TSplitPaneController? controller;

  /// Initial ratio for the leading pane (between 0.0 and 1.0). Defaults to 0.5.
  final double initialRatio;

  /// Initial pixel extent for the leading pane. If provided, overrides [initialRatio].
  final double? initialExtent;

  /// Minimum allowed pixel extent for the leading pane. Defaults to 80.0.
  final double minLeadingExtent;

  /// Maximum allowed pixel extent for the leading pane. If null, unbounded up to trailing minimum.
  final double? maxLeadingExtent;

  /// Minimum allowed pixel extent for the trailing pane. Defaults to 80.0.
  final double minTrailingExtent;

  /// Maximum allowed pixel extent for the trailing pane. If null, unbounded.
  final double? maxTrailingExtent;

  /// Thickness of the interactive divider bar in pixels. Defaults to 8.0.
  final double dividerThickness;

  /// Whether to render a visual grip indicator in the center of the divider handle. Defaults to true.
  final bool showGrip;

  /// Whether to render quick collapse/expand buttons on the divider handle. Defaults to false.
  final bool showCollapseButtons;

  /// Whether dragging past [collapseSnapThreshold] allows snapping the leading pane to collapsed (0px). Defaults to false.
  final bool collapsibleLeading;

  /// Whether dragging past [collapseSnapThreshold] allows snapping the trailing pane to collapsed (0px). Defaults to false.
  final bool collapsibleTrailing;

  /// Distance threshold in pixels from edge to snap pane to collapsed. Defaults to 40.0.
  final double collapseSnapThreshold;

  /// Callback fired whenever the split ratio changes due to user dragging or controller updates.
  final ValueChanged<double>? onResized;

  /// Callback fired when the divider is double-clicked to reset.
  final VoidCallback? onReset;

  const TSplitPane({
    super.key,
    required this.leading,
    required this.trailing,
    this.axis = Axis.horizontal,
    this.controller,
    this.initialRatio = 0.5,
    this.initialExtent,
    this.minLeadingExtent = 80.0,
    this.maxLeadingExtent,
    this.minTrailingExtent = 80.0,
    this.maxTrailingExtent,
    this.dividerThickness = 8.0,
    this.showGrip = true,
    this.showCollapseButtons = false,
    this.collapsibleLeading = false,
    this.collapsibleTrailing = false,
    this.collapseSnapThreshold = 40.0,
    this.onResized,
    this.onReset,
  }) : assert(initialRatio >= 0.0 && initialRatio <= 1.0, 'initialRatio must be between 0.0 and 1.0');

  @override
  State<TSplitPane> createState() => _TSplitPaneState();
}

class _TSplitPaneState extends State<TSplitPane> {
  late TSplitPaneController _controller;
  bool _internalController = false;

  bool _isHovered = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TSplitPaneController(initialRatio: widget.initialRatio);
      _internalController = true;
    }
    _controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant TSplitPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_internalController) {
        _controller.removeListener(_handleControllerChange);
        _controller.dispose();
      } else {
        oldWidget.controller?.removeListener(_handleControllerChange);
      }

      if (widget.controller != null) {
        _controller = widget.controller!;
        _internalController = false;
      } else {
        _controller = TSplitPaneController(initialRatio: widget.initialRatio);
        _internalController = true;
      }
      _controller.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    if (_internalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) {
      setState(() {});
      if (_controller.ratio != null) {
        widget.onResized?.call(_controller.ratio!);
      }
    }
  }

  void _handleDragUpdate(DragUpdateDetails details, double totalAvailable) {
    if (totalAvailable <= 0) return;

    final delta = widget.axis == Axis.horizontal ? details.delta.dx : details.delta.dy;
    final currentExtent = _calculateLeadingExtent(totalAvailable);
    double newExtent = currentExtent + delta;

    // Check snap collapse leading
    if (widget.collapsibleLeading && newExtent < widget.collapseSnapThreshold) {
      _controller.collapseLeading();
      return;
    }

    // Check snap collapse trailing
    final remainingForTrailing = totalAvailable - newExtent;
    if (widget.collapsibleTrailing && remainingForTrailing < widget.collapseSnapThreshold) {
      _controller.collapseTrailing();
      return;
    }

    // Clamp constraints
    final minLead = widget.minLeadingExtent;
    final maxLead = widget.maxLeadingExtent ?? (totalAvailable - widget.minTrailingExtent);
    final minTrail = widget.minTrailingExtent;
    final maxTrail = widget.maxTrailingExtent;

    // Constrain by leading min/max
    newExtent = newExtent.clamp(minLead, maxLead);

    // Constrain by trailing max if specified
    if (maxTrail != null) {
      final minLeadDueToTrail = totalAvailable - maxTrail;
      if (newExtent < minLeadDueToTrail) {
        newExtent = minLeadDueToTrail;
      }
    }

    // Constrain by trailing min
    if (totalAvailable - newExtent < minTrail) {
      newExtent = totalAvailable - minTrail;
    }

    final newRatio = (newExtent / totalAvailable).clamp(0.0, 1.0);
    _controller.setRatio(newRatio);
  }

  double _calculateLeadingExtent(double totalAvailable) {
    if (_controller.isLeadingCollapsed) return 0.0;
    if (_controller.isTrailingCollapsed) return totalAvailable;

    if (_controller.leadingExtent != null) {
      return _controller.leadingExtent!.clamp(0.0, totalAvailable);
    }

    final ratio = _controller.ratio ?? widget.initialRatio;
    return (totalAvailable * ratio).clamp(0.0, totalAvailable);
  }

  void _handleDoubleTap() {
    _controller.reset();
    widget.onReset?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor;
    final primaryColor = theme.colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize = widget.axis == Axis.horizontal ? constraints.maxWidth : constraints.maxHeight;
        final availableSize = math.max(0.0, totalSize - widget.dividerThickness);

        final leadingExtent = _calculateLeadingExtent(availableSize);
        final trailingExtent = math.max(0.0, availableSize - leadingExtent);

        final divider = _buildDivider(context, isDark, dividerColor, primaryColor, availableSize);

        if (widget.axis == Axis.horizontal) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (leadingExtent > 0)
                SizedBox(
                  width: leadingExtent,
                  child: ClipRect(child: widget.leading),
                ),
              divider,
              if (trailingExtent > 0)
                Expanded(
                  child: ClipRect(child: widget.trailing),
                ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (leadingExtent > 0)
                SizedBox(
                  height: leadingExtent,
                  child: ClipRect(child: widget.leading),
                ),
              divider,
              if (trailingExtent > 0)
                Expanded(
                  child: ClipRect(child: widget.trailing),
                ),
            ],
          );
        }
      },
    );
  }

  Widget _buildDivider(
    BuildContext context,
    bool isDark,
    Color defaultDividerColor,
    Color activeColor,
    double totalAvailable,
  ) {
    final isHorizontal = widget.axis == Axis.horizontal;
    final cursor = isHorizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow;

    Color handleBg = Colors.transparent;
    if (_isDragging) {
      handleBg = activeColor.withValues(alpha: 0.15);
    } else if (_isHovered) {
      handleBg = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04);
    }

    final lineIndicator = Container(
      width: isHorizontal ? 1.0 : double.infinity,
      height: isHorizontal ? double.infinity : 1.0,
      color: (_isDragging || _isHovered) ? activeColor : defaultDividerColor,
    );

    return MouseRegion(
      cursor: cursor,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: _handleDoubleTap,
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) => _handleDragUpdate(details, totalAvailable),
        onPanEnd: (_) => setState(() => _isDragging = false),
        onPanCancel: () => setState(() => _isDragging = false),
        child: Container(
          width: isHorizontal ? widget.dividerThickness : double.infinity,
          height: isHorizontal ? double.infinity : widget.dividerThickness,
          color: handleBg,
          child: Stack(
            alignment: Alignment.center,
            children: [
              lineIndicator,
              if (widget.showGrip) _buildGrip(isHorizontal, isDark),
              if (widget.showCollapseButtons) _buildCollapseButtons(isHorizontal, activeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrip(bool isHorizontal, bool isDark) {
    final gripColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    if (isHorizontal) {
      return Center(
        child: Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: gripColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    } else {
      return Center(
        child: Container(
          width: 24,
          height: 4,
          decoration: BoxDecoration(
            color: gripColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }
  }

  Widget _buildCollapseButtons(bool isHorizontal, Color activeColor) {
    final isLeadingCollapsed = _controller.isLeadingCollapsed;
    final isTrailingCollapsed = _controller.isTrailingCollapsed;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.collapsibleLeading)
                InkWell(
                  onTap: () => _controller.toggleLeadingCollapse(),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      isHorizontal
                          ? (isLeadingCollapsed ? Icons.chevron_right : Icons.chevron_left)
                          : (isLeadingCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                      size: 14,
                      color: isLeadingCollapsed ? activeColor : null,
                    ),
                  ),
                ),
              if (widget.collapsibleTrailing)
                InkWell(
                  onTap: () => _controller.toggleTrailingCollapse(),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      isHorizontal
                          ? (isTrailingCollapsed ? Icons.chevron_left : Icons.chevron_right)
                          : (isTrailingCollapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                      size: 14,
                      color: isTrailingCollapsed ? activeColor : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
