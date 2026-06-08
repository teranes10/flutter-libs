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

  const TStepper({
    super.key,
    required this.steps,
    this.currentStep = 0,
    this.onStepTapped,
    this.type = TStepperType.vertical,
    this.color,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    if (type == TStepperType.vertical) {
      return _buildVerticalStepper(context);
    } else {
      return _buildHorizontalStepper(context);
    }
  }

  Widget _buildVerticalStepper(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(context, index, isLast),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepHeader(context, index),
                    if (index == currentStep)
                      Padding(
                        padding: contentPadding ?? const EdgeInsets.only(left: 12, right: 12, bottom: 24, top: 12),
                        child: TCard(
                          margin: EdgeInsets.zero,
                          child: step.content,
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

  Widget _buildHorizontalStepper(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(steps.length, (index) {
              final isLast = index == steps.length - 1;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStepHeaderHorizontal(context, index),
                  if (!isLast)
                    Container(
                      width: 40,
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: index < currentStep ? (color ?? context.colors.primary) : context.colors.outlineVariant,
                    ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        TCard(
          child: steps[currentStep].content,
        ),
      ],
    );
  }

  Widget _buildStepIndicator(BuildContext context, int index, bool isLast) {
    final colors = context.colors;
    final theme = context.theme;
    final mColor = color ?? theme.primary;
    final isActive = index == currentStep;
    final isCompleted = index < currentStep;

    return Column(
      children: [
        GestureDetector(
          onTap: () => onStepTapped?.call(index),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted || isActive ? mColor : colors.surfaceContainerHighest,
              border: isActive ? Border.all(color: mColor.withAlpha(50), width: 4) : null,
            ),
            child: Center(
              child: steps[index].icon ??
                  (isCompleted
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCompleted || isActive ? Colors.white : colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )),
            ),
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: isCompleted ? mColor : colors.outlineVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildStepHeader(BuildContext context, int index) {
    final colors = context.colors;
    final step = steps[index];
    final isActive = index == currentStep;

    return GestureDetector(
      onTap: () => onStepTapped?.call(index),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? colors.onSurface : colors.onSurfaceVariant,
              ),
              child: step.title,
            ),
            if (step.subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant.withAlpha(150),
                  ),
                  child: step.subtitle!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeaderHorizontal(BuildContext context, int index) {
    final colors = context.colors;
    final theme = context.theme;
    final mColor = color ?? theme.primary;
    final step = steps[index];
    final isActive = index == currentStep;
    final isCompleted = index < currentStep;

    return GestureDetector(
      onTap: () => onStepTapped?.call(index),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted || isActive ? mColor : colors.surfaceContainerHighest,
            ),
            child: Center(
              child: step.icon ??
                  (isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCompleted || isActive ? Colors.white : colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? colors.onSurface : colors.onSurfaceVariant,
                ),
                child: step.title,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
