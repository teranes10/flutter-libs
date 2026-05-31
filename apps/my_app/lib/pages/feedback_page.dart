import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page for Feedback widgets (Badge, Progress Bar, etc.).
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Feedback & Status',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Components that provide feedback, status updates, or notifications.',
            style: TextStyle(
              fontSize: 16,
              color: context.colors.onSurface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 32),

          // ==================== BADGE ====================

          WidgetDocCard(
            title: 'Badge',
            description: 'Small status or numerical indicator',
            icon: Icons.notifications,
            preview: Wrap(
              spacing: 32,
              runSpacing: 16,
              children: [
                TBadge(
                  count: 5,
                  child: Icon(Icons.mail, size: 30),
                ),
                TBadge(
                  count: 120,
                  child: Icon(Icons.notifications, size: 30),
                ),
                TBadge(
                  dot: true,
                  child: TAvatar(name: 'John Doe', size: TInputSize.sm),
                ),
                TBadge(
                  label: 'New',
                  color: AppColors.success,
                  child: TButton(text: 'Features', size: TButtonSize.sm),
                ),
              ],
            ),
            code: '''TBadge(
  count: 5,
  child: Icon(Icons.mail),
)

TBadge(
  dot: true,
  child: TAvatar(name: 'JD'),
)''',
            properties: const [
              PropertyDoc(name: 'count', type: 'int?', description: 'Numerical value to display'),
              PropertyDoc(name: 'dot', type: 'bool', defaultValue: 'false', description: 'Show a small dot instead of count'),
              PropertyDoc(name: 'maxCount', type: 'int', defaultValue: '99', description: 'Maximum count before showing "+"'),
              PropertyDoc(name: 'color', type: 'Color?', description: 'Background color of the badge'),
            ],
          ),

          // ==================== PROGRESS BAR ====================

          WidgetDocCard(
            title: 'Progress Bar',
            description: 'Displays task completion status',
            icon: Icons.trending_flat,
            preview: Column(
              children: [
                TProgressBar(
                  value: 0.7,
                  label: 'Standard Progress',
                ),
                const SizedBox(height: 24),
                TProgressBar(
                  value: 0.45,
                  showPercentage: true,
                  label: 'With Percentage',
                  color: AppColors.success,
                ),
                const SizedBox(height: 24),
                TProgressBar(
                  value: 0.9,
                  height: 4,
                  label: 'Slim Variant',
                  color: AppColors.info,
                ),
              ],
            ),
            code: '''TProgressBar(
  value: 0.7,
  label: 'Uploading...',
  showPercentage: true,
)''',
            properties: const [
              PropertyDoc(name: 'value', type: 'double', description: 'Progress value from 0.0 to 1.0'),
              PropertyDoc(name: 'showPercentage', type: 'bool', defaultValue: 'false', description: 'Show percentage text'),
              PropertyDoc(name: 'height', type: 'double', defaultValue: '8.0', description: 'Height of the bar'),
              PropertyDoc(name: 'color', type: 'Color?', description: 'Color of the progress indicator'),
            ],
          ),

          // ==================== ANIMATED PROGRESS BAR ====================

          WidgetDocCard(
            title: 'Animated Progress',
            description: 'Progress bars with flowing and indeterminate animations',
            icon: Icons.auto_awesome,
            preview: const Column(
              children: [
                TProgressBar(
                  indeterminate: true,
                  label: 'Indeterminate (Unknown Progress)',
                  color: AppColors.primary,
                ),
                SizedBox(height: 24),
                TProgressBar(
                  value: 0.65,
                  flowing: true,
                  label: 'Flowing Animation (Deterministic)',
                  color: AppColors.warning,
                ),
              ],
            ),
            code: '''// Indeterminate state
TProgressBar(
  indeterminate: true,
  label: 'Processing...',
)

// Flowing animation on fixed value
TProgressBar(
  value: 0.65,
  flowing: true,
  label: 'Loading...',
)''',
            properties: const [
              PropertyDoc(
                name: 'indeterminate',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the progress is in an unknown state',
              ),
              PropertyDoc(name: 'flowing', type: 'bool', defaultValue: 'false', description: 'Whether to show a continuous shimmering effect'),
            ],
          ),

          // ==================== CIRCULAR PROGRESS ====================

          WidgetDocCard(
            title: 'Circular Progress',
            description: 'Circular indicators for progress and loading',
            icon: Icons.refresh,
            preview: const Wrap(
              spacing: 32,
              runSpacing: 24,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TCircularProgress(
                  value: 0.75,
                  showPercentage: true,
                  label: 'Completed',
                ),
                TCircularProgress(
                  indeterminate: true,
                  size: 30,
                  label: 'Loading...',
                ),
                TCircularProgress(
                  value: 0.4,
                  size: 60,
                  strokeWidth: 8,
                  showPercentage: true,
                  color: AppColors.danger,
                ),
                TCircularProgress(
                  value: 0.9,
                  size: 24,
                  strokeWidth: 2,
                  color: AppColors.success,
                ),
              ],
            ),
            code: '''// Fixed value with percentage
TCircularProgress(
  value: 0.75,
  showPercentage: true,
)

// Indeterminate spinner
TCircularProgress(
  indeterminate: true,
)

// Custom size and stroke
TCircularProgress(
  value: 0.4,
  size: 60,
  strokeWidth: 8,
)''',
            properties: const [
              PropertyDoc(name: 'value', type: 'double', description: 'Progress value from 0.0 to 1.0'),
              PropertyDoc(name: 'indeterminate', type: 'bool', defaultValue: 'false', description: 'Whether the progress is unknown'),
              PropertyDoc(name: 'size', type: 'double', defaultValue: '40.0', description: 'Diameter of the circle'),
              PropertyDoc(name: 'strokeWidth', type: 'double', defaultValue: '4.0', description: 'Thickness of the progress line'),
              PropertyDoc(name: 'showPercentage', type: 'bool', defaultValue: 'false', description: 'Show percentage in the center'),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
