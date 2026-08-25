import 'package:flutter/material.dart';
import 'package:my_app/clients/posts_client.dart';
import 'package:my_app/models/post_dto.dart';
import 'package:te_widgets/te_widgets.dart';

class FormsPage extends StatelessWidget {
  const FormsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TButton(
          text: 'Show User Form Modal',
          onPressed: (_) async {
            final value = await TFormService.show(context, UserForm());
            if (value != null) {
              debugPrint('__save $value');
            }
          },
        ),
        const SizedBox(height: 12),
        TButton(
          text: 'Show Product Form (Sidebar)',
          onPressed: (_) async {
            final value = await TFormService.show(context, ProductForm());
            if (value != null) {
              debugPrint('__save product $value');
            }
          },
        ),
        const SizedBox(height: 12),
        TButton(
          text: 'Show Tabbed Sub-forms Modal',
          onPressed: (_) async {
            final value = await TFormService.show(context, TabbedSettingsForm());
            if (value != null) {
              debugPrint('__save tabbed $value');
            }
          },
        ),
      ],
    );
  }
}

class UserForm extends TFormBase {
  final select = TFieldProp<PostDto?>(null, useNotifier: true);
  final firstName = TFieldProp(
    '',
    onValueChanged: (v) {
      debugPrint(v);
    },
  );
  final lastName = TFieldProp('');
  final username = TFieldProp('', useNotifier: true);
  final email = TFieldProp('');
  final check = TFieldProp(false);
  final toggle = TFieldProp(false);
  final brandColor = TFieldProp<Color?>(null);
  final files = TFieldProp<List<TFile>>([]);
  final options = TFieldProp<List<String>>([]);
  final subForm = TFieldProp(SubForm());
  final subForms = TFieldProp(List<SubForm>.empty());
  final internal1 = TFieldProp('');
  final internal2 = TFieldProp('');

  UserForm() {
    email.subscribe(firstName, (v) => v, cancelOnUserEdit: true);
    username.subscribeToMany([firstName, lastName], () => "${firstName.value} ${lastName.value}", cancelOnUserEdit: true);
  }

  @override
  double get formWidth => 850;

  @override
  List<TFormField> get fields {
    return [
      TFormField.select<PostDto, PostDto, int>(
        select,
        "Select",
        onLoad: (o) async {
          final (items, total) = await PostsClient().fetchPosts(start: o.offset, limit: o.itemsPerPage, query: o.search);
          if (o.page == 1) {
            select.value = items.first;
          }
          return TLoadResult(items, total);
        },
        itemText: (x) => x.title,
        itemKey: (x) => x.id,
      ),
      TFormField.text(firstName, 'First Name').size(6),
      TFormField.text(lastName, 'Last Name').size(6),
      TFormField.text(username, 'Username', isRequired: true),
      TFormField.text(email, 'Email'),
      TFormField.checkboxGroup(options, "Options", [
        TCheckboxGroupItem.map("Option 1"),
        TCheckboxGroupItem.map("Option 2"),
        TCheckboxGroupItem.map("Option 3"),
      ]).size(6),
      TFormField.checkbox(check, "Check").size(3),
      TFormField.toggle(toggle, "Toggle").size(3),
      TFormField.colorPicker(brandColor, "Brand Color", onlyPlusIcon: true).size(6),
      TFormField.filePicker(files, "File Picker"),
      TFormField.groupFields(
        [TFormField.text(internal1, 'Internal Field 1').size(6), TFormField.text(internal2, 'Internal Field 2').size(6)],
        label: 'Manual Group',
        description: 'Grouped without TFormBase',
      ),
      TFormField.group(subForm, label: 'Sub Form', description: 'Sub Title'),
      TFormField.items(subForms, () => SubForm(), label: 'Sub Forms', buttonLabel: 'Add New'),
    ];
  }

  // @override
  // void onValueChanged() {
  //   if (!username.wasUserInput) {
  //     username.value = "${firstName.value} ${lastName.value}";
  //   }
  // }

  @override
  String toString() {
    return 'UserForm firstName: $firstName, lastName: $lastName, username: $username, email: $email, internal1: $internal1, internal2: $internal2, items: ${subForms.value}';
  }
}

class SubForm extends TFormBase {
  final title = TFieldProp('');
  final value = TFieldProp(0.0);
  final value2 = TFieldProp(0.0);

  @override
  List<TFormField> get fields {
    return [
      TFormField.text(title, "Title", isRequired: true).size(6),
      TFormField.number<double>(value, "Value").size(3),
      TFormField.number<double>(value2, "Value 2").size(3),
    ];
  }

