import 'package:flutter/material.dart';
import 'package:my_app/navigation.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/widgets/widget_doc_card.dart';

/// Documentation page for Breadcrumbs.
class BreadcrumbsPage extends StatelessWidget {
  const BreadcrumbsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Text(
            'Breadcrumbs',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Navigation aid that helps users keep track of their location within the application.',
            style: TextStyle(fontSize: 16, color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          // Basic Breadcrumbs
          WidgetDocCard(
            title: 'Basic Breadcrumbs',
            description: 'Automatically generated from sidebar items and current route',
            icon: Icons.linear_scale,
            preview: TBreadcrumbs(items: sidebarItems),
            code: '''TBreadcrumbs(
  items: sidebarItems,
)''',
            properties: const [
              PropertyDoc(name: 'items', type: 'List<TSidebarItem>', description: 'Sidebar items used to map routes to labels'),
              PropertyDoc(name: 'includeHome', type: 'bool', defaultValue: 'true', description: 'Whether to show the home link'),
              PropertyDoc(name: 'separator', type: 'Widget', description: 'Widget placed between items'),
            ],
          ),

          // Custom Style
          WidgetDocCard(
            title: 'Custom Style',
            description: 'Customized colors and separators',
            icon: Icons.palette,
            preview: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: context.colors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
              child: TBreadcrumbs(
                items: sidebarItems,
                activeColor: Colors.orange,
                separator: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('/', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
            code: '''TBreadcrumbs(
  items: sidebarItems,
  activeColor: Colors.orange,
  separator: Padding(
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Text('/', style: TextStyle(color: Colors.grey)),
  ),
)''',
          ),

          // Dynamic paths
          WidgetDocCard(
            title: 'Dynamic Paths',
            description: 'Use tGo extension to provide labels for multi-segment paths',
            icon: Icons.account_tree,
            preview: Wrap(
              spacing: 8,
              children: [
                TButton(
                  text: 'Electronics / Phones / iPhone',
                  onPressed: (_) => context.tGo(
                    '/explorer/electronics/phones/iphone',
                    labels: {'electronics': 'Gadgets', 'phones': 'Smartphones', 'iphone': 'iPhone 15 Pro'},
                    push: true,
                  ),
                ),
              ],
            ),
            code: '''// Route definition: /explorer/:path*

// Using tGo extension for multi-segment labels
context.tGo(
  '/explorer/electronics/phones/iphone',
  labels: {
    'electronics': 'Gadgets',
    'phones': 'Smartphones',
    'iphone': 'iPhone 15 Pro'
  },
);

// TBreadcrumbs will match segments to keys in the labels map.''',
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
