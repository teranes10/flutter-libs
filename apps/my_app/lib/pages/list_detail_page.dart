import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class Contact {
  final String id;
  final String name;
  final String role;
  final String email;
  final String phone;
  final String imageUrl;

  Contact({required this.id, required this.name, required this.role, required this.email, required this.phone, required this.imageUrl});

  Contact copyWith({String? id, String? name, String? role, String? email, String? phone, String? imageUrl}) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class ContactForm extends TFormBase {
  final name = TFieldProp('');
  final role = TFieldProp('');
  final email = TFieldProp('');
  final phone = TFieldProp('');
  final imageUrl = TFieldProp('');

  ContactForm([Contact? contact]) {
    if (contact != null) {
      name.value = contact.name;
      role.value = contact.role;
      email.value = contact.email;
      phone.value = contact.phone;
      imageUrl.value = contact.imageUrl;
    }
  }

  @override
  double get formWidth => 600;

  @override
  List<TFormField> get fields => [
    TFormField.text(name, 'Name', isRequired: true).size(6),
    TFormField.text(role, 'Role', isRequired: true).size(6),
    TFormField.text(email, 'Email', isRequired: true).size(6),
    TFormField.text(phone, 'Phone').size(6),
    TFormField.text(imageUrl, 'Image URL'),
  ];
}

class ListDetailPage extends StatefulWidget {
  const ListDetailPage({super.key});

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  final List<Contact> _contacts = [
    Contact(
      id: '2',
      name: 'Jane Doe',
      role: 'Product Manager',
      email: 'jane.doe@example.com',
      phone: '+1 (555) 014-9218',
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80',
    ),
    Contact(
      id: '3',
      name: 'John Smith',
      role: 'Senior Developer',
      email: 'john.smith@example.com',
      phone: '+1 (555) 012-3847',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80',
    ),
  ];

  late final TListController<Contact, String> _controller;

  @override
  void initState() {
    super.initState();
    _controller = TListController<Contact, String>(items: _contacts, itemKey: (c) => c.id, expansionMode: TExpansionMode.single);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TListDetail<Contact, String>(
        controller: _controller,
        itemTitle: (c) => c.name,
        itemSubTitle: (c) => c.role,
        itemImageUrl: (c) => c.imageUrl,
        actions: (contact) => [
          TButton(
            type: TButtonType.icon,
            icon: Icons.edit_rounded,
            onTap: () {
              _controller.beginEditItem(contact);
            },
          ),
          const SizedBox(width: 8),
          TButton(
            type: TButtonType.icon,
            icon: Icons.delete_outline_rounded,
            onTap: () {
              setState(() {
                _contacts.removeWhere((c) => c.id == contact.id);
                _controller.updateItems(_contacts);
                _controller.collapseAll();
              });
              TToastService.success(context, '${contact.name} deleted successfully');
            },
          ),
        ],
        detailBuilder: (context, item, index) {
          final contact = item.data;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      TImage(url: contact.imageUrl, size: 100, border: const CircleBorder()),
                      const SizedBox(height: 16),
                      Text(contact.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(contact.role, style: TextStyle(fontSize: 16, color: context.colors.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TKeyValueSection(
                  values: [
                    TKeyValue.text('Email', contact.email),
                    TKeyValue.text('Phone', contact.phone),
                    TKeyValue.text('ID', contact.id),
                  ],
                ),
              ],
            ),
          );
        },
        createBuilder: (context) {
          final form = ContactForm();
          return TFormBuilder(
            input: form,
            footer: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: TButton(
                text: 'Create Contact',
                onPressed: (_) async {
                  final newContact = Contact(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: form.name.value,
                    role: form.role.value,
                    email: form.email.value,
                    phone: form.phone.value,
                    imageUrl: form.imageUrl.value.isNotEmpty
                        ? form.imageUrl.value
                        : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
                  );
                  setState(() {
                    _contacts.add(newContact);
                    _controller.updateItems(_contacts);
                    _controller.cancelCreateItem();
                    _controller.expandDetail(newContact.id);
                  });
                  TToastService.success(context, '${newContact.name} created successfully');
                },
              ),
            ),
          );
        },
        editBuilder: (context, item, index) {
          final contact = item.data;
          final form = ContactForm(contact);
          return TFormBuilder(
            input: form,
            footer: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: TButton(
                text: 'Update Contact',
                onPressed: (_) async {
                  final updatedContact = contact.copyWith(
                    name: form.name.value,
                    role: form.role.value,
                    email: form.email.value,
                    phone: form.phone.value,
                    imageUrl: form.imageUrl.value,
                  );
                  setState(() {
                    final idx = _contacts.indexWhere((c) => c.id == contact.id);
                    if (idx != -1) {
                      _contacts[idx] = updatedContact;
                    }
                    _controller.updateItems(_contacts);
                    _controller.cancelEditItem();
                    _controller.expandDetail(updatedContact.id);
                  });
                  TToastService.success(context, '${updatedContact.name} updated successfully');
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