  @override
  String toString() {
    return 'Sub Form title: $title, value: $value, value2: $value2';
  }
}

/// Demo form that showcases [sidebarFields].
///
/// Layout:
/// - lg (≥1024 px): main details (8 cols) | sidebar metadata (4 cols)
/// - sm / md: main details full-width, then sidebar metadata below.
class ProductForm extends TFormBase {
  final name = TFieldProp('');
  final category = TFieldProp<String?>(null);
  final description = TFieldProp('');
  final price = TFieldProp(0.0);
  final stock = TFieldProp(0.0);
  final sku = TFieldProp('');
  final tags = TFieldProp<List<String>>([]);
  final featured = TFieldProp(false);
  final active = TFieldProp(true);

  @override
  double get formWidth => 1200;

  @override
  String get formTitle => 'Add New Product';

  @override
  String get formActionName => 'Save Product';

  // Main form fields — occupy the left 8-column panel on desktop.
  @override
  List<TFormField> get fields => [
    TFormField.text(name, 'Product Name', isRequired: true),
    TFormField.select<String, String, String>(
      category,
      'Category',
      onLoad: (_) async => TLoadResult(['Electronics', 'Clothing', 'Books', 'Home & Garden', 'Sports'], 5),
      itemText: (x) => x,
      itemKey: (x) => x,
    ),
    TFormField.text(description, 'Description').size(12),
    TFormField.number<double>(price, 'Price (USD)').size(6),
    TFormField.number<double>(stock, 'Stock Quantity').size(6),
    TFormField.checkboxGroup(tags, 'Tags', [
      TCheckboxGroupItem.map('New Arrival'),
      TCheckboxGroupItem.map('Best Seller'),
      TCheckboxGroupItem.map('On Sale'),
      TCheckboxGroupItem.map('Limited Edition'),
    ]),
  ];

  // Sidebar fields — occupy the right 4-column panel on desktop,
  // stacked below main fields on mobile / tablet.
  @override
  List<TFormField>? get sidebarFields => [
    TFormField.text(sku, 'SKU / Barcode'),
    TFormField.toggle(featured, 'Featured Product'),
    TFormField.toggle(active, 'Active / Visible'),
  ];

  @override
  String toString() =>
      'ProductForm name: $name, category: $category, price: $price, '
      'stock: $stock, sku: $sku, featured: $featured, active: $active, tags: ${tags.value}';
}

/// Demo form that showcases horizontal and vertical tab sub forms.
class TabbedSettingsForm extends TFormBase {
  final siteName = TFieldProp('My Awesome Site');
  final siteUrl = TFieldProp('https://example.com');
  final maintenanceMode = TFieldProp(false);

  final smtpHost = TFieldProp('');
  final smtpPort = TFieldProp(587);
  final smtpUser = TFieldProp('');

  final enable2FA = TFieldProp(true);
  final sessionTimeout = TFieldProp(30);

  final notifyEmail = TFieldProp(true);
  final notifyPush = TFieldProp(false);

  @override
  double get formWidth => 800;

  @override
  String get formTitle => 'Application Settings';

  @override
  String get formActionName => 'Save Settings';

  @override
  List<TFormField> get fields => [
        TFormField.verticalTabs(
          tabWidth: 160,
          tabs: [
            TFormTab.fields(
              title: 'General',
              icon: Icons.tune,
              fields: [
                TFormField.text(siteName, 'Site Name', isRequired: true),
                TFormField.text(siteUrl, 'Site URL', isRequired: true),
                TFormField.toggle(maintenanceMode, 'Maintenance Mode'),
              ],
            ),
            TFormTab.fields(
              title: 'Email / SMTP',
              icon: Icons.mail_outline,
              fields: [
                TFormField.text(smtpHost, 'SMTP Host').size(8),
                TFormField.number<int>(smtpPort, 'Port').size(4),
                TFormField.text(smtpUser, 'Username'),
              ],
            ),
            TFormTab.fields(
              title: 'Security',
              icon: Icons.security,
              fields: [
                TFormField.toggle(enable2FA, 'Require 2FA for all users'),
                TFormField.number<int>(sessionTimeout, 'Session Timeout (minutes)'),
              ],
            ),
            TFormTab.fields(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              fields: [
                TFormField.toggle(notifyEmail, 'Email Notifications'),
                TFormField.toggle(notifyPush, 'Push Notifications'),
              ],
            ),
          ],
        ),
      ];

  @override
  String toString() =>
      'TabbedSettingsForm siteName: $siteName, siteUrl: $siteUrl, 2FA: $enable2FA';
}

