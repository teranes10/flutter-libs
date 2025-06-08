import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/widgets/button/button.dart';
import 'package:te_widgets/widgets/button/button_config.dart';
import 'package:te_widgets/widgets/button/button_group.dart';

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow('Fill Buttons', [
            TButton(icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
          ]),
          _buildRow('Inverse Buttons', [
            TButton(type: TButtonType.inverse, icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(type: TButtonType.inverse, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(type: TButtonType.inverse, icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.inverse, icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.inverse, icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.inverse, icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(type: TButtonType.inverse, icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
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
          _buildRow('Outline Fill Buttons', [
            TButton(type: TButtonType.outlineFill, icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(type: TButtonType.outlineFill, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(type: TButtonType.outlineFill, icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.outlineFill, icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.outlineFill, icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.outlineFill, icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(type: TButtonType.outlineFill, icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
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
          _buildRow('Text Fill Buttons', [
            TButton(type: TButtonType.textFill, icon: Icons.home, text: 'Primary', color: AppColors.primary, onPressed: (_) => {}),
            TButton(type: TButtonType.textFill, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onPressed: (_) => {}),
            TButton(type: TButtonType.textFill, icon: Icons.home, text: 'Success', color: AppColors.success, onPressed: (_) => {}),
            TButton(type: TButtonType.textFill, icon: Icons.home, text: 'Info', color: AppColors.info, onPressed: (_) => {}),
            TButton(type: TButtonType.textFill, icon: Icons.home, text: 'Warning', color: AppColors.warning, onPressed: (_) => {}),
            TButton(type: TButtonType.textFill, icon: Icons.home, text: 'Danger', color: AppColors.danger, onPressed: (_) => {}),
            TButton(type: TButtonType.textFill, icon: Icons.home, text: 'Grey', color: AppColors.grey, onPressed: (_) => {}),
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
          _buildRow('Fill Group', [
            TButtonGroup(
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
          _buildRow('Inverse Group', [
            TButtonGroup(
              type: TButtonGroupType.inverse,
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
          _buildRow('Outline Fill Group', [
            TButtonGroup(
              type: TButtonGroupType.outlineFill,
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
          _buildRow('Text Fill Group', [
            TButtonGroup(
              type: TButtonGroupType.textFill,
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
