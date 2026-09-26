import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Placement of the tour tooltip popover relative to the spotlighted target.
enum TTourPlacement {
  auto,
  top,
  bottom,
  left,
  right,
}

/// A single step in an onboarding or feature walkthrough [TTour].
class TTourStep {
  /// The global key of the widget to highlight with a spotlight cutout.
  final GlobalKey targetKey;

  /// Headline title for this tour step.
  final String title;

  /// Explanatory description text guiding the user.
  final String description;

  /// Optional icon shown in the card header.
  final IconData? icon;

  /// Preferred placement for the popover card. Defaults to [TTourPlacement.auto].
  final TTourPlacement placement;

  /// Padding around the spotlight cutout. Defaults to 8.0.
  final EdgeInsets spotlightPadding;

  /// Border radius for the spotlight cutout. Defaults to 8.0.
  final BorderRadius spotlightBorderRadius;

  const TTourStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.icon,
    this.placement = TTourPlacement.auto,
    this.spotlightPadding = const EdgeInsets.all(8.0),
    this.spotlightBorderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });
}

/// Controller to drive a [TTour] walkthrough programmatically.
class TTourController extends ChangeNotifier {
  int _currentStep = 0;
  bool _isActive = false;
  List<TTourStep> _steps = const [];

  int get currentStep => _currentStep;
  bool get isActive => _isActive;
  int get stepCount => _steps.length;
  TTourStep? get currentStepData => _isActive && _currentStep < _steps.length ? _steps[_currentStep] : null;

  void start(List<TTourStep> steps, {int initialStep = 0}) {
    if (steps.isEmpty) return;
    _steps = steps;
    _currentStep = initialStep.clamp(0, steps.length - 1);
    _isActive = true;
    notifyListeners();
  }

  void next() {
    if (!_isActive) return;
    if (_currentStep < _steps.length - 1) {
      _currentStep++;
      notifyListeners();
    } else {
      finish();
    }
  }

  void previous() {
    if (!_isActive) return;
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void skip() {
    if (!_isActive) return;
    _isActive = false;
    notifyListeners();
  }

  void finish() {
    if (!_isActive) return;
    _isActive = false;
    notifyListeners();
  }
}

/// An interactive guided tour overlay with spotlight cutout masks and anchored tooltips
/// for introducing new features and onboarding operators to admin interfaces.
class TTour extends StatefulWidget {
  /// The underlying page content.
  final Widget child;

  /// Controller driving the tour steps.
  final TTourController controller;

  /// Callback fired when the tour completes all steps.
  final VoidCallback? onFinish;

  /// Callback fired when the tour is skipped or dismissed.
  final VoidCallback? onSkip;

  const TTour({
    super.key,
    required this.child,
    required this.controller,
    this.onFinish,
    this.onSkip,
  });

  @override
  State<TTour> createState() => _TTourState();
}

class _TTourState extends State<TTour> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant TTour oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) setState(() {});
  }

  Rect? _getTargetRect(GlobalKey key, BuildContext context) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return null;

    final overlayBox = context.findRenderObject() as RenderBox?;
    if (overlayBox == null) return null;

    final globalPos = renderBox.localToGlobal(Offset.zero);
    final localPos = overlayBox.globalToLocal(globalPos);

    return localPos & renderBox.size;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (widget.controller.isActive && widget.controller.currentStepData != null)
          _buildTourOverlay(context),
      ],
    );
  }

  Widget _buildTourOverlay(BuildContext context) {
    final step = widget.controller.currentStepData!;
    final targetRect = _getTargetRect(step.targetKey, context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final paddedRect = targetRect != null
            ? Rect.fromLTRB(
                targetRect.left - step.spotlightPadding.left,
                targetRect.top - step.spotlightPadding.top,
                targetRect.right + step.spotlightPadding.right,
                targetRect.bottom + step.spotlightPadding.bottom,
              )
            : Rect.fromLTWH(constraints.maxWidth / 2 - 100, constraints.maxHeight / 2 - 50, 200, 100);

        return Stack(
          children: [
            // Spotlight Hole Mask
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Prevent click-through to background
                },
                child: CustomPaint(
                  painter: _SpotlightPainter(
                    spotlightRect: paddedRect,
                    borderRadius: step.spotlightBorderRadius,
                    overlayColor: Colors.black.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ),

            // Floating Tooltip Card
            _buildTooltipCard(context, step, paddedRect, constraints),
          ],
        );
      },
    );
  }

  Widget _buildTooltipCard(
    BuildContext context,
    TTourStep step,
    Rect targetRect,
    BoxConstraints constraints,
  ) {
    const cardWidth = 320.0;
    const cardMargin = 16.0;

    // Calculate card position based on placement
    double left = targetRect.center.dx - (cardWidth / 2);
    double top = targetRect.bottom + 12.0;

    // If bottom overflow, place above target
    if (top + 180 > constraints.maxHeight) {
      top = math.max(cardMargin, targetRect.top - 190.0);
    }

    // Clamp horizontally to stay inside screen
    left = left.clamp(cardMargin, constraints.maxWidth - cardWidth - cardMargin);

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLastStep = widget.controller.currentStep == widget.controller.stepCount - 1;

    return Positioned(
      left: left,
      top: top,
      width: cardWidth,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        color: theme.cardColor,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Icon, Title, and Step Indicator
              Row(
                children: [
                  if (step.icon != null) ...[
                    Icon(step.icon, size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      step.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${widget.controller.currentStep + 1} / ${widget.controller.stepCount}',
                    style: TextStyle(fontSize: 11, color: theme.hintColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                step.description,
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Action Buttons: Skip, Previous, Next / Finish
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      widget.controller.skip();
                      widget.onSkip?.call();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      child: Text('Skip Tour', style: TextStyle(fontSize: 12, color: theme.hintColor)),
                    ),
                  ),
                  const Spacer(),
                  if (widget.controller.currentStep > 0) ...[
                    TButton(
                      text: 'Back',
                      size: TSize.xs,
                      type: TButtonType.outline,
                      onTap: () => widget.controller.previous(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  TButton(
                    text: isLastStep ? 'Got It' : 'Next',
                    size: TSize.xs,
                    type: TButtonType.solid,
                    color: colors.primary,
                    onTap: () {
                      if (isLastStep) {
                        widget.controller.finish();
                        widget.onFinish?.call();
                      } else {
                        widget.controller.next();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect spotlightRect;
  final BorderRadius borderRadius;
  final Color overlayColor;

  _SpotlightPainter({
    required this.spotlightRect,
    required this.borderRadius,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = overlayColor;

    // Draw full background with a cutout for the target spotlight
    final screenPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final spotlightPath = Path()
      ..addRRect(
        borderRadius.toRRect(spotlightRect),
      );

    final combined = Path.combine(PathOperation.difference, screenPath, spotlightPath);
    canvas.drawPath(combined, bgPaint);

    // Subtle glowing outline around spotlight cutout
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(borderRadius.toRRect(spotlightRect), borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.spotlightRect != spotlightRect ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.overlayColor != overlayColor;
  }
}
