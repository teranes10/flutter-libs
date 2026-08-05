import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TStepperType { horizontal, vertical }

/// A step in a [TStepper].
class TStep {
  /// The title of the step.
  final Widget title;

  /// The subtitle of the step.
  final Widget? subtitle;

  /// The content of the step when it is active.
  final Widget content;

  /// Optional icon to display instead of the step number.
  final Widget? icon;

  /// Whether the step is currently active.
  final bool isActive;

  /// Whether the step is completed.
  final bool isCompleted;

  /// Custom color for this step.
  final Color? color;

  const TStep({
    required this.title,
    this.subtitle,
    required this.content,
    this.icon,
    this.isActive = false,
    this.isCompleted = false,
    this.color,
  });
}

/// A Material Design stepper widget with Lexend font and TCard integration.
class TStepper extends StatelessWidget {
  /// The steps of the stepper.
  final List<TStep> steps;

  /// The index of the current step.
  final int currentStep;

  /// Callback fired when a step is tapped.
  final ValueChanged<int>? onStepTapped;

  /// Whether the stepper is horizontal or vertical.
  final TStepperType type;

  /// Custom theme color.
  final Color? color;

  /// Custom padding for the stepper content.
  final EdgeInsetsGeometry? contentPadding;

  /// Custom margin for the content [TCard]. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? contentMargin;

  /// Custom border for the content [TCard].
  final Color? contentBorder;

  /// When [true] in horizontal mode, the step title is placed **below**
  /// the indicator instead of beside it — better suited for mobile layouts.
  final bool? titleBelowIndicator;

  final double? indicatorSize;

  // Fixed layout constants for the horizontal "stacked" (mobile) row.
  static const double _connectorGap = 4;
  static const double _desktopConnectorWidth = 40;

