import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/button/button.dart';
import 'package:te_widgets/widgets/form/form_builder.dart';

class FormsPage extends StatelessWidget {
  const FormsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TFormBuilder(input: userForm),
      TButton(
        text: 'Save',
        onPressed: (_) =>
            print('__save ${userForm.firstName.value}, ${userForm.lastName.value}, ${userForm.username.value}, ${userForm.email.value}'),
      )
    ]);
  }
}

class UserForm extends TFormBase {
  final firstName = TFieldProp('');
  final lastName = TFieldProp('');
  final username = TFieldProp('');
  final email = TFieldProp('');

  @override
  List<TFormField> get fields {
    return [
      TFormField.text(firstName, 'First Name').size(6),
      TFormField.text(lastName, 'Last Name').size(6),
      TFormField.text(username, 'Username', isRequired: true),
      TFormField.text(email, 'Email'),
    ];
  }
}

final userForm = UserForm();
