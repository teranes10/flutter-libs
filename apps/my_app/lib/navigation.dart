import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:my_app/pages/buttons_page.dart';
import 'package:my_app/pages/chips_page.dart';
import 'package:my_app/pages/crud_page.dart';
import 'package:my_app/pages/editor_page.dart';
import 'package:my_app/pages/forms_page.dart';
import 'package:my_app/pages/grid_page.dart';
import 'package:my_app/pages/input_fields_page.dart';
import 'package:my_app/pages/pickers_page.dart';
import 'package:my_app/pages/popups_page.dart';
import 'package:my_app/pages/select_fields_page.dart';
import 'package:my_app/pages/tables_page.dart';
import 'package:my_app/pages/tabs_page.dart';

final sidebarItems = [
  TSidebarItem(icon: Icons.text_fields, text: 'Input Fields', route: '/input-fields', page: const InputFieldsPage()),
  TSidebarItem(icon: Icons.check_box, text: 'Select Fields', route: '/select-fields', page: const SelectFieldsPage()),
  TSidebarItem(icon: Icons.calendar_month, text: 'Pickers', route: '/pickers', page: const PickersPage()),
  TSidebarItem(icon: Icons.smart_button, text: 'Buttons', route: '/buttons', page: const ButtonsPage()),
  TSidebarItem(icon: Icons.label, text: 'Chips', route: '/chips', page: const ChipsPage()),
  TSidebarItem(icon: Icons.tab, text: 'Tabs', route: '/tabs', page: const TabsPage()),
  TSidebarItem(icon: Icons.message, text: 'Popups', route: '/popups', page: const PopupsPage()),
  TSidebarItem(icon: Icons.table_chart, text: 'Tables', route: '/tables', page: const TablesPage()),
  TSidebarItem(icon: Icons.grid_view, text: 'Grid', route: '/grid', page: const GridPage()),
  TSidebarItem(icon: Icons.storage, text: 'Crud', route: '/crud', page: const CrudPage()),
  TSidebarItem(icon: Icons.edit_note, text: 'Editor', route: '/editor', page: const EditorPage()),
  TSidebarItem(icon: Icons.assignment, text: 'Forms', route: '/forms', page: const FormsPage()),
];
