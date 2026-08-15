import 'package:flutter/material.dart';
import 'package:te_editor/te_editor.dart';
import 'package:te_widgets/te_widgets.dart';

@immutable
class RichTextFieldPage extends StatefulWidget {
  const RichTextFieldPage({super.key});

  @override
  State<RichTextFieldPage> createState() => _RichTextFieldPageState();
}

class _RichTextFieldPageState extends State<RichTextFieldPage> {
  final _formKey = GlobalKey<FormState>();
  String? _documentDelta = '[{"insert":"Hello World!\\n"}]';

  @override
  Widget build(BuildContext context) {
    return TPageWrapper(
      title: 'Rich Text Field',
      child: Form(
        key: _formKey,
        child: TGridRow(
          children: [
            TGridCol(
              child: TRichTextField(
                label: 'Rich Description',
                placeholder: 'Enter rich text here...',
                value: _documentDelta,
                onValueChanged: (val) {
                  setState(() {
                    _documentDelta = val;
                  });
                },
              ),
            ),
            TGridCol(
              child: TTextField(label: 'Raw JSON Delta', value: _documentDelta, readOnly: true, rows: 10),
            ),
          ],
        ),
      ),
    );
  }
}
