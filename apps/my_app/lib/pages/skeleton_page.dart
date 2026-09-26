import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation and showcase page for the [TSkeleton] widget.
class SkeletonPage extends StatefulWidget {
  const SkeletonPage({super.key});

  @override
  State<SkeletonPage> createState() => _SkeletonPageState();
}

class _SkeletonPageState extends State<SkeletonPage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with live toggle
          TAlignedRow(
            left: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skeleton Loaders',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Animated pulse and shimmer placeholders while content is loading.',
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            right: [
              TButton(
                type: _isLoading ? TButtonType.solid : TButtonType.tonal,
                icon: _isLoading ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                text: _isLoading ? 'Pause / Show Content' : 'Simulate Loading',
                onTap: () => setState(() => _isLoading = !_isLoading),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 1. Basic Shapes (Text, Circles, Rectangles)
          WidgetDocCard(
            title: 'Basic Shapes (Text, Circle, Rect)',
            description: 'Core primitive building blocks for atomic loading placeholders',
            icon: Icons.interests_outlined,
            preview: Wrap(
              spacing: 24,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Text Lines', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    const TSkeleton.text(width: 140),
                    const SizedBox(height: 6),
                    const TSkeleton.text(width: 200),
                    const SizedBox(height: 6),
                    const TSkeleton.text(width: 90),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Circles (Avatars)', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TSkeleton.circle(size: 32),
                        SizedBox(width: 8),
                        TSkeleton.circle(size: 44),
                        SizedBox(width: 8),
                        TSkeleton.circle(size: 56),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rectangles', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    const TSkeleton.rect(width: 100, height: 60),
                  ],
                ),
              ],
            ),
            code: '''// Text line skeleton
TSkeleton.text(width: 160)

// Circular avatar skeleton
TSkeleton.circle(size: 44)

// Rectangular container skeleton
TSkeleton.rect(width: 100, height: 60)''',
            properties: const [
              PropertyDoc(
                name: 'width',
                type: 'double?',
                description: 'Width of the skeleton placeholder',
              ),
              PropertyDoc(
                name: 'height',
                type: 'double?',
                description: 'Height of the skeleton placeholder',
              ),
              PropertyDoc(
                name: 'shape',
                type: 'BoxShape',
                defaultValue: 'BoxShape.rectangle',
                description: 'Shape of placeholder (rectangle or circle)',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Paragraph Lines
          WidgetDocCard(
            title: 'Multi-Line Paragraphs (TSkeleton.lines)',
            description: 'Simulates paragraphs of text with naturally varying last-line width factor',
            icon: Icons.format_align_left_rounded,
            preview: SizedBox(
              width: 380,
              child: TSkeleton.lines(count: 4, spacing: 10, lastLineWidthRatio: 0.55),
            ),
            code: '''TSkeleton.lines(
  count: 4,
  spacing: 10,
  lastLineWidthRatio: 0.55,
)''',
            properties: const [
              PropertyDoc(
                name: 'count',
                type: 'int',
                defaultValue: '3',
                description: 'Number of simulated text lines',
              ),
              PropertyDoc(
                name: 'lastLineWidthRatio',
                type: 'double',
                defaultValue: '0.65',
                description: 'Fractional width factor of the last line for realistic paragraph endings',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Card & Tile Skeletons
          WidgetDocCard(
            title: 'Card & Tile Skeletons (TSkeleton.card & TSkeleton.tile)',
            description: 'Ready-to-use composite placeholders matching TCard and TTile geometries',
            icon: Icons.view_agenda_outlined,
            preview: TGridRow(
              gapX: 16,
              gapY: 16,
              children: [
                TGridCol(
                  sm: 12,
                  md: 6,
                  child: TSkeleton.card(lines: 3),
                ),
                TGridCol(
                  sm: 12,
                  md: 6,
                  child: Card(
                    elevation: 0,
                    color: colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          TSkeleton.tile(size: TTileSize.h4, hasTrailing: true),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          TSkeleton.tile(size: TTileSize.h5, hasTrailing: true),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          TSkeleton.tile(size: TTileSize.h6),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            code: '''// Full card skeleton with avatar and lines
TSkeleton.card(lines: 3)

// TTile list item skeleton
TSkeleton.tile(size: TTileSize.h4, hasTrailing: true)''',
          ),
          const SizedBox(height: 24),

          // 4. Tabular Data Grid Skeleton
          WidgetDocCard(
            title: 'Table Data Grid Skeleton (TSkeleton.table)',
            description: 'Instant multi-row, multi-column skeleton for data tables and TCrudTable',
            icon: Icons.table_chart_outlined,
            preview: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: TSkeleton.table(rows: 4, columns: 4, rowHeight: 46),
            ),
            code: '''TSkeleton.table(
  rows: 4,
  columns: 4,
  rowHeight: 46,
  hasHeader: true,
)''',
          ),
          const SizedBox(height: 24),

          // 5. Interactive Conditional Wrapper
          WidgetDocCard(
            title: 'Conditional Wrapper State Transition',
            description: 'Wraps any widget tree and reveals real data when loading finishes',
            icon: Icons.swap_horiz_rounded,
            preview: Container(
              width: 360,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: _isLoading
                  ? TSkeleton.card(hasAvatar: true, lines: 2, padding: EdgeInsets.zero)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TAvatar(name: 'Sarah Connor', size: TInputSize.md),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sarah Connor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Engineering Manager',
                                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 8),
                              const TChip.tonal(text: 'Active Member', color: Colors.green),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            code: '''_isLoading
    ? TSkeleton.card(hasAvatar: true, lines: 2)
    : UserProfileView(user: user)''',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
