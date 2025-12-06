# te_widgets

A comprehensive, opinionated collection of high-quality Flutter widgets designed for building enterprise-grade applications with speed and consistency.

`te_widgets` provides a robust set of UI components, form builders, and layout utilities that adhere to a unified design system. From powerful data tables and dynamic forms to responsive sidebars and polished input fields, this package aims to reduce boilerplate and ensure visual consistency across your app.

![Screenshot 1](https://raw.githubusercontent.com/teranes10/flutter-libs/master/packages/te_widgets/screenshot-1.png)
![Screenshot 2](https://raw.githubusercontent.com/teranes10/flutter-libs/master/packages/te_widgets/screenshot-2.png)
![Screenshot 3](https://raw.githubusercontent.com/teranes10/flutter-libs/master/packages/te_widgets/screenshot-3.png)


## ✨ Key Features

*   **🖥️ Responsive Layouts**: Built-in `TLayout` with responsive `TSidebar` (drawer/rail/minimized modes) integration.
*   **📝 Advanced Forms**:
    *   **`TFormBuilder`**: Create complex forms with validation and state management easily.
    *   **Rich Input Fields**: `TTextField`, `TNumberField` (decimal/integer), `TTagsField`, `TSelect`, `TMultiSelect`, `TDatePicker`, `TTimePicker`, and `TFilePicker`.
    *   **Validation**: Built-in validation mixins and rules (`required`, `email`, `min/max`, etc.).
*   **📊 Powerful Data Tables**:
    *   **`TDataTable`**: Server-side pagination, sorting, filtering, expandable rows, and sticky headers.
    *   **`TCrudTable`**: A wrapper for rapid CRUD operations.
*   **🎨 Theming System**:
    *   Extensive `TTheme` extension for granular control over widget styling (Buttons, Inputs, Tables, Cards, etc.) independent of the global material theme.
    *   Dark mode support out of the box.
*   **🧩 Atoms & Molecules**:
    *   **Buttons**: `TButton` with variants (solid, tonal, outline, icon, text) and loading states.
    *   **Chips**: `TChip` with various styles.
    *   **Dialogs & Overlays**: `TModal`, `TAlert`, `TPopup`, and `TTooltip`.
    *   **Cards**: `TCard` with standardized elevations and padding.

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  te_widgets: ^2.0.4
```

## 🚀 Getting Started

### 1. Setup Theme

Wrap your application with the `TTheme` extensions or configure your `ThemeData` to utilize `te_widgets` defaults.

```dart
import 'package:te_widgets/te_widgets.dart';

MaterialApp(
  theme: ThemeData(
    extensions: [
      TWidgetThemeExtension.light, // Or .dark
    ],
  ),
  // ...
);
```

### 2. Basic Layout

Use `TLayout` to quickly scaffold a responsive application structure with a sidebar.

```dart
TLayout(
  logo: TLogo(text: 'My App'),
  items: [
    TSidebarItem(icon: Icons.dashboard, text: 'Dashboard', route: '/'),
    TSidebarItem(icon: Icons.settings, text: 'Settings', route: '/settings'),
  ],
  child: MyPage(),
);
```

### 3. Building a Form

Use `TFormBuilder` to create robust forms with validation.

```dart
class UserForm extends TFormBase {
  final name = TFieldProp('');
  final email = TFieldProp('');
  final role = TFieldProp<String?>(null);

  @override
  List<TFormField> get fields => [
    TFormField.text(name, 'Full Name', isRequired: true),
    TFormField.text(email, 'Email Address', 
      rules: [Validations.email('Invalid email')]
    ),
    TFormField.select<String, String, String>(
        role, 
        'Role',
        options: ['Admin', 'User', 'Guest'],
        itemText: (item) => item,
        itemKey: (item) => item,
    ),
  ];
}

// In your widget:
final form = UserForm();

// Show as a modal
TFormService.show(context, form);
```

### 4. Data Tables

Create sophisticated tables with minimal code.

```dart
TDataTable<User, int>(
  headers: [
    TTableHeader.text('ID', (user) => user.id.toString()),
    TTableHeader.text('Name', (user) => user.name),
    TTableHeader.chip('Status', 
      (user) => user.status, 
      color: (user) => user.isActive ? Colors.green : Colors.red
    ),
  ],
  onLoad: (options) async {
    // Fetch data from API based on options.page, options.search, etc.
    return await fetchUsers(options);
  },
);
```

## 🛠️ Widgets Overview

| Category | Widgets |
|----------|---------|
| **Inputs** | `TTextField`, `TNumberField`, `TSelect`, `TMultiSelect`, `TCheckbox`, `TSwitch`, `TRadio` |
| **Pickers** | `TDatePicker`, `TTimePicker`, `TFilePicker` |
| **Display** | `TCard`, `TChip`, `TBadge`, `TAvatar`, `TImage` |
| **Feedback** | `TAlert`, `TToast`, `TModal`, `TLoading` |
| **Layout** | `TLayout`, `TSidebar`, `THeader`, `TFooter` |
| **Data** | `TList`, `TTable`, `TDataTable`, `TCrudTable` |

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
