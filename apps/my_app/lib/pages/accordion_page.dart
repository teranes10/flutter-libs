import 'package:flutter/material.dart';
import 'package:my_app/widgets/widget_doc_card.dart';
import 'package:te_widgets/te_widgets.dart';

class AccordionPage extends StatelessWidget {
  const AccordionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
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
            style: TextStyle(fontSize: 16, color: context.colors.onSurface.withAlpha(179)),
          ),
          const SizedBox(height: 32),

          WidgetDocCard(
            title: 'Basic Accordion',
            description: 'Standard collapsible section.',
            icon: Icons.view_headline,
            preview: const Column(
              children: [
                TAccordion(title: 'Accordion Item 1', content: Text('This is the content for the first item.')),
                TAccordion(title: 'Accordion Item 2', content: Text('This is the content for the second item.')),
              ],
            ),
            code: '''TAccordion(
  title: 'Accordion Item 1',
  content: Text('Content here'),
)''',
            properties: const [
              PropertyDoc(name: 'title', type: 'String', description: 'The title text'),
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

          WidgetDocCard(
            title: 'Improved Accordion',
            description: 'Accordion with icon, title and subtitle.',
            icon: Icons.info_outline,
            preview: const Column(
              children: [
                TAccordion(
                  leading: Icons.settings,
                  title: 'Settings',
                  subtitle: 'Manage your application preferences',
                  content: Text('Here you can change your language, theme, and notifications settings.'),
                ),
                SizedBox(height: 12),
                TAccordion(
                  leading: Icons.security,
                  title: 'Security',
                  subtitle: 'Privacy and account protection',
                  content: Text('Manage your passwords, two-factor authentication, and active sessions.'),
                ),
              ],
            ),
            code: '''TAccordion(
  leading: Icons.settings,
  title: 'Settings',
  subtitle: 'Manage your application preferences',
  content: Text('Content here'),
)''',
            properties: const [
              PropertyDoc(name: 'leading', type: 'IconData?', description: 'Optional icon before the title'),
              PropertyDoc(name: 'subtitle', type: 'String?', description: 'Optional subtitle text below the title'),
            ],
          ),
        ],
      ),
    );
  }
}