  const TStepper({
    super.key,
    required this.steps,
    this.currentStep = 0,
    this.onStepTapped,
    this.type = TStepperType.vertical,
    this.color,
    this.contentPadding,
    this.contentMargin,
    this.contentBorder,
    this.titleBelowIndicator,
    this.indicatorSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return type == TStepperType.vertical ? _buildVerticalStepper(context) : _buildHorizontalStepper(context);
  }

  // ---------------------------------------------------------------------
  // Vertical layout
  // ---------------------------------------------------------------------

  Widget _buildVerticalStepper(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVerticalIndicatorColumn(context, index, isLast),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVerticalStepHeader(context, index),
                    if (index == currentStep)
                      Padding(
                        padding: contentPadding ?? const EdgeInsets.only(left: 12, right: 12, bottom: 24, top: 12),
                        child: TCard(
                          margin: contentMargin ?? EdgeInsets.zero,
                          borderColor: contentBorder,
                          child: steps[index].content,
                        ),
                      )
                    else if (!isLast)
                      const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildVerticalIndicatorColumn(BuildContext context, int index, bool isLast) {
    final size = indicatorSize ?? 32;

    return Column(
      children: [
        GestureDetector(
          onTap: () => onStepTapped?.call(index),
          child: _buildIndicator(context, index, size: size),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: _connectorColor(context, index < currentStep),
            ),
          ),
      ],
    );
  }

  Widget _buildVerticalStepHeader(BuildContext context, int index) {
    final colors = context.colors;
    final step = steps[index];
    final isActive = index == currentStep;

    return GestureDetector(
      onTap: () => onStepTapped?.call(index),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w400 : FontWeight.w300,
                color: isActive ? colors.onSurface : colors.onSurfaceVariant,
              ),
              child: step.title,
            ),
            if (step.subtitle != null) _buildSubtitle(context, step.subtitle!, TextAlign.start),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Horizontal layout
  // ---------------------------------------------------------------------

  Widget _buildHorizontalStepper(BuildContext context) {
    final isMobileLayout = titleBelowIndicator ?? context.isMobile;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: isMobileLayout ? _buildMobileStepRow(context, constraints.maxWidth) : _buildDesktopStepRow(context),
            );
          },
        ),
        const SizedBox(height: 24),
        TCard(
          margin: contentMargin ?? EdgeInsets.zero,
          padding: EdgeInsets.zero,
          borderColor: contentBorder ?? Colors.transparent,
          child: steps[currentStep].content,
        ),
      ],
    );
  }

  /// Stacked (indicator above title) layout for narrow/mobile screens.
  /// Connector segments are explicitly inset from each indicator's edge
  /// (radius + gap) so there's a visible gap, rather than relying on the
  /// circle to occlude the line underneath it.
  Widget _buildMobileStepRow(BuildContext context, double availableWidth) {
    final size = indicatorSize ?? 28;
    final radius = size / 2;
    final lineInset = radius + _connectorGap;

    // Calculate dynamic step widths based on text length
    final stepWidths = steps.map((s) => _calculateStepWidth(context, s)).toList();
    final totalWidth = stepWidths.reduce((r, x) => r + x);

    // Determine horizontal centers and final widths for each step's circular indicator
    final centers = <double>[];
    final finalWidths = <double>[];
    double currentX = 0;

    final shouldScale = totalWidth > availableWidth;

    for (int i = 0; i < steps.length; i++) {
      final stepWidth = shouldScale
          ? (stepWidths[i] / totalWidth) * availableWidth
          : stepWidths[i];

      finalWidths.add(stepWidth);
      centers.add(currentX + stepWidth / 2);
      currentX += stepWidth;
    }

    return SizedBox(
      width: shouldScale ? availableWidth : totalWidth,
      child: Stack(
        children: [
          // Draw connecting lines between centers
          for (var index = 0; index < steps.length - 1; index++)
            Positioned(
              top: radius - 1,
              left: centers[index] + lineInset,
              width: (centers[index + 1] - centers[index]) - 2 * lineInset,
              child: Container(
                height: 2,
                color: _connectorColor(context, index < currentStep),
              ),
            ),
          // Draw the columns side-by-side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              steps.length,
              (index) => SizedBox(
                width: finalWidths[index],
                child: _buildStepChip(context, index, stacked: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Indicator-beside-title layout for wider screens.
  Widget _buildDesktopStepRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var index = 0; index < steps.length; index++) ...[
          if (index > 0) _buildDesktopConnector(context, index - 1),
          _buildStepChip(context, index, stacked: false),
        ],
      ],
    );
  }

  Widget _buildStepChip(BuildContext context, int index, {required bool stacked}) {
    final size = indicatorSize ?? 28;
    final indicator = _buildIndicator(context, index, size: size);
    final text = _buildStepText(context, index, centerAlign: stacked);

    return GestureDetector(
      onTap: () => onStepTapped?.call(index),
      child: stacked
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [indicator, const SizedBox(height: 8), text],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [indicator, const SizedBox(width: 8), text],
            ),
    );
  }

  Widget _buildDesktopConnector(BuildContext context, int index) {
    return Container(
      width: _desktopConnectorWidth,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: _connectorColor(context, index < currentStep),
    );
  }

  // ---------------------------------------------------------------------
  // Shared building blocks
  // ---------------------------------------------------------------------

  Color _connectorColor(BuildContext context, bool completed) =>
      completed ? (color ?? context.colors.primary) : context.colors.outlineVariant;

  Widget _buildIndicator(BuildContext context, int index, {required double size}) {
    final colors = context.colors;
    final mColor = color ?? context.theme.primary;
    final step = steps[index];
    final isActive = index == currentStep;
    final isCompleted = index < currentStep;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted || isActive ? mColor : colors.surfaceContainerHighest,
        border: isActive ? Border.all(color: mColor.withAlpha(50), width: size >= 32 ? 4 : 3) : null,
      ),
      child: Center(
        child: step.icon ??
            (isCompleted
                ? Icon(Icons.check, size: size * 0.5625, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCompleted || isActive ? Colors.white : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: size * 0.4375,
                    ),
                  )),
      ),
    );
  }

  Widget _buildStepText(BuildContext context, int index, {required bool centerAlign}) {
    final colors = context.colors;
    final step = steps[index];
    final isActive = index == currentStep;
    final textAlign = centerAlign ? TextAlign.center : TextAlign.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            color: isActive ? colors.onSurface : colors.onSurfaceVariant,
          ),
          textAlign: textAlign,
          child: step.title,
        ),
        if (step.subtitle != null) _buildSubtitle(context, step.subtitle!, textAlign),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context, Widget subtitle, TextAlign textAlign) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 11, color: context.colors.onSurfaceVariant.withAlpha(150)),
        textAlign: textAlign,
        child: subtitle,
      ),
    );
  }

  double _calculateStepWidth(BuildContext context, TStep step) {
    final size = indicatorSize ?? 28;

    // Estimate title text width using TextPainter
    String titleText = '';
    if (step.title is Text) {
      titleText = (step.title as Text).data ?? '';
    } else {
      titleText = step.title.toString();
    }

    final titlePainter = TextPainter(
      text: TextSpan(
        text: titleText,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Lexend',
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    double maxTextWidth = titlePainter.width;

    // Estimate subtitle text width if present
    if (step.subtitle != null) {
      String subtitleText = '';
      if (step.subtitle is Text) {
        subtitleText = (step.subtitle as Text).data ?? '';
      }
      final subtitlePainter = TextPainter(
        text: TextSpan(
          text: subtitleText,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'Lexend',
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      maxTextWidth = math.max(maxTextWidth, subtitlePainter.width);
    }

    // Add double padding around estimated text width to prevent touching
    return math.max(size, maxTextWidth) + 32.0;
  }
}
