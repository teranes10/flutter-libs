import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page showcasing all TButton variants and features.
class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Button Components',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customizable button widgets with multiple variants, sizes, and states.',
            style: TextStyle(
              fontSize: 16,
              color: context.colors.onSurface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 32),

          // Solid Buttons
          WidgetDocCard(
            title: 'Solid Buttons',
            description: 'Filled buttons with solid background colors',
            icon: Icons.rectangle,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(type: TButtonType.solid, text: 'Primary', color: AppColors.primary, onTap: () {}),
                TButton(type: TButtonType.solid, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
                TButton(type: TButtonType.solid, text: 'Success', color: AppColors.success, onTap: () {}),
                TButton(type: TButtonType.solid, text: 'Danger', color: AppColors.danger, onTap: () {}),
              ],
            ),
            code: '''TButton(
  type: TButtonType.solid,
  text: 'Primary',
  color: AppColors.primary,
  onTap: () {},
)''',
            properties: const [
              PropertyDoc(
                name: 'type',
                type: 'TButtonType',
                defaultValue: 'TButtonType.solid',
                description: 'The visual variant of the button',
              ),
              PropertyDoc(
                name: 'text',
                type: 'String?',
                description: 'The text to display on the button',
              ),
              PropertyDoc(
                name: 'color',
                type: 'Color?',
                description: 'The primary color of the button',
              ),
              PropertyDoc(
                name: 'onTap',
                type: 'VoidCallback?',
                description: 'Callback fired when the button is tapped',
              ),
            ],
          ),

          // Tonal Buttons
          WidgetDocCard(
            title: 'Tonal Buttons',
            description: 'Buttons with subtle background tint',
            icon: Icons.palette,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(type: TButtonType.tonal, icon: Icons.home, text: 'Primary', color: AppColors.primary, onTap: () {}),
                TButton(type: TButtonType.tonal, icon: Icons.settings, text: 'Secondary', color: AppColors.secondary, onTap: () {}),
                TButton(type: TButtonType.tonal, icon: Icons.check, text: 'Success', color: AppColors.success, onTap: () {}),
                TButton(type: TButtonType.tonal, icon: Icons.warning, text: 'Warning', color: AppColors.warning, onTap: () {}),
              ],
            ),
            code: '''TButton(
  type: TButtonType.tonal,
  icon: Icons.home,
  text: 'Primary',
  color: AppColors.primary,
  onTap: () {},
)''',
            properties: const [
              PropertyDoc(
                name: 'icon',
                type: 'IconData?',
                description: 'The icon to display before the text',
              ),
            ],
          ),

          // Outline Buttons
          WidgetDocCard(
            title: 'Outline Buttons',
            description: 'Buttons with colored borders',
            icon: Icons.border_outer,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(type: TButtonType.outline, icon: Icons.add, text: 'Add', color: AppColors.primary, onTap: () {}),
                TButton(type: TButtonType.outline, icon: Icons.edit, text: 'Edit', color: AppColors.info, onTap: () {}),
                TButton(type: TButtonType.outline, icon: Icons.delete, text: 'Delete', color: AppColors.danger, onTap: () {}),
              ],
            ),
            code: '''TButton(
  type: TButtonType.outline,
  icon: Icons.add,
  text: 'Add',
  color: AppColors.primary,
  onTap: () {},
)''',
          ),

          // Icon Buttons
          WidgetDocCard(
            title: 'Icon Buttons',
            description: 'Compact icon-only buttons',
            icon: Icons.touch_app,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(type: TButtonType.icon, icon: Icons.visibility, color: AppColors.success, onTap: () {}),
                TButton(type: TButtonType.icon, icon: Icons.edit, color: AppColors.info, onTap: () {}),
                TButton(type: TButtonType.icon, icon: Icons.archive, color: AppColors.warning, onTap: () {}),
                TButton(type: TButtonType.icon, icon: Icons.delete_forever, color: AppColors.danger, onTap: () {}),
              ],
            ),
            code: '''TButton(
  type: TButtonType.icon,
  icon: Icons.visibility,
  color: AppColors.success,
  onTap: () {},
)''',
          ),

          // Button Sizes
          WidgetDocCard(
            title: 'Button Sizes',
            description: 'Different size options for buttons',
            icon: Icons.format_size,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TButton(text: 'XXS', size: TButtonSize.xxs, onTap: () {}),
                TButton(text: 'XS', size: TButtonSize.xs, onTap: () {}),
                TButton(text: 'SM', size: TButtonSize.sm, onTap: () {}),
                TButton(text: 'MD', size: TButtonSize.md, onTap: () {}),
                TButton(text: 'LG', size: TButtonSize.lg, onTap: () {}),
              ],
            ),
            code: '''TButton(
  text: 'Small',
  size: TButtonSize.sm,
  onTap: () {},
)

TButton(
  text: 'Medium',
  size: TButtonSize.md, // default
  onTap: () {},
)

TButton(
  text: 'Large',
  size: TButtonSize.lg,
  onTap: () {},
)''',
            properties: const [
              PropertyDoc(
                name: 'size',
                type: 'TButtonSize?',
                defaultValue: 'TButtonSize.md',
                description: 'The size configuration for the button. Available: xxs, xs, sm, md, lg, block',
              ),
            ],
          ),

          // Button Shapes
          WidgetDocCard(
            title: 'Button Shapes',
            description: 'Different shape options',
            icon: Icons.category,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(icon: Icons.home, text: 'Normal', shape: TButtonShape.normal, onTap: () {}),
                TButton(icon: Icons.home, text: 'Pill', shape: TButtonShape.pill, onTap: () {}),
                TButton(icon: Icons.home, shape: TButtonShape.circle, onTap: () {}),
              ],
            ),
            code: '''TButton(
  icon: Icons.home,
  text: 'Normal',
  shape: TButtonShape.normal,
  onTap: () {},
)

TButton(
  icon: Icons.home,
  text: 'Pill',
  shape: TButtonShape.pill,
  onTap: () {},
)

TButton(
  icon: Icons.home,
  shape: TButtonShape.circle, // icon only
  onTap: () {},
)''',
            properties: const [
              PropertyDoc(
                name: 'shape',
                type: 'TButtonShape?',
                defaultValue: 'TButtonShape.normal',
                description: 'The shape of the button. Options: normal, pill, circle',
              ),
            ],
          ),

          // Loading State
          WidgetDocCard(
            title: 'Loading State',
            description: 'Buttons with automatic loading indicator',
            icon: Icons.hourglass_empty,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TButton(
                  text: 'Submit Form',
                  icon: Icons.send,
                  loading: true,
                  color: AppColors.primary,
                  onPressed: (options) {
                    Future.delayed(const Duration(seconds: 2), () {
                      options.stopLoading();
                      _showSnackBar('Operation completed!');
                    });
                  },
                ),
              ],
            ),
            code: '''TButton(
  text: 'Submit Form',
  icon: Icons.send,
  loading: true, // Enable loading state
  color: AppColors.primary,
  onPressed: (options) async {
    // Perform async operation
    await submitForm();
    
    // Stop loading when done
    options.stopLoading();
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'loading',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether to show loading indicator when onPressed is called',
              ),
              PropertyDoc(
                name: 'loadingText',
                type: 'String',
                defaultValue: "'Loading...'",
                description: 'Text to display while loading',
              ),
              PropertyDoc(
                name: 'onPressed',
                type: 'Function(TButtonPressOptions)?',
                description: 'Callback with loading state control. Use options.stopLoading() to hide indicator',
              ),
            ],
          ),

          // Toggle Button
          WidgetDocCard(
            title: 'Toggle Button',
            description: 'Buttons that can be toggled between active/inactive states',
            icon: Icons.toggle_on,
            preview: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TButton(
                  shape: TButtonShape.circle,
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  color: Colors.grey,
                  activeColor: Colors.red,
                  onChanged: (isActive) => _showSnackBar('Favorite: $isActive'),
                ),
                TButton(
                  icon: Icons.notifications_none,
                  activeIcon: Icons.notifications_active,
                  text: 'Notifications',
                  color: AppColors.grey,
                  activeColor: AppColors.primary,
                  onChanged: (isActive) => _showSnackBar('Notifications: $isActive'),
                ),
              ],
            ),
            code: '''TButton(
  icon: Icons.favorite_border,
  activeIcon: Icons.favorite,
  color: Colors.grey,
  activeColor: Colors.red,
  onChanged: (isActive) {
    print('Active: \$isActive');
  },
)''',
            properties: const [
              PropertyDoc(
                name: 'active',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the button is in active state',
              ),
              PropertyDoc(
                name: 'activeIcon',
                type: 'IconData?',
                description: 'Icon to display when active. Falls back to icon if not provided',
              ),
              PropertyDoc(
                name: 'activeColor',
                type: 'Color?',
                description: 'Color to use when active. Falls back to color if not provided',
              ),
              PropertyDoc(
                name: 'onChanged',
                type: 'ValueChanged<bool>?',
                description: 'Callback fired when active state changes',
              ),
            ],
          ),

          // Button Group
          WidgetDocCard(
            title: 'Button Group',
            description: 'Group multiple buttons together',
            icon: Icons.view_week,
            preview: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TButtonGroup(
                  type: TButtonGroupType.solid,
                  items: [
                    TButtonGroupItem(icon: Icons.format_align_left, onTap: () {}),
                    TButtonGroupItem(icon: Icons.format_align_center, onTap: () {}),
                    TButtonGroupItem(icon: Icons.format_align_right, onTap: () {}),
                    TButtonGroupItem(icon: Icons.format_align_justify, onTap: () {}),
                  ],
                ),
              ],
            ),
            code: '''TButtonGroup(
  type: TButtonGroupType.solid,
  items: [
    TButtonGroupItem(
      icon: Icons.format_align_left,
      onTap: () {},
    ),
    TButtonGroupItem(
      icon: Icons.format_align_center,
      onTap: () {},
    ),
    TButtonGroupItem(
      icon: Icons.format_align_right,
      onTap: () {},
    ),
  ],
)''',
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
