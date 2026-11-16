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
                  child: Column(spacing: 20, children: [..._alignedRowSamples()]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  static Widget _chip(String t) => TChip(text: t);

  static Widget _sample(String title, double? width, Widget row) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      Container(
        width: width,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: .4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: row,
      ),
    ],
  );

  static List<Widget> _alignedRowSamples() {
    List<Widget> items(String p, int n) => [for (var i = 1; i <= n; i++) _chip('$p $i')];
    return [
      _sample('Left only', null, TAlignedRow(left: items('L', 2))),
      _sample('Right only', null, TAlignedRow(right: items('R', 2))),
      _sample('Center only', null, TAlignedRow(center: items('C', 2))),
      _sample('Left + Right (fits one row)', null, TAlignedRow(left: items('L', 2), right: items('R', 2))),
      _sample('Left + Center', null, TAlignedRow(left: items('L', 2), center: items('C', 2))),
      _sample('Center + Right', null, TAlignedRow(center: items('C', 2), right: items('R', 2))),
      _sample('Left + Center + Right (fits one row)', null, TAlignedRow(left: items('L', 2), center: items('C', 2), right: items('R', 2))),
      _sample(
        'Left + Right, narrow, moveAllToSecondRow: true (all right items move down)',
        200,
        TAlignedRow(moveAllToSecondRow: true, left: items('Left', 2), right: items('Right', 2)),
      ),
      _sample(
        'Left + Right, narrow, moveAllToSecondRow: false (default, only overflow moves down)',
        200,
        TAlignedRow(moveAllToSecondRow: false, left: items('Left', 2), right: items('Right', 2)),
      ),
      _sample(
        'Left + Center + Right, narrow (3 rows, one per group)',
        200,
        TAlignedRow(left: items('Left', 1), center: items('Center', 1), right: items('Right', 1)),
      ),
      _sample(
        'Left only, too narrow -> wrapper mode (threshold 1)',
        200,
        TAlignedRow(left: items('Item', 5), wrapperAlignment: MainAxisAlignment.start),
      ),
      _sample('Left + Right, many items -> wrapper mode (threshold 2)', 200, TAlignedRow(left: items('Left', 3), right: items('Right', 3))),
      _sample(
        'Wrapper mode, expanded (ratio based)',
        200,
        TAlignedRow(wrapperExpanded: true, left: items('Left', 3), center: items('Mid', 2), right: items('Right', 2)),
      ),
      _sample(
        'Wrapper mode, expanded (equal slots)',
        200,
        TAlignedRow(
          wrapperExpanded: true,
          wrapperExpandedRatioBased: false,
          left: items('Left', 3),
          center: items('Mid', 2),
          right: items('Right', 2),
        ),
      ),
      _sample(
        'Explicit wrapperModeThreshold: 1 on left + right',
        200,
        TAlignedRow(wrapperModeThreshold: 1, left: items('Left', 2), right: items('Right', 2)),
      ),
      _sample(
        'Buttons: Back / title / actions',
        null,
        TAlignedRow(
          left: [TButton(type: TButtonType.softText, text: 'Back', icon: HugeIcons.strokeRoundedArrowLeft01, onTap: () {})],
          center: [const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.bold))],
          right: [
            TButton(text: 'Save Changes', icon: HugeIcons.strokeRoundedFloppyDisk, onTap: () {}),
            TButton(type: TButtonType.tonal, text: 'Publish', icon: HugeIcons.strokeRoundedBlinds, onTap: () {}),
          ],
        ),
      ),
    ];
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
