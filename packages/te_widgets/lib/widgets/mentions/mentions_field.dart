import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// A mentionable entity (e.g. a user) suggested by [TMentionsField].
class TMentionOption {
  /// Unique id, inserted as `@id` (or displayed via [label] if you render
  /// mentions client-side with a rich-text renderer).
  final String id;

  /// Display label shown in the suggestion list and inserted into the text.
  final String label;

  /// Optional avatar/leading widget shown in the suggestion row.
  final Widget? avatar;

  const TMentionOption({required this.id, required this.label, this.avatar});
}

/// A multi-line text input that pops a `@`-triggered suggestion list for
/// tagging users/entities inline (comments, notes, chat composer).
///
/// ```dart
/// TMentionsField(
///   options: teamMembers,
///   placeholder: 'Write a comment… use @ to mention someone',
///   onSubmitted: (text) => postComment(text),
/// )
/// ```
class TMentionsField extends StatefulWidget {
  /// Candidate entities offered when `@` is typed.
  final List<TMentionOption> options;

  /// Placeholder text.
  final String? placeholder;

  /// Called with the current raw text (including `@label` tokens) on change.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (e.g. presses enter in a single-line use).
  final ValueChanged<String>? onSubmitted;

  /// Number of visible text rows.
  final int rows;

  const TMentionsField({
    super.key,
    required this.options,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.rows = 3,
  });

  @override
  State<TMentionsField> createState() => _TMentionsFieldState();
}

class _TMentionsFieldState extends State<TMentionsField> {
  final _layerLink = LayerLink();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<TMentionOption> _matches = [];
  int _mentionStart = -1;

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    widget.onChanged?.call(text);
    final cursor = _controller.selection.baseOffset;
    if (cursor < 0) {
      _removeOverlay();
      return;
    }

    final upToCursor = text.substring(0, cursor);
    final atIndex = upToCursor.lastIndexOf('@');
    if (atIndex == -1) {
      _removeOverlay();
      return;
    }

    final query = upToCursor.substring(atIndex + 1);
    if (query.contains(' ') || query.contains('\n')) {
      _removeOverlay();
      return;
    }

    _mentionStart = atIndex;
    final matches = widget.options.where((o) => o.label.toLowerCase().contains(query.toLowerCase())).take(6).toList();

    setState(() => _matches = matches);
    matches.isEmpty ? _removeOverlay() : _showOverlay();
  }

  void _insertMention(TMentionOption option) {
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset;
    final before = text.substring(0, _mentionStart);
    final after = text.substring(cursor);
    final mentionText = '@${option.label} ';
    final newText = '$before$mentionText$after';

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: before.length + mentionText.length),
    );
    widget.onChanged?.call(newText);
    _removeOverlay();
  }

  void _showOverlay() {
    _removeOverlay();
    final fieldWidth = (context.findRenderObject() as RenderBox?)?.size.width ?? 280;
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final colors = overlayContext.colors;
        return Positioned(
          width: fieldWidth,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, -8),
            followerAnchor: Alignment.bottomLeft,
            targetAnchor: Alignment.topLeft,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              color: colors.surface,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _matches.length,
                  itemBuilder: (context, i) {
                    final option = _matches[i];
                    return InkWell(
                      onTap: () => _insertMention(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            if (option.avatar != null) ...[option.avatar!, const SizedBox(width: 8)],
                            Text(option.label, style: TextStyle(fontSize: 13.5, color: colors.onSurface)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TTextField<String?>(
        textController: _controller,
        focusNode: _focusNode,
        rows: widget.rows,
        placeholder: widget.placeholder,
        onValueChanged: (text) => _onTextChanged(text ?? ''),
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}
