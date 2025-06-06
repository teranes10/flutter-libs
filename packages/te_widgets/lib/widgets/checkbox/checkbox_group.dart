import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/checkbox/checkbox.dart';
import 'package:te_widgets/widgets/checkbox/checkbox_config.dart';

class TCheckboxGroup<T> extends StatefulWidget {
  final List<T> modelValue;
  final ValueChanged<List<T>>? onChanged;
  final List<TCheckboxGroupItem<T>> items;
  final String? label;
  final String? tag;
  final bool required;
  final bool inline;
  final String color;
  final TCheckboxSize size;
  final TCheckboxIcon icon;
  final List<String Function(List<T>?)>? rules;

  const TCheckboxGroup({
    Key? key,
    required this.modelValue,
    this.onChanged,
    required this.items,
    this.label,
    this.tag,
    this.required = false,
    this.inline = true,
    this.color = 'primary',
    this.size = TCheckboxSize.medium,
    this.icon = TCheckboxIcon.check,
    this.rules,
  }) : super(key: key);

  @override
  State<TCheckboxGroup<T>> createState() => _TCheckboxGroupState<T>();
}

class _TCheckboxGroupState<T> extends State<TCheckboxGroup<T>> {
  List<T> _selectedValues = [];
  List<String> _errors = [];

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.modelValue);
    _validateField();
  }

  @override
  void didUpdateWidget(TCheckboxGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modelValue != widget.modelValue) {
      setState(() {
        _selectedValues = List.from(widget.modelValue);
      });
      _validateField();
    }
  }

  void _validateField() {
    if (widget.rules != null) {
      setState(() {
        _errors = widget.rules!.map((rule) => rule(_selectedValues)).where((error) => error.isNotEmpty).toList();
      });
    }
  }

  void _onItemChanged(T value, bool isChecked) {
    setState(() {
      if (isChecked) {
        if (!_selectedValues.contains(value)) {
          _selectedValues.add(value);
        }
      } else {
        _selectedValues.remove(value);
      }
    });

    _validateField();
    widget.onChanged?.call(List.from(_selectedValues));
  }

  Widget _buildHeader() {
    if (widget.label == null && widget.tag == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (widget.label != null)
            Text(
              widget.label!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          if (widget.required)
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          if (widget.tag != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.tag!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckboxes() {
    final hasErrors = _errors.isNotEmpty;

    Widget checkboxContainer = Container(
      decoration: BoxDecoration(
        border: hasErrors ? Border.all(color: Colors.red) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: hasErrors ? const EdgeInsets.all(8) : null,
      child: widget.inline
          ? Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _buildCheckboxWidgets(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildCheckboxWidgets(),
            ),
    );

    return checkboxContainer;
  }

  List<Widget> _buildCheckboxWidgets() {
    return widget.items.map((item) {
      final isChecked = _selectedValues.contains(item.value);

      return TCheckbox<T>(
        value: item.value,
        label: item.label,
        modelValue: isChecked,
        color: item.color ?? widget.color,
        size: item.size ?? widget.size,
        icon: item.icon ?? widget.icon,
        onChanged: (checked) => _onItemChanged(item.value, checked),
      );
    }).toList();
  }

  Widget _buildErrors() {
    if (_errors.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _errors
            .map((error) => Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '• $error',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildCheckboxes(),
        _buildErrors(),
      ],
    );
  }
}
