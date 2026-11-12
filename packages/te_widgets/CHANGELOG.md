## 4.1.0

 - **REFACTOR**: replace Material IconButton with TButton; popover trigger fires on enabled buttons. ([70d110ce](https://github.com/teranes10/flutter-libs/commit/70d110ce1ca5b12af6c149e06d7d630ceead01a7))
 - **FIX**(te_widgets): TTextField.scan camera button keeps a 48dp touch target; format scan view files. ([e7385c22](https://github.com/teranes10/flutter-libs/commit/e7385c2278219b09d4616744b451eecdb013edd9))
 - **FIX**(te_widgets): theme text uses onSurface; TTextField wires onTap and keeps typed text on rebuild. ([1cc1b680](https://github.com/teranes10/flutter-libs/commit/1cc1b68087b16e5f6690ac7384b70222288a4784))
 - **FIX**(te_widgets): remove lingering page-mode detail route when table is disposed. ([23ea6d02](https://github.com/teranes10/flutter-libs/commit/23ea6d0265cdec445cb8810b250efca7d23f3646))
 - **FIX**(te_widgets): size create/edit dialog by createMode; toggle View closed in bottom expansion. ([594e16f3](https://github.com/teranes10/flutter-libs/commit/594e16f3c59ec3c6a02a4157299ad275caa688ce))
 - **FIX**(te_widgets): template honors format delimiter, key-value stacked label overflow; update stale profile menu test. ([1fba47c7](https://github.com/teranes10/flutter-libs/commit/1fba47c72ddac833db974d76fcf492caae517a36))
 - **FEAT**: global configs for TImage, TPhoneField and te_map. ([aa013faf](https://github.com/teranes10/flutter-libs/commit/aa013faf4d3a9475a3e04c6485f864c49a1ca69f))

## 4.0.0

> Note: This release has breaking changes.

 - **REFACTOR**(te_widgets): replace photo_view with InteractiveViewer. ([8c4815ff](https://github.com/teranes10/flutter-libs/commit/8c4815ff4f13bc0567f74a83e7c295ff0c162819))
 - **REFACTOR**(te_widgets): drop crypto and dio in favour of FNV key and http. ([f790449d](https://github.com/teranes10/flutter-libs/commit/f790449d7c3accefcb6523afa8ac37b7ccdf2385))
 - **FIX**: automated deployment and release. ([62aa9082](https://github.com/teranes10/flutter-libs/commit/62aa908245dd98901b70c2855fba4dd55c1aa7f5))
 - **FEAT**(te_widgets): add inline create (createForm/onCreateItem) to TSelect and TMultiSelect. ([14fb9e2a](https://github.com/teranes10/flutter-libs/commit/14fb9e2aebd85964b2b67ff712aeed092f9cc1eb))
 - **FEAT**(te_widgets): add refresh button to crud toolbar and pull-to-refresh to TList. ([9b4c33c5](https://github.com/teranes10/flutter-libs/commit/9b4c33c5bb117548662b9fb4a9291ba4ce6c9dfa))
 - **FEAT**(te_widgets): add TMarquee and TRollingText with my_app samples. ([1e54c324](https://github.com/teranes10/flutter-libs/commit/1e54c324ec5e3a77b80f074c8b050538f20be176))
 - **FEAT**(te_widgets): add theme customizer panel and rebuild color picker. ([fd60e851](https://github.com/teranes10/flutter-libs/commit/fd60e8518df4cffb65ff385e7d15390ea10b22e1))
 - **FEAT**(te_widgets): add TDropzone and rework csv editor import/export. ([e7700b07](https://github.com/teranes10/flutter-libs/commit/e7700b07561a869992cd5ed8013af6e34c403b63))
 - **FEAT**(te_widgets): open profile and crud toolbar more-options dropdowns on click. ([a59df43d](https://github.com/teranes10/flutter-libs/commit/a59df43d76356cabbd5b2445e3ace0dea220852a))
 - **FEAT**(te_widgets): replace toastification with built-in toast host. ([7da030d1](https://github.com/teranes10/flutter-libs/commit/7da030d148170369f34ff9f53ae6c146e12637a0))
 - **DOCS**(te_widgets): add unreleased changes to changelog. ([82a3f031](https://github.com/teranes10/flutter-libs/commit/82a3f031d130c0ee3730facd29ce8dab6cb952f0))
 - **BREAKING** **FEAT**(te_widgets): migrate to file_picker 13. ([3047508a](https://github.com/teranes10/flutter-libs/commit/3047508a2ba60fc991e8e5cf779a0da30b7a5ff2))

## 3.11.0

 - **FEAT**(te_widgets): `TSelect` and `TMultiSelect` inline create: `createForm`, `onCreateItem`, `createLabel` and `selectCreated` add an "Add New" footer button that opens a form and adds (and selects) the new item.
 - **FEAT**(te_widgets): add refresh button to crud toolbar and pull-to-refresh to `TList`.
 - **FEAT**(te_widgets): add `TMarquee` and `TRollingText` with my_app samples.
 - **FEAT**(te_widgets): add theme customizer panel and rebuild color picker.
 - **FEAT**(te_widgets): add `TDropzone` and rework csv editor import/export.
 - **FEAT**(te_widgets): open profile and crud toolbar more-options dropdowns on click.
 - **FEAT**(te_widgets): replace toastification with built-in toast host.
 - **FEAT**(te_widgets)!: **BREAKING** migrate to file_picker 13.
 - **REFACTOR**(te_widgets): replace photo_view with `InteractiveViewer`.
 - **REFACTOR**(te_widgets): drop crypto and dio in favour of FNV key and http.
 - **STYLE**(te_widgets): update default backgrounds and layout/metric tile tweaks.
 - **CHORE**(te_widgets): tree-card and crud table inset work; stricter lints, check script, CI and pre-commit hook.
 - **TEST**(te_widgets): update layout, tile size and stepper tests.

## 3.10.0

 - **FEAT**(te_widgets): crud top bar metrics list with aligned-row layout, tabs fill, dense toggle in menu.

## 3.9.1

 - **REFACTOR**(te_widgets): unify menu/dropdown theming with hover background and compact sizing.

## 3.9.0

 - **REFACTOR**: migrate Icons.* to HugeIcons and Icon widgets to TIcon.raw.
 - **FIX**(te_widgets): even label/text spacing with icons, drop focus overlay on containers, TIcon number stepper.
 - **FIX**(te_widgets): close table overlays on dispose, dedupe streamed creates, change CRUD expansion defaults.
 - **FEAT**(te_widgets): fade scrollable tab edges and fix tab wrapping.
 - **FEAT**(te_widgets): add stacked sub-row table columns and matrix table demo pages.
 - **FEAT**(te_widgets): add permission-string authorization engine and segmented tabs/button group.

## 3.8.0

 - **FEAT**(te_widgets): add forceCache support across image-bearing widgets.

## 3.7.0

- **New Widgets**:
  - Added `TCarousel`, `TMentionsField`, `TMenubar`, `TCalendarView`, `TAffix`.
  - Added mobile/field widgets: `TActionBar`, `TOptionTile`, `TSignaturePad` (with `TSignaturePadController`).
  - Added `TTile.task` task-row variant and `TBanner.offline` connectivity/sync-status banner.
- **Inputs & Forms**:
  - Added `TNumberField` quantity variant (`TNumberFieldVariant`) with step buttons.
  - Added `TTextField.scan` for scan-first entry.
  - Added `TNumberRangeInputFormatter`.
  - Radio, checkbox and switch groups support a tile mode for large touch targets.
  - `TFilePicker` updated; added `image_picker` dependency.
- **Buttons**:
  - Added `gradient`, `elevation` and `shadowColor` to `TButton`, `TButtonConfig` and `TButtonTheme`. Filled buttons get a subtle default lighting gradient and minimal elevation.
- **Feedback**:
  - Added `TFeedback` helper for central haptic and sound feedback (`selection`, `step`, `success`, `warning`, `error`).
- **Sizing & Layout**:
  - Added `TSize.xl` and `TTile` `h7`/`sm`/`md`/`lg` sizes; `TTile`, `TKeyValue`, `TCard`, tabs, accordion, bottom bar, alert, badge, chip and result refinements.
  - Layout, page wrapper and width helper updates for mobile layouts.
  - Table header, row card and mobile card adjustments.

## 3.6.0

 - **FEAT**(te_widgets): add gap analysis widgets suite (Phases 1-6) and showcase pages.

## 3.5.1

 - **FIX**(te_widgets): restore Flutter 3.38 backward compatibility for SizeTransition and ReorderableList.

## 3.5.0

 - **FEAT**(te_widgets): add TMetricGrid, TMetricTile, TTile heading scale, and enhancements.

## 3.4.0

- **Filtering Framework (`TFilter` & `TFilterField`)**:
  - Added comprehensive declarative filter suite: `TFilterDef`, `TFilterRule`, `TFilterEvaluator`, `TFilterOperator`.
  - Added typed filter models: `bool_filter`, `date_only_filter`, `date_time_filter`, `enum_filter`, `guid_filter`, `number_filter`, `string_filter`.
  - Added `TFilterField` and `TFilterFieldTheme` for rendering dynamic filter controls.
- **Key-Value Section Modes & Spacings (`TKeyValueMode`)**:
  - Added `TKeyValueMode` enum (`stackedFlow`, `stackedColumns`, `inlineFlow`, `inlineColumns`, `split`) with mode-based spacing/gap defaults and dense mode support.
  - Added factory constructors `TKeyValueSection.flow`, `TKeyValueSection.columnsInline`, `TKeyValueSection.flowStacked`, `TKeyValueSection.columnsStacked`, `TKeyValueSection.split`.
  - Removed `FittedBox` constraint restriction on `TKeyValue.widget` for unconstrained child layout safety.
- **Typography & Sizing Utilities**:
  - Added `TextStyleX` extension (`adjust`, `stepWeight`, `scale`, `thicker`, `lighter`, `clearColor`).
  - Added unified `TSize`, `TChipSize`, and `TBadgeSize`.
- **UI Components & Table Headers**:
  - Added `TTile` for unified icon/title/subtitle/trailing presentation.
  - Added `TInputContainer` for structured form input field containers.
  - Added `TDateTimeTextField` with ISO and formatted date/time inputs.
  - Added `TTableHeader.chips` and `TTableHeader.tile` table header factories.
  - Enhanced `TTableHeader.progress` with adaptive dynamic progress color shade styling and item width estimation constraints.

## 3.3.0

- **CSV Editor (`TCsvEditor`)**:
  - Introduced `TCsvEditor` — an interactive CSV/TSV upload, visual header re-mapping, inline editing, and export component.
  - Added `TCsvColumn` schema definition with typed factories (`text`, `number`, `integer`, `boolean`), validation rules, default values, and column aliases.
  - Added `TCsvHeaderMapperModal` and `TCsvHeaderMapping` for automatic and interactive visual header re-mapping with sample data previews.
  - Added `TCsvParser` supporting comma and semicolon delimiter detection, RFC 4180 parsing, and starter template generation.
  - Modularized editor implementation into `csv_editor_actions.dart`, `csv_editor_banners.dart`, and `csv_editor_table.dart`.
  - Integrated `TTabs<int>` toolbar to filter between All, Valid, and Errors with dynamic row counts and error indicators.
- **Table & Cell Scoped Errors**:
  - Added `TTableHeader.toggle` for boolean switch toggle columns.
  - Added `TTableCellScope` for cell-scoped error handling and validation error indicators at table level.
  - Expanded editable cell tap target (`TTableHeader.editable`, `textField`, `numberField`) to the full column width.
  - Fixed horizontal column bounding alignment between table header and row cards.
- **Metric Tiles**:
  - Added `TMetricTile` for KPI metrics and analytical summary cards.

## 3.2.0

- **Button & Icon Enhancements**:
  - Integrated `TIcon` into `TButton` and `TButtonGroup` supporting `IconData`, `HugeIcons`, and custom `Widget` icons dynamically.
  - Added support for rotation animations (`turns: (initial, active)`) and active icon transitions in `TButton` and `TButtonGroupItem`.
  - Added `TIcon.raw` factory constructor as a zero-overhead drop-in replacement for Flutter's `Icon(...)` without outer padding, background, shape, or container wrapping.
  - Updated `TPagination` navigation icon buttons to use `HugeIcons` via `TIcon` (`strokeRoundedArrowLeftDouble`, `strokeRoundedArrowLeft01`, `strokeRoundedArrowRight01`, `strokeRoundedArrowRightDouble`).
- **Form Types & Layout Persistence**:
  - Introduced `TFormType` (`accordion`, `horizontalTabs`, `verticalTabs`) supporting flexible subform presentation styles.
  - Added `TFormTypePersistence` managing multi-tier form type layout persistence across user sessions (in-memory cache, `PageStorage`, and `SharedPreferences`).
  - Added `TFormTypeScope` and `TFormTypeToggleSwitch` for cycling form layout presentation.
  - Integrated `TFormService.show` with subform detection (`hasSubForms`) to automatically display layout toggle action before the modal close button and persist user layout choices.
  - Added accordion layout support (`_buildAccordionTabsContent`) in `TFormBuilder`.
  - Configured `TTabs` with `Axis.vertical` to expand all tabs to the width of the widest tab using intrinsic width and stretched layout.
- **Top Bar & Navigation Enhancements**:
  - Added responsive top navigation menu and actions row (`TTopBar`, `TDesktopTopBar`, `TMobileTopBar`, `TTopNavMenu`, `TActionsRow`).
  - Added `ProfileButton` with popups for theme, color, fullscreen, and logout.
  - Added `SidebarTristateButton` for toggling sidebar modes.
- **Timeline & List Detail Widgets**:
  - Introduced `TTimeline`, `TTimelineItem`, `TTimelineIndicator`, and `TDashedLine` with rich variant theming.
  - Added `TListDetail` for split-view master-detail layouts with animated pane transitions.
- **Table & Layout Enhancements**:
  - Added `TTableExpansionMode.sideOverlay` for side overlay details view.
  - Added responsive width options in `TCrudTable`.
  - Added `Material` support across `TModal` and `TPageWrapper` for reliable input field rendering.

## 3.1.0

 - **FEAT**: modularize packages and configure melos scripts.

# 3.0.0

- **List Controller & Flat Virtualization Hierarchy Improvements**:
  - Unified item generation by merging `_createListItem` into a single canonical `itemFactory` method on `TListController`.
  - Consolidated tree traversal helpers (`getAncestorsOfKey` / `getDescendantsOfKey`) into instance methods to ensure correct generic type reification (`K`) on web platforms (DDC/dart2js).
  - Added `hasChildren` and `childrenCount` parameters to `TListCard`.
  - Refactored `TList`, `TSelect`, and `TMultiSelect` default list item builders to utilize the flat layout mode: items are rendered as separate list rows with indented levels rather than nesting children inside parent cards. This fixes duplicate item rendering and allows correct list recycling/virtualization.
  - Fixed state-tracking bug where collapsing all tree nodes (making `expandedKeys` empty) bypassed list re-flattening, keeping sub-items visible.
  - Fixed `totalItems` decrement calculation in `removeItemsByKeys` to subtract the counts of all removed descendants instead of just top-level parents.
  - Extracted `_syncParentInLocalAndDisplay` helper to sync updated parent `childrenKeys` state back into local pagination lists.
  - Centralized widget state sync in `TListStateMixin` (`_handleDidUpdateWidget`) for cleaner didUpdateWidget updates.
- **Sidebar Layout Routing Updates**:
  - Updated `TSidebarItemWidget` tap gesture behavior: tapping a parent item with visible children will trigger navigation/routing only if it is explicitly navigable (has both a route path and a custom `page`/`builder` widget defined).
  - If a route path is not defined or is just a structural parent placeholder (no page widget), tapping will toggle sub-menu expansion or execute its `onTap` handler instead of attempting navigation.

# 2.6.6


- **Table Details Side List Improvements**:
  - `TTableRowCard` now natively supports `onTap`, `hoverColor`, `splashColor`, and `highlightColor`, passing them to its internal `TCard`.
  - Configured hover state to display a semi-transparent version of the selected color.
  - Removed excessive right margins to achieve a full-width tile hover effect.
  - Wrapped `TImage` headers in `IgnorePointer` to prevent it from swallowing row tap events.
- **Select & MultiSelect Improvements**:
  - Enhanced empty states for dropdowns to display a minimal "No items found" message, avoiding oversized icons on small dropdown widths.
  - Smoothed initial `lazy` popup height scaling by enforcing a base height equivalent to 3 list items (~175px average) instead of defaulting to a large container limit, preventing harsh popup shrinkage after loading.

# 2.6.5

- **Mobile Page Mode Navigation (`TPageWrapper`)**:
  - Introduced `TPageWrapper` widget to provide a uniform full-screen Scaffold/AppBar layout on mobile screens.
  - Implemented `TPopupMode.page` in the popup mixin, allowing selects and multi-selects to open as full-screen modal pages on mobile devices.
  - Form service (`TFormService`) now renders fullscreen form routes on mobile using `TPageWrapper`.
  - Replaced the close button with a back button and reduced body padding in page mode routes.
- **Select & MultiSelect Improvements**:
  - Added filter search bars inside full-screen page mode dropdowns.
  - Optimized the search placeholder inside page mode to show `"Search..."` instead of repeating the input label.
  - Reverted `initState()` MediaQuery queries in `TSelect` and `TMultiSelect` into `didChangeDependencies()` to fix Flutter widget lifecycle exceptions.
- **Underline Input Decoration Style**:
  - Configured `TInputDecorationType.underline` to explicitly force the `BorderRadius` to `BorderRadius.zero`.
- **Infinite Scroll Enhancements**:
  - Resolved loading bugs in page-mode infinite lists: added post-frame layout triggers to load subsequent pages when the first page fits completely in the viewport without scrolling.
  - Bumped the default page-mode `itemsPerPage` count on mobile to `20` to fill the screen in a single request.
- **Detail Pane Deep-Linking**:
  - Exposed `TTabController` on `TRowExpandedBuilder.tabs` helper to allow client-side deep linking of side-panel sub-tabs with URL query parameters.
- **CRUD Side List Visual Alignment**:
  - Updated `_buildSideList` card layout to use the exact card structure, themes, margins, and selection state resolver of `TTableRowCard`.

# 2.6.4

- Input Field bug fix

# 2.6.3

- **Form Sidebar Layout**:
  - Added support for dual-column form structures by introducing `sidebarFields` and `sidebarSize` in `TFormBase`.
  - Splitted form layout dynamically in `TFormBuilder` using a responsive 12-column grid layout where main fields and sidebar fields flow side-by-side on desktop/large screens (e.g. 8:4 split) and stack into a single column on tablet/mobile screens.
- **TImage Local/IndexedDB Storage Caching (`forceCache`)**:
  - Implemented persistent caching for `TImage` using platform-specific adapters: `IndexedDB` on Web (via browser DB APIs) and local application document directory caching on native platforms (iOS/Android/Desktop).
  - Designed local image caching to prevent reloading and support offline asset viewing.
  - Added custom looping skeleton shimmer animation and smooth reveal transitions on successful fetch.
- **TAlignedRow Widget**:
  - Added `TAlignedRow` for responsive alignment of mixed child widgets.
  - Supports custom alignment rules where children can be grouped dynamically and automatically aligned (e.g., aligning groups of items to the left or right, with auto-flow wrapping).
- **TDateTimeText Widget**:
  - Added `TDateTimeText` to render relative/time-ago text (e.g., "5 seconds ago") while automatically wrapping it in a structured tooltip displaying the precise timestamp formatted according to a customizable pattern.
- **TFormatter & TFormats Utilities**:
  - Added `TFormatter` class for standardized formatting of numbers, currencies, durations, file sizes, speeds, and contact numbers.
  - Added `TFormats` class defining standard format patterns for date, time, and currency.

# 2.6.2
- CrudTable topbar actions width calc from box constraints logic added to prevent the overflow

# 2.6.1

- **InputValueMixin Cleanup**:
  - Removed the text controller watcher logic from `InputValueMixin` that was redundantly listening to text changes and could cause unintended state updates.

# 2.6.0

- **Overlay & Popup Positioning Fixes**:
  - Corrected `TPopupMixin` and `TDropdown` positioning by mapping `childPaintTransform` relative to the ancestor `Overlay` instead of global screen coordinates. This resolves alignment issues when popups are used inside navigators or padded layouts.
  - Replaced faulty `.absolute()` transform logic with `MatrixUtils.transformPoint` to ensure correct rendering during scrolling.
  - Factored keyboard height (`viewInsets.bottom`) and safety margins back into constraint calculations to prevent popups from rendering under the keyboard or getting clipped at screen edges.
- **TCard Enhancement**:
  - Added `clipBehavior` property (defaulting to `Clip.none`) to prevent nested overlays from being hidden inside layout borders (e.g., in `TDataTable` toolbars).
- **TListController Refinement**:
  - Added explicit `fetching` state to `TListState` alongside `loading` to better differentiate between initial loads and subsequent pagination/refresh fetches.
- **TDateTimeInputFormatter Update**:
  - Fixed mask validation logic to correctly truncate digits exceeding the mask's maximum length.

# 2.5.0  
- **TBarcodeScanner Improvements**:
  - Enhanced scanning UI with a visual scan window and an animated scanning line for better user guidance.
  - Added interactive hardware controls: Torch toggle, Camera flip, and 2x Zoom.
  - Optimized for Web: Automatically hides hardware-dependent controls on the web platform to prevent "Unsupported operation" errors.
  - Improved Lifecycle: Strictly synchronized camera start/stop with popup visibility, resolving "Video already playing" errors and resource leaks.
- **TButton Enhancement**:
  - Implemented a 1-second debounce (throttle) for `onTap` and `onPressed` to prevent accidental double-taps and redundant invalid clicks.
- **TTableMobileCard Refinement**:
  - Refactored layout to ensure the expansion icon remains anchored to the bottom-right even when the card is stretched in grid layouts.
  - Improved padding to prevent content overlap with expansion controls.

# 2.4.0

- Added `TBottomBar` for customizable bottom navigation.
- Added `TBottomBarItem` to define items within the bottom bar.
- Visual Variants: Support for TVariant (solid, tonal, outline, etc.) for active item highlighting.
- Label Positions: Added TBottomBarTextPosition enum to support:
  - rightActive: Label appears to the right of the icon only when active (modern style).
  - bottomAlways: Label appears below the icon always.
  - bottomActive: Label appears below the icon only when active.
  - none: No labels shown.
- Customization: Added properties for color, background, padding, margin, borderRadius, height, textStyle, and iconSize.
- Animation: Integrated AnimatedContainer for smooth transitions between active states.

# 2.3.0

- Added `TBarcodeScanner` widget for non-traditional popup-based barcode scanning
- Fixed `TCrudTable` issue where the create form would hide other items and disable scrolling
- Refactored `TListView` to use `SliverMainAxisGroup` for more robust content grouping
- Improved `TTable` card view (mobile/grid) to support `beforeItemsBuilder`
- Exported `mobile_scanner` library from `te_widgets.dart` for easier integration

# 2.2.0

- Added PDF and CSV export functionality to `TCrudTable`
- Implemented inline form editing for `TCrudTable` (row-flipping)
- Added `rowBuilder` and `rowColorBuilder` to `TTable`, `TDataTable`, and `TCrudTable`
- Refactored `TTableMobileCard` to use `TCard` for visual consistency
- Refined `TCard` default shadow for better UI appearance

# 2.1.0

- Added direct theme properties to `TList`, `TTable`, `TDataTable`, and `TTextField` for easier customization
- `TList` & `TTable`: Added `grid`, `gridDelegate`, `shrinkWrap`, `header`, `footer`, `infiniteScroll`, `headerSticky`, `footerSticky`
- `TDataTable`: Added `grid`, `gridDelegate`, `shrinkWrap`, `headerBuilder`, `footerBuilder`, `infiniteScroll`, `headerSticky`, `footerSticky`
- `TTextField`: Added `preWidget`, `postWidget`, `size`, `decorationType`
- Implemented a flexible theme override system where individual properties override the global theme when no local theme is provided
- Updated `TListTheme` and `TTableTheme` with `header` and `footer` (Widget?) support
- Added assertions to prevent conflicting theme configurations

# 2.0.9

- Table row card background color, border props added

## 2.0.8

- Added cursor-based pagination support
- Fixed tabs selection issues
- Enabled selectable text in tables

## 2.0.7

- Improved tabs (scrollable, wrapping, navigation buttons)
- Added clearable option for inputs

## 2.0.6

- Added screenshots

## 2.0.5

- Added documentation

## 2.0.4

- Fixed select infinite scroll issue
- Fixed data table items-per-page dropdown

## 2.0.0

- Added ListView and ListController

## 0.0.9

- Fixed sidebar overlay issue when removing deeper levels
- Fixed selected item text display in Select

## 0.0.8

- Added actions to TCrudTable

## 0.0.7

- Added TFormBuilder support for sub-forms and sub-form lists

## 0.0.6

- Fixed overflow issue in TModalService

## 0.0.5

- Added new field types to TFormField:
  - tags
  - select
  - multiSelect
  - number
  - date
  - time
  - dateTime

## 0.0.4

- Added TPaginationController
- Added TToastService
- Added TFormService
- Added “Add Item” option to TCrudTable

## 0.0.3

- Implemented filtering logic for TDataTable

## 0.0.2

- **FEAT(te_widgets):** version bump for testing

## 0.0.1

- Initial release
