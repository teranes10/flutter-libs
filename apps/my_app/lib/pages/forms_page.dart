import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class FormsPage extends StatelessWidget {
  const FormsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TButton(
          text: 'Show User Form Modal',
          onPressed: (_) async {
            final value = await TFormService.show(context, UserForm());
            if (value != null) {
              print('__save $value');
            }
          })
    ]);
  }
}

class UserForm extends TFormBase {
  final firstName = TFieldProp('', onValueChanged: (v) {
    print(v);
  });
  final lastName = TFieldProp('');
  final username = TFieldProp('', useNotifier: true);
  final email = TFieldProp('');
  final check = TFieldProp(false);
  final toggle = TFieldProp(false);
  final options = TFieldProp<List<String>>([]);
  final subForm = TFieldProp(SubForm());
  final subForms = TFieldProp(List<SubForm>.empty());

  UserForm() {
    email.subscribe(firstName, (v) => v, cancelOnUserEdit: true);
    username.subscribeToMany([firstName, lastName], () => "${firstName.value} ${lastName.value}", cancelOnUserEdit: true);
  }

  @override
  double get formWidth => 850;

  @override
  List<TFormField> get fields {
    return [
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
      TFormField.group(subForm, label: 'Sub Form'),
      TFormField.items(subForms, () => SubForm(), label: 'Sub Forms', buttonLabel: 'Add New')
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
    return 'UserForm firstName: $firstName, lastName: $lastName, username: $username, email: $email, items: ${subForms.value}';
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
