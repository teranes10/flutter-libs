import 'package:flutter/material.dart';
import 'package:my_app/widgets/widget_documentation.dart';
import 'package:te_widgets/te_widgets.dart';

class TButtonDocumentationPage extends StatelessWidget {
  const TButtonDocumentationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetDocumentationPage(
      primaryColor: const Color(0xFF667eea),
      sections: [
        basicUsage(),
        buttonTypes(),
        buttonGroups(),
        buttonSizes(),
        buttonLoadingState(),
      ],
    );
  }
}

DocumentationSection basicUsage() {
  return DocumentationSection(
    id: 'basic-usage',
    title: 'Basic Usage',
    description: 'Simple button implementations with text and icons',
    icon: Icons.play_arrow,
    code: '''
TButton(
  text: 'Basic Button',
  onPressed: (options) {
    // Handle button press
    print('Button pressed!');
  },
)

TButton(
  type: TButtonType.solid,
  icon: Icons.download,
  text: 'Download',
  color: AppColors.success,
  onPressed: (options) {
    // Handle download
  },
)''',
    widget: Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        TButton(text: 'Basic Button', onPressed: (_) {}),
        TButton(type: TButtonType.solid, icon: Icons.download, text: 'Download', color: AppColors.success, onPressed: (_) {}),
        TButton(type: TButtonType.icon, icon: Icons.favorite, color: AppColors.danger, onPressed: (_) {}),
      ],
    ),
  );
}

DocumentationSection buttonTypes() {
  return DocumentationSection(
    id: 'button-types',
    title: 'Button Types',
    description: 'Explore different visual styles and variants',
    icon: Icons.palette,
    code: '''
// Solid button
TButton(
  type: TButtonType.solid,
  text: 'Solid Button',
  color: AppColors.primary,
  onPressed: (_) {},
)

// Outline button  
TButton(
  type: TButtonType.outline,
  text: 'Outline Button',
  color: AppColors.secondary,
  onPressed: (_) {},
)

// Tonal button
TButton(
  type: TButtonType.tonal,
  text: 'Tonal Button',
  color: AppColors.info,
  onPressed: (_) {},
)''',
    widget: Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        TButton(
          type: TButtonType.solid,
          text: 'Solid',
          color: AppColors.primary,
          onPressed: (_) {},
        ),
        TButton(
          type: TButtonType.outline,
          text: 'Outline',
          color: AppColors.secondary,
          onPressed: (_) {},
        ),
        TButton(
          type: TButtonType.tonal,
          text: 'Tonal',
          color: AppColors.info,
          onPressed: (_) {},
        ),
        TButton(
          type: TButtonType.text,
          text: 'Text',
          color: AppColors.success,
          onPressed: (_) {},
        ),
      ],
    ),
  );
}

DocumentationSection buttonGroups() {
  return DocumentationSection(
    id: 'button-groups',
    title: 'Button Groups',
    description: 'Group related buttons together',
    icon: Icons.view_column,
    code: '''
TButtonGroup(
  type: TButtonGroupType.solid,
  items: [
    TButtonGroupItem(
      icon: Icons.home,
      text: 'Home',
      color: AppColors.primary,
      onPressed: (_) {},
    ),
    TButtonGroupItem(
      icon: Icons.settings,
      text: 'Settings',
      color: AppColors.secondary,
      onPressed: (_) {},
    ),
  ],
)''',
    widget: TButtonGroup(
      type: TButtonGroupType.solid,
      items: [
        TButtonGroupItem(
          icon: Icons.home,
          text: 'Home',
          color: AppColors.primary,
          onPressed: (_) {},
        ),
        TButtonGroupItem(
          icon: Icons.settings,
          text: 'Settings',
          color: AppColors.secondary,
          onPressed: (_) {},
        ),
        TButtonGroupItem(
          icon: Icons.info,
          text: 'Info',
          color: AppColors.info,
          onPressed: (_) {},
        ),
      ],
    ),
  );
}

DocumentationSection buttonSizes() {
  return DocumentationSection(
    id: 'sizes',
    title: 'Sizes & Dimensions',
    description: 'Various button sizes and custom dimensions',
    icon: Icons.photo_size_select_large,
    code: '''
// Predefined sizes
TButton(text: 'Small', size: TButtonSize.sm, onPressed: (_) {}),
TButton(text: 'Medium', size: TButtonSize.md, onPressed: (_) {}),
TButton(text: 'Large', size: TButtonSize.lg, onPressed: (_) {}),

// Custom dimensions
TButton(
  text: 'Custom Size',
  size: TButtonSize.md.copyWith(
    minW: 200,
    minH: 60,
  ),
  onPressed: (_) {},
)''',
    widget: Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TButton(text: 'SM', size: TButtonSize.sm, onPressed: (_) {}),
        TButton(text: 'MD', onPressed: (_) {}),
        TButton(text: 'LG', size: TButtonSize.lg, onPressed: (_) {}),
        TButton(
          text: 'Custom',
          size: TButtonSize.md.copyWith(minW: 120, minH: 50),
          color: AppColors.warning,
          onPressed: (_) {},
        ),
      ],
    ),
  );
}

DocumentationSection buttonLoadingState() {
  return DocumentationSection(
    id: 'loading-states',
    title: 'Loading States',
    description: 'Auto-managed and manual loading states',
    icon: Icons.refresh,
    code: '''
TButton(
  text: 'Process Data',
  loading: true, // Auto-manage loading
  onPressed: (options) {
    Future.delayed(Duration(seconds: 2), () {
      options.stopLoading();
      // Show completion message
    });
  },
)''',
    widget: TButton(
      text: 'Start Processing',
      color: AppColors.info,
      loading: true,
      onPressed: (options) {
        Future.delayed(const Duration(seconds: 2), () {
          options.stopLoading();
        });
      },
    ),
  );
}
