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
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
            TButton(type: TButtonType.solid, icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
          ]),
          _buildRow('Tonal Buttons', [
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
            TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
          ]),
          _buildRow('Outline Buttons', [
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
            TButton(type: TButtonType.outline, icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
          ]),
          _buildRow('Soft Outline Buttons', [
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
            TButton(type: TButtonType.softOutline, icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
          ]),
          _buildRow('Filled Outline Buttons', [
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
            TButton(type: TButtonType.filledOutline, icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
          ]),
          _buildRow('Text Buttons', [
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
            TButton(type: TButtonType.text, icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
          ]),
          _buildRow('Soft Text Buttons', [
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
            TButton(type: TButtonType.softText, icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
          ]),
          _buildRow('Filled Text Buttons', [
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
            TButton(type: TButtonType.filledText, icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
          ]),
          _buildRow('Icon Buttons', [
            TButton(type: TButtonType.icon, icon: Icons.remove_red_eye, color: AppColors.success, onTap: () {}),
            TButton(type: TButtonType.icon, icon: Icons.edit, color: AppColors.info, onTap: () {}),
            TButton(type: TButtonType.icon, icon: Icons.unarchive, color: AppColors.info, onTap: () {}),
            TButton(type: TButtonType.icon, icon: Icons.archive, color: AppColors.warning, onTap: () {}),
            TButton(type: TButtonType.icon, icon: Icons.delete_forever, color: AppColors.danger, onTap: () {}),
          ]),
          _buildRow('Different Sizes', [
            TButton(icon: Icons.home, text: 'xxs', size: TButtonSize.xxs, onTap: () {}),
            TButton(icon: Icons.home, text: 'xs', size: TButtonSize.xs, onTap: () {}),
            TButton(icon: Icons.home, text: 'sm', size: TButtonSize.sm, onTap: () {}),
            TButton(icon: Icons.home, text: 'md', onTap: () {}),
            TButton(icon: Icons.home, text: 'lg', size: TButtonSize.lg, onTap: () {}),
            TButton(text: '150 * 75', size: TButtonSize.md.copyWith(minW: 150, minH: 75), onTap: () {}),
            TButton(text: '100 * 150', size: TButtonSize.md.copyWith(minW: 100, minH: 150), onTap: () {}),
            TButton(text: '150 * 150', size: TButtonSize.md.copyWith(minW: 150, minH: 150), onTap: () {}),
          ]),
          _buildRow('Different Shapes', [
            TButton(icon: Icons.home, text: 'Normal', shape: TButtonShape.normal, onTap: () {}),
            TButton(icon: Icons.home, text: 'Pill', shape: TButtonShape.pill, onTap: () {}),
            TButton(icon: Icons.home, shape: TButtonShape.circle, onTap: () {}),
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
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
              ],
            ),
          ]),
          _buildRow('Tonal Group', [
            TButtonGroup(
              type: TButtonGroupType.tonal,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
              ],
            ),
          ]),
          _buildRow('Outline Group', [
            TButtonGroup(
              type: TButtonGroupType.outline,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
              ],
            ),
          ]),
          _buildRow('Soft Outline Group', [
            TButtonGroup(
              type: TButtonGroupType.softOutline,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
              ],
            ),
          ]),
          _buildRow('Filled Outline Group', [
            TButtonGroup(
              type: TButtonGroupType.filledOutline,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
              ],
            ),
          ]),
          _buildRow('Text Group', [
            TButtonGroup(
              type: TButtonGroupType.text,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
              ],
            ),
          ]),
          _buildRow('Soft Text Group', [
            TButtonGroup(
              type: TButtonGroupType.softText,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
              ],
            ),
          ]),
          _buildRow('Filled Text Group', [
            TButtonGroup(
              type: TButtonGroupType.filledText,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
              ],
            ),
          ]),
          _buildRow('Icon Group', [
            TButtonGroup(
              type: TButtonGroupType.icon,
              items: [
                TButtonGroupItem(icon: Icons.remove_red_eye, color: AppColors.success, onTap: () {}),
                TButtonGroupItem(icon: Icons.edit, color: AppColors.info, onTap: () {}),
                TButtonGroupItem(icon: Icons.unarchive, color: AppColors.info, onTap: () {}),
                TButtonGroupItem(icon: Icons.archive, color: AppColors.warning, onTap: () {}),
                TButtonGroupItem(icon: Icons.delete_forever, color: AppColors.danger, onTap: () {}),
              ],
            ),
          ]),
          _buildRow('Boxed Group', [
            TButtonGroup(
              type: TButtonGroupType.boxed,
              items: [
                TButtonGroupItem(icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Success', color: AppColors.success, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Info', color: AppColors.info, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Warning', color: AppColors.warning, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Danger', color: AppColors.danger, onTap: () {}),
                TButtonGroupItem(icon: Icons.home, text: 'Grey', color: AppColors.grey, onTap: () {}),
              ],
            ),
          ]),
          _buildRow('Block Button', [TButton(text: 'Block Button', size: TButtonSize.block, color: AppColors.success, onTap: () {})]),
          _buildRow("Toggle Button", [
            TButton(
              shape: TButtonShape.circle,
              icon: Icons.play_arrow,
              activeIcon: Icons.pause,
              color: Colors.green,
              activeColor: Colors.red,
              onChanged: (v) {},
            ),
          ]),
          _buildRow("Image Button", [
            TButton(
              shape: TButtonShape.pill,
              size: TButtonSize.lg,
              imageUrl: '',
              text: 'Image',
              onTap: () {},
            ),
          ]),
          _buildRow("Custom", [
            TButton.custom(
              onTap: () {},
              child: Container(
                width: 100,
                height: 100,
                color: Colors.amber,
              ),
            ),
          ]),
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
