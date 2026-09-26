import 'package:flutter/material.dart';
import 'package:my_app/pages/accordion_page.dart';
import 'package:my_app/pages/avatars_page.dart';
import 'package:my_app/pages/banners_page.dart';
import 'package:my_app/pages/bottom_bar_page.dart';
import 'package:my_app/pages/breadcrumbs_page.dart';
import 'package:my_app/pages/buttons_page.dart';
import 'package:my_app/pages/chips_page.dart';
import 'package:my_app/pages/colors_page.dart';
import 'package:my_app/pages/command_palette_page.dart';
import 'package:my_app/pages/context_menu_page.dart';
import 'package:my_app/pages/copy_button_page.dart';
import 'package:my_app/pages/crud_page.dart';
import 'package:my_app/pages/crud_riverpod_page.dart';
import 'package:my_app/pages/csv_editor_page.dart';
import 'package:my_app/pages/cursor_pagination_page.dart';
import 'package:my_app/pages/delivery_page.dart';
import 'package:my_app/pages/diff_viewer_page.dart';
import 'package:my_app/pages/dropdown_sample_page.dart';
import 'package:my_app/pages/editor_page.dart';
import 'package:my_app/pages/empty_state_page.dart';
import 'package:my_app/pages/feedback_page.dart';
import 'package:my_app/pages/filter_field_page.dart';
import 'package:my_app/pages/forms_page.dart';
import 'package:my_app/pages/grid_page.dart';
import 'package:my_app/pages/input_fields_page.dart';
import 'package:my_app/pages/json_viewer_page.dart';
import 'package:my_app/pages/kanban_page.dart';
import 'package:my_app/pages/key_value_page.dart';
import 'package:my_app/pages/layout_page.dart';
import 'package:my_app/pages/list_detail_page.dart';
import 'package:my_app/pages/lists_page.dart';
import 'package:my_app/pages/map_sample_page.dart';
import 'package:my_app/pages/metric_tile_page.dart';
import 'package:my_app/pages/pickers_page.dart';
import 'package:my_app/pages/pin_field_page.dart';
import 'package:my_app/pages/popover_page.dart';
import 'package:my_app/pages/popups_page.dart';
import 'package:my_app/pages/results_page.dart';
import 'package:my_app/pages/rich_text_field_page.dart';
import 'package:my_app/pages/select_fields_page.dart';
import 'package:my_app/pages/skeleton_page.dart';
import 'package:my_app/pages/sparkline_page.dart';
import 'package:my_app/pages/speed_dial_page.dart';
import 'package:my_app/pages/split_pane_page.dart';
import 'package:my_app/pages/stepper_page.dart';
import 'package:my_app/pages/tables_bottom_page.dart';
import 'package:my_app/pages/tables_create_builder_page.dart';
import 'package:my_app/pages/tables_dialog_page.dart';
import 'package:my_app/pages/tables_page.dart';
import 'package:my_app/pages/tables_page_mode_page.dart';
import 'package:my_app/pages/tables_side_page.dart';
import 'package:my_app/pages/tables_sub_item_page.dart';
import 'package:my_app/pages/tables_tree_children_page.dart';
import 'package:my_app/pages/tabs_page.dart';
import 'package:my_app/pages/timeline_page.dart';
import 'package:my_app/pages/tour_page.dart';
import 'package:my_app/pages/transfer_list_page.dart';
import 'package:my_app/pages/tree_view_page.dart';
import 'package:my_app/pages/watermark_page.dart';
import 'package:te_widgets/te_widgets.dart';

