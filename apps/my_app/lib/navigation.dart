import 'package:flutter/material.dart';
import 'package:my_app/pages/accordion_page.dart';
import 'package:my_app/pages/dropdown_sample_page.dart';
import 'package:my_app/pages/colors_page.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/pages/avatars_page.dart';
import 'package:my_app/pages/breadcrumbs_page.dart';
import 'package:my_app/pages/buttons_page.dart';
import 'package:my_app/pages/chips_page.dart';
import 'package:my_app/pages/crud_page.dart';
import 'package:my_app/pages/editor_page.dart';
import 'package:my_app/pages/forms_page.dart';
import 'package:my_app/pages/feedback_page.dart';
import 'package:my_app/pages/grid_page.dart';
import 'package:my_app/pages/input_fields_page.dart';
import 'package:my_app/pages/pickers_page.dart';
import 'package:my_app/pages/popups_page.dart';
import 'package:my_app/pages/select_fields_page.dart';
import 'package:my_app/pages/tables_page.dart';
import 'package:my_app/pages/cursor_pagination_page.dart';
import 'package:my_app/pages/tabs_page.dart';

final sidebarItems = [
  TSidebarItem(icon: Icons.text_fields, text: 'Input Fields', route: '/input-fields', page: const InputFieldsPage()),
  TSidebarItem(icon: Icons.check_box, text: 'Select Fields', route: '/select-fields', page: const SelectFieldsPage()),
  TSidebarItem(icon: Icons.calendar_month, text: 'Pickers', route: '/pickers', page: const PickersPage()),
  TSidebarItem(icon: Icons.smart_button, text: 'Buttons', route: '/buttons', page: const ButtonsPage()),
  TSidebarItem(icon: Icons.label, text: 'Chips', route: '/chips', page: const ChipsPage()),
  TSidebarItem(icon: Icons.account_circle, text: 'Avatars', route: '/avatars', page: const AvatarsPage()),
  TSidebarItem(icon: Icons.linear_scale, text: 'Breadcrumbs', route: '/breadcrumbs', page: const BreadcrumbsPage()),
  TSidebarItem(icon: Icons.feedback, text: 'Feedback', route: '/feedback', page: const FeedbackPage()),
  TSidebarItem(
    icon: Icons.explore,
    text: 'Explorer',
    route: '/explorer/:path(.*)',
    builder: (context, state) => PlaceholderPage(title: 'Path: ${state.pathParameters['path']}'),
    hidden: true,
  ),
  TSidebarItem(icon: Icons.tab, text: 'Tabs', route: '/tabs', page: const TabsPage()),
  TSidebarItem(icon: Icons.message, text: 'Popups', route: '/popups', page: const PopupsPage()),
  TSidebarItem(icon: Icons.table_chart, text: 'Tables', route: '/tables', page: const TablesPage()),
  TSidebarItem(icon: Icons.navigate_next, text: 'Cursor Pagination', route: '/cursor-pagination', page: const CursorPaginationPage()),
  TSidebarItem(icon: Icons.grid_view, text: 'Grid', route: '/grid', page: const GridPage()),
  TSidebarItem(icon: Icons.storage, text: 'Crud', route: '/crud', page: const CrudPage()),
  TSidebarItem(icon: Icons.edit_note, text: 'Editor', route: '/editor', page: const EditorPage()),
  TSidebarItem(icon: Icons.assignment, text: 'Forms', route: '/forms', page: const FormsPage()),
  TSidebarItem(icon: Icons.arrow_drop_down_circle, text: 'Dropdown', route: '/dropdown', page: const DropdownSamplePage()),
  TSidebarItem(icon: Icons.view_headline, text: 'Accordion', route: '/accordion', page: const AccordionPage()),
  TSidebarItem(icon: Icons.schema, text: 'Colors', route: '/colors', page: const ColorsPage()),
  TSidebarItem(
    icon: Icons.schema,
    text: 'Parent',
    route: '/parent',
    children: [
      TSidebarItem(
        icon: Icons.schema,
        text: 'Child 1',
        route: '/child 1',
        page: const PlaceholderPage(title: 'Child'),
      ),
      TSidebarItem(
        icon: Icons.schema,
        text: 'Child 2',
        route: '/child 2',
        children: [
          TSidebarItem(
            icon: Icons.schema,
            text: 'Child 3',
            route: '/child 3',
            page: const PlaceholderPage(title: 'Child'),
          ),
        ],
      ),
    ],
  ),
];

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TBreadcrumbs(items: sidebarItems),
        ],
      ),
    );
  }
}
