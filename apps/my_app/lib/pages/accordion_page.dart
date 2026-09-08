import 'package:flutter/material.dart';
import 'package:my_app/widgets/widget_doc_card.dart';
import 'package:te_widgets/te_widgets.dart';

class AccordionPage extends StatelessWidget {
  const AccordionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accordion',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'A vertical list of collapsible items that allow users to manage information density.',
            style: TextStyle(fontSize: 16, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          WidgetDocCard(
            title: 'Basic Accordion',
            description: 'Standard collapsible section.',
            icon: Icons.view_headline,
            preview: const Column(
              children: [
                TAccordion(title: 'Accordion Item 1', content: Text('This is the content for the first item.')),
                SizedBox(height: 12),
                TAccordion(title: 'Accordion Item 2', content: Text('This is the content for the second item.')),
              ],
            ),
            code: '''TAccordion(
  title: 'Accordion Item 1',
  content: Text('Content here'),
)''',
            properties: const [
              PropertyDoc(name: 'title', type: 'String?', description: 'The title text'),
              PropertyDoc(name: 'content', type: 'Widget', description: 'The content displayed when expanded'),
              PropertyDoc(
                name: 'initiallyExpanded',
                type: 'bool',
                defaultValue: 'false',
                description: 'Whether the accordion starts expanded',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Configured Icon Background & Colors
          WidgetDocCard(
            title: 'Configurable Icon & Background Colors',
            description: 'Accordion with custom icon background colors, expanded states, padding, and border radius',
            icon: Icons.palette,
            preview: Column(
              children: [
                TAccordion(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'Manage your application preferences',
                  iconBackgroundColor: context.theme.primary.withAlpha(25),
                  expandedIconBackgroundColor: context.theme.primary,
                  iconColor: context.theme.primary,
                  expandedIconColor: Colors.white,
                  iconBorderRadius: BorderRadius.circular(10),
                  content: const Text('Here you can change your language, theme, and notifications settings.'),
                ),
                const SizedBox(height: 12),
                TAccordion(
                  icon: Icons.security,
                  title: 'Security & Privacy',
                  subtitle: 'Two-factor auth and active sessions',
                  iconBackgroundColor: context.theme.success.withAlpha(25),
                  expandedIconBackgroundColor: context.theme.success,
                  iconColor: context.theme.success,
                  expandedIconColor: Colors.white,
                  content: const Text('Manage your passwords, two-factor authentication, and active sessions.'),
                ),
                const SizedBox(height: 12),
                TAccordion(
                  icon: Icons.warning_amber_rounded,
                  title: 'Danger Zone',
                  subtitle: 'Irreversible account operations',
                  iconBackgroundColor: context.theme.danger.withAlpha(25),
                  expandedIconBackgroundColor: context.theme.danger,
                  iconColor: context.theme.danger,
                  expandedIconColor: Colors.white,
                  content: const Text('Permanently delete your account or transfer ownership.'),
                ),
              ],
            ),
            code: '''TAccordion(
  icon: Icons.settings,
  title: 'Settings',
  subtitle: 'Manage preferences',
  iconBackgroundColor: context.theme.primary.withAlpha(25),
  expandedIconBackgroundColor: context.theme.primary,
  iconColor: context.theme.primary,
  expandedIconColor: Colors.white,
  iconBorderRadius: BorderRadius.circular(10),
  content: Text('Content here'),
)''',
            properties: const [
              PropertyDoc(name: 'icon', type: 'dynamic', description: 'Leading icon (IconData, HugeIcon, or Widget)'),
              PropertyDoc(name: 'iconBackgroundColor', type: 'Color?', description: 'Container background color of the leading icon'),
              PropertyDoc(name: 'expandedIconBackgroundColor', type: 'Color?', description: 'Background color of icon container when expanded'),
              PropertyDoc(name: 'iconColor', type: 'Color?', description: 'Color of the leading icon'),
              PropertyDoc(name: 'expandedIconColor', type: 'Color?', description: 'Color of the leading icon when expanded'),
              PropertyDoc(name: 'iconBorderRadius', type: 'BorderRadius?', description: 'Border radius of the icon container'),
              PropertyDoc(name: 'iconPadding', type: 'EdgeInsetsGeometry?', description: 'Padding inside the icon container'),
              PropertyDoc(name: 'iconSize', type: 'double?', description: 'Size of the leading icon'),
            ],
          ),

          const SizedBox(height: 24),

          // Standalone TTile / TAccordionHeader
          WidgetDocCard(
            title: 'Standalone TTile (TTileHeader / TAccordionHeader)',
            description: 'The versatile tile component with icon container, title, subtitle, and trailing widget',
            icon: Icons.splitscreen,
            preview: Column(
              children: [
                TCard(
                  child: TTile(
                    icon: Icons.analytics_outlined,
                    iconBackgroundColor: context.theme.info.withAlpha(30),
                    iconColor: context.theme.info,
                    title: 'Real-time Analytics',
                    subtitle: 'Updated 2 minutes ago',
                    trailing: TBadge(label: 'Live', color: context.theme.success),
                  ),
                ),
                const SizedBox(height: 12),
                TCard(
                  child: TTile(
                    icon: Icons.cloud_done_rounded,
                    iconBackgroundColor: context.theme.success.withAlpha(30),
                    iconColor: context.theme.success,
                    title: 'Cloud Backup Complete',
                    subtitle: '5.2 GB synced to AWS S3',
                    trailing: const Icon(Icons.chevron_right, size: 20),
                  ),
                ),
              ],
            ),
            code: '''// Use standalone TTile / TAccordionHeader / TTileHeader anywhere:
TTile(
  icon: Icons.analytics_outlined,
  iconBackgroundColor: context.theme.info.withAlpha(30),
  iconColor: context.theme.info,
  title: 'Real-time Analytics',
  subtitle: 'Updated 2 minutes ago',
  trailing: TBadge(label: 'Live', color: context.theme.success),
)''',
            properties: const [
              PropertyDoc(name: 'title', type: 'String?', description: 'Title text'),
              PropertyDoc(name: 'subtitle', type: 'String?', description: 'Subtitle text'),
              PropertyDoc(name: 'icon', type: 'dynamic', description: 'Leading icon (IconData, HugeIcon, or Widget)'),
              PropertyDoc(name: 'iconBackgroundColor', type: 'Color?', description: 'Background of icon container'),
              PropertyDoc(name: 'trailing', type: 'Widget?', description: 'Optional trailing widget'),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