final sidebarItems = [
  // ── Forms & Inputs ───────────────────────────────────────────────────────
  TSidebarItem(
    icon: Icons.edit_note,
    text: 'Forms & Inputs',
    route: '/forms',
    children: [
      TSidebarItem(icon: Icons.text_fields, text: 'Input Fields', route: 'input-fields', page: const InputFieldsPage()),
      TSidebarItem(icon: Icons.pin_outlined, text: 'PIN / OTP Field', route: 'pin-field', page: const PinFieldPage()),
      TSidebarItem(icon: Icons.check_box, text: 'Select Fields', route: 'select-fields', page: const SelectFieldsPage()),
      TSidebarItem(icon: Icons.arrow_drop_down_circle, text: 'Dropdown', route: 'dropdown', page: const DropdownSamplePage()),
      TSidebarItem(icon: Icons.calendar_month, text: 'Pickers', route: 'pickers', page: const PickersPage()),
      TSidebarItem(icon: Icons.filter_alt, text: 'Filter Fields', route: 'filter-fields', page: const FilterFieldPage()),
      TSidebarItem(icon: Icons.swap_horiz_rounded, text: 'Transfer List', route: 'transfer-list', page: const TransferListPage()),
      TSidebarItem(icon: Icons.assignment, text: 'Forms', route: 'forms', page: const FormsPage()),
      TSidebarItem(icon: Icons.edit_note, text: 'Editor', route: 'editor', page: const EditorPage()),
      TSidebarItem(icon: Icons.text_snippet, text: 'Rich Text Field', route: 'rich-text-field', page: const RichTextFieldPage()),
    ],
  ),

  // ── Buttons & Actions ────────────────────────────────────────────────────
  TSidebarItem(
    icon: Icons.smart_button,
    text: 'Buttons & Actions',
    route: '/actions',
    children: [
      TSidebarItem(icon: Icons.smart_button, text: 'Buttons', route: 'buttons', page: const ButtonsPage()),
      TSidebarItem(icon: Icons.unfold_more_rounded, text: 'Speed Dial', route: 'speed-dial', page: const SpeedDialPage()),
      TSidebarItem(icon: Icons.copy_rounded, text: 'Copy Button', route: 'copy-button', page: const CopyButtonPage()),
    ],
  ),

  // ── Tables ───────────────────────────────────────────────────────────────
  TSidebarItem(
    icon: Icons.table_chart,
    text: 'Tables',
    route: '/tables',
    children: [
      TSidebarItem(icon: Icons.table_chart_outlined, text: 'Basic Tables', route: 'basic', page: const TablesPage()),
      TSidebarItem(icon: Icons.table_rows, text: 'Bottom Expansion', route: 'bottom', page: const TablesBottomPage()),
      TSidebarItem(icon: Icons.view_sidebar, text: 'Side Expansion', route: 'side', page: const TablesSidePage()),
      TSidebarItem(icon: Icons.web_asset, text: 'Dialog Expansion', route: 'dialog', page: const TablesDialogPage()),
      TSidebarItem(icon: Icons.article, text: 'Page Expansion', route: 'page', page: const TablesPageModePage()),
      TSidebarItem(icon: Icons.filter_none_outlined, text: 'Sub-Items Table', route: 'sub-item', page: const TablesSubItemPage()),
      TSidebarItem(icon: Icons.add_box_outlined, text: 'Create Builder Table', route: 'create-builder', page: const TablesCreateBuilderPage()),
      TSidebarItem(icon: Icons.account_tree, text: 'Tree Children Table', route: 'tree-children', page: const TablesTreeChildrenPage()),
    ],
  ),

  // ── Data Management ──────────────────────────────────────────────────────
  TSidebarItem(
    icon: Icons.storage_rounded,
    text: 'Data Management',
    route: '/data-management',
    children: [
      TSidebarItem(icon: Icons.storage, text: 'CRUD', route: 'crud', page: const CrudPage()),
      TSidebarItem(icon: Icons.storage, text: 'CRUD (Riverpod)', route: 'crud-riverpod', page: const CrudRiverpodPage()),
      TSidebarItem(icon: Icons.table_view_rounded, text: 'CSV Editor', route: 'csv-editor', page: const CsvEditorPage()),
      TSidebarItem(icon: Icons.navigate_next, text: 'Cursor Pagination', route: 'cursor-pagination', page: const CursorPaginationPage()),
    ],
  ),

  // ── Data Display ─────────────────────────────────────────────────────────
  TSidebarItem(
    icon: Icons.analytics_outlined,
    text: 'Data Display',
    route: '/data-display',
    children: [
      TSidebarItem(icon: Icons.list, text: 'Lists', route: 'lists', page: const ListsPage()),
      TSidebarItem(icon: Icons.splitscreen, text: 'List Detail', route: 'list-detail', page: const ListDetailPage()),
      TSidebarItem(icon: Icons.account_tree_outlined, text: 'Tree View', route: 'tree-view', page: const TreeViewPage()),
      TSidebarItem(icon: Icons.view_kanban_outlined, text: 'Kanban Board', route: 'kanban', page: const KanbanPage()),
      TSidebarItem(icon: Icons.speed_rounded, text: 'Metrics & Tiles', route: 'metrics-tiles', page: const MetricTilePage()),
      TSidebarItem(icon: Icons.show_chart_rounded, text: 'Sparklines & Trends', route: 'sparklines', page: const SparklinePage()),
      TSidebarItem(icon: Icons.list_alt, text: 'Key Value', route: 'key-value', page: const KeyValuePage()),
      TSidebarItem(icon: Icons.data_object_rounded, text: 'JSON Inspector', route: 'json-viewer', page: const JsonViewerPage()),
      TSidebarItem(icon: Icons.difference_outlined, text: 'Diff Viewer', route: 'diff-viewer', page: const DiffViewerPage()),
      TSidebarItem(icon: Icons.account_circle, text: 'Avatars', route: 'avatars', page: const AvatarsPage()),
      TSidebarItem(icon: Icons.label, text: 'Chips', route: 'chips', page: const ChipsPage()),
    ],
  ),

  // ── Feedback & Status ────────────────────────────────────────────────────
  TSidebarItem(
    icon: Icons.notifications_active_outlined,
    text: 'Feedback & Status',
    route: '/feedback-status',
    children: [
      TSidebarItem(icon: Icons.message, text: 'Popups', route: 'popups', page: const PopupsPage()),
      TSidebarItem(icon: Icons.chat_bubble_outline_rounded, text: 'Popover & Confirm', route: 'popover', page: const PopoverPage()),
      TSidebarItem(icon: Icons.announcement_outlined, text: 'Banners', route: 'banners', page: const BannersPage()),
      TSidebarItem(icon: Icons.feedback, text: 'Feedback', route: 'feedback', page: const FeedbackPage()),
      TSidebarItem(icon: Icons.view_quilt_outlined, text: 'Skeleton Loaders', route: 'skeletons', page: const SkeletonPage()),
      TSidebarItem(icon: Icons.inbox_outlined, text: 'Empty States', route: 'empty-states', page: const EmptyStatePage()),
      TSidebarItem(icon: Icons.check_circle_outline_rounded, text: 'Result States', route: 'results', page: const ResultsPage()),
    ],
  ),

  // ── Navigation ───────────────────────────────────────────────────────────
  TSidebarItem(
    icon: Icons.navigation_outlined,
    text: 'Navigation',
    route: '/navigation',
    children: [
      TSidebarItem(icon: Icons.tab, text: 'Tabs', route: 'tabs', page: const TabsPage()),
      TSidebarItem(icon: Icons.linear_scale, text: 'Stepper', route: 'stepper', page: const StepperPage()),
      TSidebarItem(icon: Icons.linear_scale, text: 'Breadcrumbs', route: 'breadcrumbs', page: const BreadcrumbsPage()),
      TSidebarItem(icon: Icons.vertical_align_bottom, text: 'Bottom Bar', route: 'bottom-bar', page: const BottomBarPage()),
      TSidebarItem(icon: Icons.terminal_rounded, text: 'Command Palette', route: 'command-palette', page: const CommandPalettePage()),
      TSidebarItem(icon: Icons.mouse_rounded, text: 'Context Menu', route: 'context-menu', page: const ContextMenuPage()),
      TSidebarItem(icon: Icons.tour_outlined, text: 'Guided Tour', route: 'tour', page: const TourPage()),
    ],
  ),

  // ── Layout & Structure ───────────────────────────────────────────────────
  TSidebarItem(
    icon: Icons.layers_outlined,
    text: 'Layout & Structure',
    route: '/layout-structure',
    children: [
      TSidebarItem(icon: Icons.layers, text: 'Layout', route: 'layout', page: const LayoutPage()),
      TSidebarItem(icon: Icons.grid_view, text: 'Grid', route: 'grid', page: const GridPage()),
      TSidebarItem(icon: Icons.splitscreen_rounded, text: 'Split Pane', route: 'split-pane', page: const SplitPanePage()),
      TSidebarItem(icon: Icons.view_headline, text: 'Accordion', route: 'accordion', page: const AccordionPage()),
      TSidebarItem(icon: Icons.timeline, text: 'Timeline', route: 'timeline', page: const TimelinePage()),
      TSidebarItem(icon: Icons.branding_watermark_outlined, text: 'Watermark', route: 'watermark', page: const WatermarkPage()),
    ],
  ),

  // ── Foundations ──────────────────────────────────────────────────────────
  TSidebarItem(
    icon: Icons.palette_outlined,
    text: 'Foundations',
    route: '/foundations',
    children: [
      TSidebarItem(icon: Icons.schema, text: 'Colors', route: 'colors', page: const ColorsPage()),
    ],
  ),

  // ── Samples & Demos ──────────────────────────────────────────────────────
  TSidebarItem(
    icon: Icons.dashboard_customize_outlined,
    text: 'Samples',
    route: '/samples',
    children: [
      TSidebarItem(icon: Icons.local_shipping_outlined, text: 'Delivery App', route: 'delivery-app', page: const DeliveryPage()),
      TSidebarItem(icon: Icons.map, text: 'Maps', route: 'maps', page: const MapSamplePage()),
      TSidebarItem(
        icon: Icons.schema,
        text: 'Nested Hierarchy',
        route: 'nested-menu',
        children: [
          TSidebarItem(icon: Icons.schema, text: 'Child 1', route: 'child1', page: const PlaceholderPage(title: 'Child 1')),
          TSidebarItem(
            icon: Icons.schema,
            text: 'Child 2',
            route: 'child2',
            children: [
              TSidebarItem(
                icon: Icons.schema,
                text: 'Child 3',
                route: 'child3',
                children: [
                  TSidebarItem(icon: Icons.schema, text: 'Child 4', route: 'child4', page: const PlaceholderPage(title: 'Child 4')),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),

  // ── Hidden / Dynamic Routes ──────────────────────────────────────────────
  TSidebarItem(
    icon: Icons.explore,
    text: 'Explorer',
    route: '/explorer/:path(.*)',
    builder: (context, state) => PlaceholderPage(title: 'Path: ${state.pathParameters["path"]}'),
    hidden: true,
  ),
];
