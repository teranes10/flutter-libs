import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page for Feedback widgets (Badge, Progress Bar, etc.).
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Feedback & Status',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Components that provide feedback, status updates, or notifications.',
            style: TextStyle(fontSize: 16, color: context.colors.onSurfaceVariant),
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
                TBadge(count: 5, child: Icon(Icons.mail, size: 30)),
                TBadge(count: 120, child: Icon(Icons.notifications, size: 30)),
                TBadge(
                  dot: true,
                  child: TAvatar(name: 'John Doe', size: TInputSize.sm),
                ),
                TBadge(
                  label: 'New',
                  color: context.theme.success,
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
            description: 'Displays task completion status with values and percentages',
            icon: Icons.trending_flat,
            preview: Column(
              children: [
                TProgressBar(value: 0.7, label: 'Standard Progress'),
                const SizedBox(height: 24),
                TProgressBar(
                  value: 0.05,
                  showPercentage: true,
                  valueText: '50 / 1000',
                  label: 'Storage Quota (Value & Percentage)',
                  color: context.theme.primary,
                ),
                const SizedBox(height: 24),
                TProgressBar(
                  value: 0.45,
                  showPercentage: true,
                  valueText: '450 / 1000 MB',
                  label: 'Bandwidth Limit',
                  color: context.theme.success,
                ),
                const SizedBox(height: 24),
                TProgressBar(value: 0.9, height: 4, label: 'Slim Variant', color: context.theme.info),
              ],
            ),
            code: '''// Progress bar with values (e.g. 50/1000) and percentage
TProgressBar(
  value: 0.05,
  showPercentage: true,
  valueText: '50 / 1000',
  label: 'Storage Quota',
)

// With unit values
TProgressBar(
  value: 0.45,
  showPercentage: true,
  valueText: '450 / 1000 MB',
  label: 'Bandwidth Limit',
)''',
            properties: const [
              PropertyDoc(name: 'value', type: 'double', description: 'Progress value from 0.0 to 1.0'),
              PropertyDoc(name: 'showPercentage', type: 'bool', defaultValue: 'false', description: 'Show percentage text'),
              PropertyDoc(name: 'valueText', type: 'String?', description: 'Custom value text (e.g. "50 / 1000")'),
              PropertyDoc(
                name: 'valuePosition',
                type: 'TProgressValuePosition',
                defaultValue: 'topRight',
                description:
                    'Position of value/percentage (topRight, topLeft, afterProgress, beforeProgress, bottomRight, bottomLeft, inside)',
              ),
              PropertyDoc(name: 'height', type: 'double', defaultValue: '8.0', description: 'Height of the bar'),
              PropertyDoc(name: 'color', type: 'Color?', description: 'Color of the progress indicator'),
              PropertyDoc(name: 'backgroundColor', type: 'Color?', description: 'Track background color'),
              PropertyDoc(name: 'label', type: 'String?', description: 'Label text'),
            ],
          ),

          // ==================== VALUE & PERCENTAGE POSITIONS ====================
          WidgetDocCard(
            title: 'Value & Percentage Positions',
            description: 'Control where percentage/value appears relative to the linear bar using TProgressValuePosition',
            icon: Icons.dashboard_customize,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. topRight (Default)
                TProgressBar(
                  value: 0.65,
                  showPercentage: true,
                  valueText: '650 / 1000',
                  valuePosition: TProgressValuePosition.topRight,
                  label: '1. Top Right (Default)',
                  color: context.theme.primary,
                ),
                const SizedBox(height: 22),

                // 2. topLeft
                TProgressBar(
                  value: 0.40,
                  showPercentage: true,
                  valueText: '400 / 1000 MB',
                  valuePosition: TProgressValuePosition.topLeft,
                  label: '2. Top Left:',
                  color: context.theme.info,
                ),
                const SizedBox(height: 22),

                // 3. afterProgress (Inline)
                TProgressBar(
                  value: 0.05,
                  showPercentage: true,
                  valueText: '50 / 1000',
                  valuePosition: TProgressValuePosition.afterProgress,
                  label: '3. After Progress (Inline)',
                  color: context.theme.success,
                ),
                const SizedBox(height: 22),

                // 4. beforeProgress (Inline)
                TProgressBar(
                  value: 0.85,
                  showPercentage: true,
                  valueText: '850 / 1000 MB',
                  valuePosition: TProgressValuePosition.beforeProgress,
                  label: '4. Before Progress (Inline)',
                  color: context.theme.warning,
                ),
                const SizedBox(height: 22),

                // 5. bottomRight
                TProgressBar(
                  value: 0.50,
                  showPercentage: true,
                  valueText: '500 / 1000 GB',
                  valuePosition: TProgressValuePosition.bottomRight,
                  label: '5. Bottom Right',
                  color: context.theme.primary,
                ),
                const SizedBox(height: 22),

                // 6. bottomLeft
                TProgressBar(
                  value: 0.30,
                  showPercentage: true,
                  valueText: '30 / 100 files',
                  valuePosition: TProgressValuePosition.bottomLeft,
                  label: '6. Bottom Left',
                  color: context.theme.secondary,
                ),
                const SizedBox(height: 22),

                // 7. inside
                TProgressBar(
                  value: 0.55,
                  height: 18,
                  showPercentage: true,
                  valueText: '55 / 100',
                  valuePosition: TProgressValuePosition.inside,
                  label: '7. Inside Bar (Custom Height)',
                  color: context.theme.success,
                ),
              ],
            ),
            code: '''// 1. Top Right (Default)
TProgressBar(
  value: 0.65,
  showPercentage: true,
  valueText: '650 / 1000',
  valuePosition: TProgressValuePosition.topRight,
  label: 'Top Right',
)

// 2. Top Left
TProgressBar(
  value: 0.40,
  showPercentage: true,
  valueText: '400 / 1000 MB',
  valuePosition: TProgressValuePosition.topLeft,
  label: 'Top Left:',
)

// 3. After Progress (Linear Before Percentage / Inline)
TProgressBar(
  value: 0.05,
  showPercentage: true,
  valueText: '50 / 1000',
  valuePosition: TProgressValuePosition.afterProgress,
  label: 'Tasks',
)

// 4. Before Progress (Percentage Before Linear / Inline)
TProgressBar(
  value: 0.85,
  showPercentage: true,
  valueText: '850 / 1000 MB',
  valuePosition: TProgressValuePosition.beforeProgress,
  label: 'Memory',
)

// 5. Bottom Right
TProgressBar(
  value: 0.50,
  showPercentage: true,
  valueText: '500 / 1000 GB',
  valuePosition: TProgressValuePosition.bottomRight,
  label: 'Disk Usage',
)

// 6. Bottom Left
TProgressBar(
  value: 0.30,
  showPercentage: true,
  valueText: '30 / 100 files',
  valuePosition: TProgressValuePosition.bottomLeft,
  label: 'Sync Progress',
)

// 7. Inside Bar
TProgressBar(
  value: 0.55,
  height: 18,
  showPercentage: true,
  valueText: '55 / 100',
  valuePosition: TProgressValuePosition.inside,
  label: 'Inside Bar',
)''',
            properties: const [
              PropertyDoc(
                name: 'valuePosition',
                type: 'TProgressValuePosition',
                defaultValue: 'TProgressValuePosition.topRight',
                description: 'Position: topRight, topLeft, afterProgress, beforeProgress, bottomRight, bottomLeft, inside',
              ),
              PropertyDoc(name: 'showPercentage', type: 'bool', defaultValue: 'false', description: 'Show calculated percentage text'),
              PropertyDoc(name: 'valueText', type: 'String?', description: 'Custom value text (e.g. "50 / 1000")'),
            ],
          ),

          // ==================== DYNAMIC COLOR BY PERCENTAGE ====================
          WidgetDocCard(
            title: 'Dynamic Color with colorBuilder',
            description: 'Dynamically shifts color based on progress value and percentage using colorBuilder',
            icon: Icons.palette,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TProgressBar(
                  value: 0.15,
                  showPercentage: true,
                  valueText: '15 / 100',
                  colorBuilder: (val, percent) => percent < 30
                      ? context.theme.danger
                      : percent < 70
                      ? context.theme.warning
                      : context.theme.success,
                  label: 'Low Completion (<30% Danger)',
                ),
                const SizedBox(height: 20),
                TProgressBar(
                  value: 0.52,
                  showPercentage: true,
                  valueText: '52 / 100',
                  colorBuilder: (val, percent) => percent < 30
                      ? context.theme.danger
                      : percent < 70
                      ? context.theme.warning
                      : context.theme.success,
                  label: 'Medium Completion (30-70% Warning)',
                ),
                const SizedBox(height: 20),
                TProgressBar(
                  value: 0.88,
                  showPercentage: true,
                  valueText: '88 / 100',
                  colorBuilder: (val, percent) => percent < 30
                      ? context.theme.danger
                      : percent < 70
                      ? context.theme.warning
                      : context.theme.success,
                  label: 'High Completion (>70% Success)',
                ),
                const SizedBox(height: 24),
                Text(
                  'Circular Progress with colorByPercentage:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.onSurface),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 28,
                  runSpacing: 16,
                  children: [
                    TCircularProgress(
                      value: 0.20,
                      size: 72,
                      showPercentage: true,
                      valueText: '20/100',
                      colorByPercentage: true,
                      label: 'Low (<30%)',
                    ),
                    TCircularProgress(
                      value: 0.55,
                      size: 72,
                      showPercentage: true,
                      valueText: '55/100',
                      colorByPercentage: true,
                      label: 'Medium (55%)',
                    ),
                    TCircularProgress(
                      value: 0.95,
                      size: 72,
                      showPercentage: true,
                      valueText: '95/100',
                      colorByPercentage: true,
                      label: 'High (>70%)',
                    ),
                  ],
                ),
              ],
            ),
            code: '''// Dynamic color using colorBuilder (receives value 0.0-1.0 and percentage 0.0-100.0):
TProgressBar(
  value: 0.15,
  showPercentage: true,
  colorBuilder: (value, percentage) => percentage < 30
      ? Colors.red
      : percentage < 70
          ? Colors.amber
          : Colors.green,
  label: 'Low (<30%)',
)

TProgressBar(
  value: 0.52,
  showPercentage: true,
  colorBuilder: (value, percentage) => percentage < 30
      ? Colors.red
      : percentage < 70
          ? Colors.amber
          : Colors.green,
  label: 'Medium (30-70%)',
)

TProgressBar(
  value: 0.88,
  showPercentage: true,
  colorBuilder: (value, percentage) => percentage < 30
      ? Colors.red
      : percentage < 70
          ? Colors.amber
          : Colors.green,
  label: 'High (>70%)',
)

// Circular Progress with colorByPercentage
TCircularProgress(
  value: 0.95,
  size: 72,
  showPercentage: true,
  valueText: '95/100',
  colorByPercentage: true,
)

// Custom threshold with colorBuilder
TProgressBar(
  value: 0.75,
  colorBuilder: (val, percent) => percent > 80 ? Colors.purple : Colors.teal,
)''',
            properties: const [
              PropertyDoc(
                name: 'colorBuilder',
                type: 'Color? Function(double value, double percentage)?',
                description: 'Custom function to dynamically compute color from progress value (0.0 to 1.0) and percentage (0.0 to 100.0)',
              ),
            ],
          ),

          // ==================== ANIMATED PROGRESS BAR ====================
          WidgetDocCard(
            title: 'Animated Progress',
            description: 'Progress bars with flowing and indeterminate animations',
            icon: Icons.auto_awesome,
            preview: Column(
              children: [
                TProgressBar(indeterminate: true, label: 'Indeterminate (Unknown Progress)', color: context.theme.primary),
                SizedBox(height: 24),
                TProgressBar(value: 0.65, flowing: true, label: 'Flowing Animation (Deterministic)', color: context.theme.warning),
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
              PropertyDoc(
                name: 'flowing',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to show a continuous shimmering effect',
              ),
            ],
          ),

          // ==================== CIRCULAR PROGRESS ====================
          WidgetDocCard(
            title: 'Circular Progress',
            description: 'Circular indicators with percentage and values inside/below the circle',
            icon: Icons.refresh,
            preview: Wrap(
              spacing: 36,
              runSpacing: 28,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Values below percentage inside circle
                TCircularProgress(
                  value: 0.05,
                  size: 96,
                  strokeWidth: 7,
                  showPercentage: true,
                  valueText: '50 / 1000',
                  label: 'Items Uploaded',
                  color: context.theme.primary,
                ),
                TCircularProgress(
                  value: 0.75,
                  size: 88,
                  strokeWidth: 6,
                  showPercentage: true,
                  valueText: '750 / 1000',
                  label: 'Storage',
                  color: context.theme.success,
                ),
                // Percentage inside circle with label below
                TCircularProgress(value: 0.50, size: 64, strokeWidth: 5, showPercentage: true, label: '50 / 1000 Completed'),
                // Compact percentage inside circle
                TCircularProgress(value: 0.4, size: 56, strokeWidth: 5, showPercentage: true, color: context.theme.warning),
                // Indeterminate spinner
                TCircularProgress(indeterminate: true, size: 36, strokeWidth: 3, label: 'Loading...'),
              ],
            ),
            code: '''// Value (e.g. 50 / 1000) below percentage inside circle
TCircularProgress(
  value: 0.05,
  size: 96,
  strokeWidth: 7,
  showPercentage: true,
  valueText: '50 / 1000',
  label: 'Items Uploaded',
)

// Success variant with value inside circle
TCircularProgress(
  value: 0.75,
  size: 88,
  strokeWidth: 6,
  showPercentage: true,
  valueText: '750 / 1000',
  label: 'Storage',
  color: context.theme.success,
)

// Percentage inside circle with value label below
TCircularProgress(
  value: 0.50,
  size: 64,
  showPercentage: true,
  label: '50 / 1000 Completed',
)''',
            properties: const [
              PropertyDoc(name: 'value', type: 'double', description: 'Progress value from 0.0 to 1.0'),
              PropertyDoc(name: 'indeterminate', type: 'bool', defaultValue: 'false', description: 'Whether the progress is unknown'),
              PropertyDoc(name: 'size', type: 'double', defaultValue: '40.0', description: 'Diameter of the circle'),
              PropertyDoc(name: 'strokeWidth', type: 'double', defaultValue: '4.0', description: 'Thickness of the progress line'),
              PropertyDoc(
                name: 'showPercentage',
                type: 'bool',
                defaultValue: 'false',
                description: 'Show percentage in the center of the circle',
              ),
              PropertyDoc(name: 'valueText', type: 'String?', description: 'Value text displayed below percentage inside circle'),
              PropertyDoc(name: 'label', type: 'String?', description: 'Label text displayed below the circular indicator'),
              PropertyDoc(name: 'center', type: 'Widget?', description: 'Custom center widget inside the circle'),
              PropertyDoc(name: 'color', type: 'Color?', description: 'Color of the progress circle'),
              PropertyDoc(name: 'backgroundColor', type: 'Color?', description: 'Track background circle color'),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
