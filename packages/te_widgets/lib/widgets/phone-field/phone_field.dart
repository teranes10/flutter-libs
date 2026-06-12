import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TPhoneField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final bool isRequired;
  final bool disabled;
  final TCountry? initialCountry;
  final ValueChanged<String>? onValueChanged;
  final String? value;
  final List<String? Function(String?)>? rules;

  const TPhoneField({
    super.key,
    this.label,
    this.placeholder,
    this.isRequired = false,
    this.disabled = false,
    this.initialCountry,
    this.onValueChanged,
    this.value,
    this.rules,
  });

  @override
  State<TPhoneField> createState() => _TPhoneFieldState();
}

class _TPhoneFieldState extends State<TPhoneField> {
  late TCountry _selectedCountry;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ?? TCountries.all.first;
    if (widget.value != null) {
      _controller.text = widget.value!;
    }
  }

  @override
  void didUpdateWidget(TPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  void _showCountryPicker() {
    if (widget.disabled) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TBottomSheet(
        title: 'Select Country',
        showCloseButton: true,
        height: MediaQuery.of(context).size.height * 0.7,
        onClose: () => Navigator.pop(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: TCountries.all.length,
                  itemBuilder: (context, index) {
                    final country = TCountries.all[index];
                    return ListTile(
                      leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                      title: Text(country.name),
                      trailing: Text(country.dialCode, style: TextStyle(color: context.colors.onSurfaceVariant)),
                      onTap: () {
                        setState(() {
                          _selectedCountry = country;
                          // Clear or reformat text if country changes?
                          // Usually better to let the user adjust, but we definitely need to update formatter.
                          _controller.clear();
                        });
                        Navigator.pop(context);
                        _notifyChanged();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _notifyChanged() {
    final fullNumber = '${_selectedCountry.dialCode} ${_controller.text.replaceAll(' ', '')}';
    widget.onValueChanged?.call(fullNumber);
  }

  @override
  Widget build(BuildContext context) {
    return TTextField(
      label: widget.label,
      placeholder: widget.placeholder ?? _selectedCountry.format,
      isRequired: widget.isRequired,
      disabled: widget.disabled,
      textController: _controller,
      onValueChanged: (_) => _notifyChanged(),
      rules: widget.rules,
      keyboardType: TextInputType.phone,
      inputFormatters: [PhoneNumberInputFormatter(format: _selectedCountry.format)],
      preWidget: GestureDetector(
        onTap: _showCountryPicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: context.colors.outlineVariant)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_selectedCountry.flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(_selectedCountry.dialCode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
