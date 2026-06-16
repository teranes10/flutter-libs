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
