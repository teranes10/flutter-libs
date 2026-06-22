import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Layout Widgets', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildSection(
            'TGridRow & TGridCol',
            'A responsive 12-column grid system that adapts to screen breakpoints (sm, md, lg).',
            Column(
              children: [
                TGridRow(
                  gapX: 16,
                  gapY: 16,
                  children: [
                    _buildGridBox('Full Width (12)', sm: 12, md: 12, lg: 12),
                    _buildGridBox('Half (6)', sm: 12, md: 6, lg: 6),
                    _buildGridBox('Half (6)', sm: 12, md: 6, lg: 6),
                    _buildGridBox('Third (4)', sm: 12, md: 4, lg: 4),
                    _buildGridBox('Third (4)', sm: 12, md: 4, lg: 4),
                    _buildGridBox('Third (4)', sm: 12, md: 4, lg: 4),
                    _buildGridBox('Quarter (3)', sm: 6, md: 3, lg: 3),
                    _buildGridBox('Quarter (3)', sm: 6, md: 3, lg: 3),
                    _buildGridBox('Quarter (3)', sm: 6, md: 3, lg: 3),
                    _buildGridBox('Quarter (3)', sm: 6, md: 3, lg: 3),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSection(
            'TAlignedRow',
            'A row utility for aligning groups of widgets to the left and right with consistent spacing.',
            Column(
              children: [
                TCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 20,
                    children: [
                      TAlignedRow(
                        left: [
                          Icon(Icons.info_outline),
                          Text('Basic Left Aligned', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      TAlignedRow(
                        right: [Text('Basic Right Aligned'), Icon(Icons.arrow_forward)],
                        mainAxisAlignment: MainAxisAlignment.end,
                      ),
                      const Divider(),
                      TAlignedRow(
                        left: [TButton(type: TButtonType.softText, text: 'Back', icon: Icons.chevron_left, onTap: () {})],
                        right: [
                          TButton(text: 'Save Changes', icon: Icons.save, onTap: () {}),
                          TButton(type: TButtonType.tonal, text: 'Publish', icon: Icons.publish, onTap: () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildGridBox(String text, {int? sm, int? md, int? lg}) {
    return TGridCol(
      sm: sm,
      md: md,
      lg: lg,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(50),
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
