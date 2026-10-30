import 'package:flutter/material.dart';
import 'package:my_app/pages/accordion_page.dart';
import 'package:my_app/pages/affix_page.dart';
import 'package:my_app/pages/card_page.dart';
import 'package:my_app/pages/avatars_page.dart';
import 'package:my_app/pages/banners_page.dart';
import 'package:my_app/pages/authorization_page.dart';
import 'package:my_app/pages/bottom_bar_page.dart';
import 'package:my_app/pages/breadcrumbs_page.dart';
import 'package:my_app/pages/buttons_page.dart';
import 'package:my_app/pages/calendar_view_page.dart';
import 'package:my_app/pages/carousel_page.dart';
import 'package:my_app/pages/chips_page.dart';
import 'package:my_app/pages/colors_page.dart';
import 'package:my_app/pages/command_palette_page.dart';
import 'package:my_app/pages/context_menu_page.dart';
import 'package:my_app/pages/copy_button_page.dart';
import 'package:my_app/pages/crud_hierarchy_page.dart';
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
import 'package:my_app/pages/mentions_menubar_page.dart';
import 'package:my_app/pages/metric_tile_page.dart';
import 'package:my_app/pages/pickers_page.dart';
import 'package:my_app/pages/pin_field_page.dart';
import 'package:my_app/pages/popover_page.dart';
import 'package:my_app/pages/popups_page.dart';
import 'package:my_app/pages/results_page.dart';
import 'package:my_app/pages/rich_text_field_page.dart';
import 'package:my_app/pages/select_fields_page.dart';
import 'package:my_app/pages/selection_controls_page.dart';
import 'package:my_app/pages/skeleton_page.dart';
import 'package:my_app/pages/sparkline_page.dart';
import 'package:my_app/pages/speed_dial_page.dart';
import 'package:my_app/pages/split_pane_page.dart';
import 'package:my_app/pages/stepper_page.dart';
import 'package:my_app/pages/order_picking_page.dart';
import 'package:my_app/pages/stocktake_v2_page.dart';
import 'package:my_app/pages/tables_bottom_page.dart';
import 'package:my_app/pages/tables_create_builder_page.dart';
import 'package:my_app/pages/tables_dialog_page.dart';
import 'package:my_app/pages/tables_page.dart';
import 'package:my_app/pages/tables_matrix_page.dart';
import 'package:my_app/pages/tables_page_mode_page.dart';
import 'package:my_app/pages/tables_permission_matrix_page.dart';
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
    icon: HugeIcons.strokeRoundedNoteEdit,
    text: 'Forms & Inputs',
    route: '/forms',
    children: [
      TSidebarItem(icon: HugeIcons.strokeRoundedText, text: 'Input Fields', route: 'input-fields', page: const InputFieldsPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedCheckList,
        text: 'Selection & Option Tiles',
        route: 'selection-tiles',
        page: const SelectionControlsPage(),
      ),
      TSidebarItem(icon: HugeIcons.strokeRoundedDialpadCircle01, text: 'PIN / OTP Field', route: 'pin-field', page: const PinFieldPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedCheckmarkSquare01,
        text: 'Select Fields',
        route: 'select-fields',
        page: const SelectFieldsPage(),
      ),
      TSidebarItem(icon: HugeIcons.strokeRoundedArrowDown01, text: 'Dropdown', route: 'dropdown', page: const DropdownSamplePage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedCalendar03, text: 'Pickers', route: 'pickers', page: const PickersPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedFilter, text: 'Filter Fields', route: 'filter-fields', page: const FilterFieldPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedArrowLeftRight,
        text: 'Transfer List',
        route: 'transfer-list',
        page: const TransferListPage(),
      ),
      TSidebarItem(icon: HugeIcons.strokeRoundedTask01, text: 'Forms', route: 'forms', page: const FormsPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedNoteEdit, text: 'Editor', route: 'editor', page: const EditorPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedFile01, text: 'Rich Text Field', route: 'rich-text-field', page: const RichTextFieldPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedMailAtSign01,
        text: 'Mentions & Menubar',
        route: 'mentions-menubar',
        page: const MentionsMenubarPage(),
      ),
    ],
  ),

  // ── Buttons & Actions ────────────────────────────────────────────────────
  TSidebarItem(
    icon: HugeIcons.strokeRoundedCursorPointer01,
    text: 'Buttons & Actions',
    route: '/actions',
    children: [
      TSidebarItem(icon: HugeIcons.strokeRoundedCursorPointer01, text: 'Buttons', route: 'buttons', page: const ButtonsPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedUnfoldMore, text: 'Speed Dial', route: 'speed-dial', page: const SpeedDialPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedCopy01, text: 'Copy Button', route: 'copy-button', page: const CopyButtonPage()),
    ],
  ),

  // ── Tables ───────────────────────────────────────────────────────────────
  TSidebarItem(
    icon: HugeIcons.strokeRoundedTable,
    text: 'Tables',
    route: '/tables',
    children: [
      TSidebarItem(icon: HugeIcons.strokeRoundedTable, text: 'Basic Tables', route: 'basic', page: const TablesPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedTableColumnsSplit,
        text: 'Bottom Expansion',
        route: 'bottom',
        page: const TablesBottomPage(),
      ),
      TSidebarItem(icon: HugeIcons.strokeRoundedSidebarLeft, text: 'Side Expansion', route: 'side', page: const TablesSidePage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedBrowser, text: 'Dialog Expansion', route: 'dialog', page: const TablesDialogPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedNews, text: 'Page Expansion', route: 'page', page: const TablesPageModePage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedLayers01, text: 'Sub-Items Table', route: 'sub-item', page: const TablesSubItemPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedGrid, text: 'Matrix Table', route: 'matrix', page: const TablesMatrixPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedAddSquare,
        text: 'Create Builder Table',
        route: 'create-builder',
        page: const TablesCreateBuilderPage(),
      ),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedFolderTree,
        text: 'Tree Children Table',
        route: 'tree-children',
        page: const TablesTreeChildrenPage(),
      ),
    ],
  ),

  // ── Data Management ──────────────────────────────────────────────────────
  TSidebarItem(
    icon: HugeIcons.strokeRoundedDatabase,
    text: 'Data Management',
    route: '/data-management',
    children: [
      TSidebarItem(icon: HugeIcons.strokeRoundedDatabase, text: 'CRUD', route: 'crud', page: const CrudPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedDatabase, text: 'CRUD (Riverpod)', route: 'crud-riverpod', page: const CrudRiverpodPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedFolderTree,
        text: 'CRUD (Hierarchy)',
        route: 'crud-hierarchy',
        page: const CrudHierarchyPage(),
      ),
      TSidebarItem(icon: HugeIcons.strokeRoundedTable, text: 'CSV Editor', route: 'csv-editor', page: const CsvEditorPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedArrowRight01,
        text: 'Cursor Pagination',
        route: 'cursor-pagination',
        page: const CursorPaginationPage(),
      ),
    ],
  ),

  // ── Data Display ─────────────────────────────────────────────────────────
  TSidebarItem(
    icon: HugeIcons.strokeRoundedAnalytics01,
    text: 'Data Display',
    route: '/data-display',
    children: [
      TSidebarItem(icon: HugeIcons.strokeRoundedListView, text: 'Lists', route: 'lists', page: const ListsPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedLayoutLeft, text: 'List Detail', route: 'list-detail', page: const ListDetailPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedFolderTree, text: 'Tree View', route: 'tree-view', page: const TreeViewPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedKanban, text: 'Kanban Board', route: 'kanban', page: const KanbanPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedDashboardSpeed01,
        text: 'Metrics & Tiles',
        route: 'metrics-tiles',
        page: const MetricTilePage(),
      ),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedChartLineData01,
        text: 'Sparklines & Trends',
        route: 'sparklines',
        page: const SparklinePage(),
      ),
      TSidebarItem(icon: HugeIcons.strokeRoundedPropertyNew, text: 'Key Value', route: 'key-value', page: const KeyValuePage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedSourceCode, text: 'JSON Inspector', route: 'json-viewer', page: const JsonViewerPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedNotEqualSignSquare,
        text: 'Diff Viewer',
        route: 'diff-viewer',
        page: const DiffViewerPage(),
      ),
      TSidebarItem(icon: HugeIcons.strokeRoundedUserCircle, text: 'Avatars', route: 'avatars', page: const AvatarsPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedTag01, text: 'Chips', route: 'chips', page: const ChipsPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedCarouselHorizontal, text: 'Carousel', route: 'carousel', page: const CarouselPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedAiView, text: 'Calendar View', route: 'calendar-view', page: const CalendarViewPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedLayers01, text: 'Card', route: 'card', page: const CardPage()),
    ],
  ),

  // ── Feedback & Status ────────────────────────────────────────────────────
  TSidebarItem(
    icon: HugeIcons.strokeRoundedNotification02,
    text: 'Feedback & Status',
    route: '/feedback-status',
    children: [
      TSidebarItem(icon: HugeIcons.strokeRoundedComment01, text: 'Popups', route: 'popups', page: const PopupsPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedBubbleChat, text: 'Popover & Confirm', route: 'popover', page: const PopoverPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedMegaphone01, text: 'Banners', route: 'banners', page: const BannersPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedBubbleChatQuestion, text: 'Feedback', route: 'feedback', page: const FeedbackPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedAiView, text: 'Skeleton Loaders', route: 'skeletons', page: const SkeletonPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedInbox, text: 'Empty States', route: 'empty-states', page: const EmptyStatePage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedCheckmarkCircle01, text: 'Result States', route: 'results', page: const ResultsPage()),
    ],
  ),

  // ── Navigation ───────────────────────────────────────────────────────────
  TSidebarItem(
    icon: HugeIcons.strokeRoundedNavigation01,
    text: 'Navigation',
    route: '/navigation',
    children: [
      TSidebarItem(icon: HugeIcons.strokeRoundedBrowser, text: 'Tabs', route: 'tabs', page: const TabsPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedFlowConnection, text: 'Stepper', route: 'stepper', page: const StepperPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedArrowRightDouble, text: 'Breadcrumbs', route: 'breadcrumbs', page: const BreadcrumbsPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedAlignBottom, text: 'Bottom Bar', route: 'bottom-bar', page: const BottomBarPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedComputer,
        text: 'Command Palette',
        route: 'command-palette',
        page: const CommandPalettePage(),
      ),
      TSidebarItem(icon: HugeIcons.strokeRoundedMouse01, text: 'Context Menu', route: 'context-menu', page: const ContextMenuPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedLock, text: 'Authorization', route: 'authorization', page: const AuthorizationPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedFlag01, text: 'Guided Tour', route: 'tour', page: const TourPage()),
    ],
  ),

  // ── Layout & Structure ───────────────────────────────────────────────────
  TSidebarItem(
    icon: HugeIcons.strokeRoundedLayers01,
    text: 'Layout & Structure',
    route: '/layout-structure',
    children: [
      TSidebarItem(icon: HugeIcons.strokeRoundedLayers01, text: 'Layout', route: 'layout', page: const LayoutPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedGrid, text: 'Grid', route: 'grid', page: const GridPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedLayoutLeft, text: 'Split Pane', route: 'split-pane', page: const SplitPanePage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedViewAgenda, text: 'Accordion', route: 'accordion', page: const AccordionPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedTimeline, text: 'Timeline', route: 'timeline', page: const TimelinePage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedStamp, text: 'Watermark', route: 'watermark', page: const WatermarkPage()),
      TSidebarItem(icon: HugeIcons.strokeRoundedAlignTop, text: 'Affix', route: 'affix', page: const AffixPage()),
    ],
  ),

  // ── Foundations ──────────────────────────────────────────────────────────
  TSidebarItem(
    icon: HugeIcons.strokeRoundedPaintBoard,
    text: 'Foundations',
    route: '/foundations',
    children: [TSidebarItem(icon: HugeIcons.strokeRoundedHierarchy, text: 'Colors', route: 'colors', page: const ColorsPage())],
  ),

  // ── Samples & Demos ──────────────────────────────────────────────────────
  TSidebarItem(
    icon: HugeIcons.strokeRoundedDashboardSquare01,
    text: 'Samples',
    route: '/samples',
    children: [
      TSidebarItem(icon: HugeIcons.strokeRoundedPackage, text: 'Stock Take Flow', route: 'stocktake-flow', page: const StocktakeV2Page()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedShoppingCart01,
        text: 'Order Picking',
        route: 'order-picking',
        page: const OrderPickingPage(),
      ),
      TSidebarItem(icon: HugeIcons.strokeRoundedDeliveryTruck01, text: 'Delivery App', route: 'delivery-app', page: const DeliveryPage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedGrid,
        text: 'Permission Matrix',
        route: 'permission-matrix',
        page: const TablesPermissionMatrixPage(),
      ),
      TSidebarItem(icon: HugeIcons.strokeRoundedMaps, text: 'Maps', route: 'maps', page: const MapSamplePage()),
      TSidebarItem(
        icon: HugeIcons.strokeRoundedHierarchy,
        text: 'Nested Hierarchy',
        route: 'nested-menu',
        children: [
          TSidebarItem(
            icon: HugeIcons.strokeRoundedHierarchy,
            text: 'Child 1',
            route: 'child1',
            page: const PlaceholderPage(title: 'Child 1'),
          ),
          TSidebarItem(
            icon: HugeIcons.strokeRoundedHierarchy,
            text: 'Child 2',
            route: 'child2',
            children: [
              TSidebarItem(
                icon: HugeIcons.strokeRoundedHierarchy,
                text: 'Child 3',
                route: 'child3',
                children: [
                  TSidebarItem(
                    icon: HugeIcons.strokeRoundedHierarchy,
                    text: 'Child 4',
                    route: 'child4',
                    page: const PlaceholderPage(title: 'Child 4'),
                  ),
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
    icon: HugeIcons.strokeRoundedCompass,
    text: 'Explorer',
    route: '/explorer/:path(.*)',
    builder: (context, state) => PlaceholderPage(title: 'Path: ${state.pathParameters["path"]}'),
    hidden: true,
  ),
];
