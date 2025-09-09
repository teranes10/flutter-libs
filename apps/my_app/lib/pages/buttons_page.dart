import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow('Solid Buttons', [
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
          ]),
          _buildRow('Tonal Buttons', [
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
          ]),
          _buildRow('Outline Buttons', [
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
          ]),
          _buildRow('Soft Outline Buttons', [
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
          ]),
          _buildRow('Filled Outline Buttons', [
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
          ]),
          _buildRow('Text Buttons', [
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
          ]),
          _buildRow('Soft Text Buttons', [
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
          ]),
          _buildRow('Filled Text Buttons', [
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
          ]),
          _buildRow('Icon Buttons', [
            TButton(type: TButtonType.icon, icon: Icons.remove_red_eye, color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.icon, icon: Icons.edit, color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.icon, icon: Icons.unarchive, color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.icon, icon: Icons.archive, color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.icon, icon: Icons.delete_forever, color: AppColors.danger, onPressed: (_) => {}),
          ]),
          _buildRow('Different Sizes', [
            TButton(icon: Icons.home, text: 'xxs', size: TButtonSize.xxs, onPressed: (_) => {}),
            TButton(icon: Icons.home, text: 'xs', size: TButtonSize.xs, onPressed: (_) => {}),
            TButton(icon: Icons.home, text: 'sm', size: TButtonSize.sm, onPressed: (_) => {}),
            TButton(icon: Icons.home, text: 'md', onPressed: (_) => {}),
            TButton(icon: Icons.home, text: 'lg', size: TButtonSize.lg, onPressed: (_) => {}),
            TButton(text: '150 * 75', width: 150, height: 75, onPressed: (_) => {}),
            TButton(text: '100 * 150', width: 100, height: 150, onPressed: (_) => {}),
            TButton(text: '150 * 150', width: 150, height: 150, onPressed: (_) => {}),
          ]),
          _buildRow('Loading State', [
            TButton(
              text: 'Auto Loading',
              loading: true,
              onPressed: (options) {
                Future.delayed(Duration(seconds: 2), () {
                  options.stopLoading();
                  _showSnackBar('Operation completed');
                });
              },
            ),
          ]),
          _buildRow('Solid Group', [
            TButtonGroup(
              type: TButtonGroupType.solid,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
              ],
            ),
          ]),
          _buildRow('Tonal Group', [
            TButtonGroup(
              type: TButtonGroupType.tonal,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
              ],
            ),
          ]),
          _buildRow('Outline Group', [
            TButtonGroup(
              type: TButtonGroupType.outline,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
              ],
            ),
          ]),
          _buildRow('Soft Outline Group', [
            TButtonGroup(
              type: TButtonGroupType.softOutline,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
              ],
            ),
          ]),
          _buildRow('Filled Outline Group', [
            TButtonGroup(
              type: TButtonGroupType.filledOutline,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
              ],
            ),
          ]),
          _buildRow('Text Group', [
            TButtonGroup(
              type: TButtonGroupType.text,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
              ],
            ),
          ]),
          _buildRow('Soft Text Group', [
            TButtonGroup(
              type: TButtonGroupType.softText,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
              ],
            ),
          ]),
          _buildRow('Filled Text Group', [
            TButtonGroup(
              type: TButtonGroupType.filledText,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
              ],
            ),
          ]),
          _buildRow('Icon Group', [
            TButtonGroup(
              type: TButtonGroupType.icon,
              items: [
                TButtonGroupItem(icon: Icons.remove_red_eye, color: AppColors.success, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.edit, color: AppColors.info, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.unarchive, color: AppColors.info, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.archive, color: AppColors.warning, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.delete_forever, color: AppColors.danger, onPressed: (_) => {}),
              ],
            ),
          ]),
          _buildRow('Boxed Group', [
            TButtonGroup(
              type: TButtonGroupType.boxed,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
              ],
            ),
          ]),
          _buildRow('Block Button', [TButton(text: 'Block Button', block: true, color: AppColors.success, onPressed: (_) => {})]),
          _buildRow("Circle Toggle Button", [
            CircleToggleButton(
              falseIcon: Icon(Icons.play_arrow, color: Colors.white),
              trueIcon: Icon(Icons.pause, color: Colors.white),
              falseBackground: Colors.green,
              trueBackground: Colors.red,
            )
          ])
        ],
      ),
    );
  }

  Widget _buildRow(String label, List<Widget> buttons) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: buttons,
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
