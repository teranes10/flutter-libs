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
