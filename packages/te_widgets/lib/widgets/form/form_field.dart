part of 'form_builder.dart';

class TFormField<T> {
  final TFieldProp<T> prop;
  final Widget Function(ValueChanged<T>) builder;

  final Widget _field;
  TFieldSize _size = const TFieldSize();

  TFormField({
    required this.prop,
    required this.builder,
  }) : _field = builder((value) {
          prop._value = value;
        });

  TFormField<T> size(int md, {int? sm, int? lg}) {
    _size = TFieldSize(sm: sm, md: md, lg: lg);
    return this;
  }

  static TFormField<String> text(
    TFieldProp<String> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(String?)>? rules,
    int? rows,
  }) {
    return TFormField<String>(
      prop: prop,
      builder: (onValueChanged) => TTextField(
        label: label,
        tag: tag,
        placeholder: placeholder,
        helperText: helperText,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        value: prop.value,
        onValueChanged: onValueChanged,
        rows: rows,
      ),
    );
  }

  static TFormField<List<String>> tags(
    TFieldProp<List<String>> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(List<String>?)>? rules,
  }) {
    return TFormField<List<String>>(
      prop: prop,
      builder: (onValueChanged) => TTagsField(
        label: label,
        tag: tag,
        placeholder: placeholder,
        helperText: helperText,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        value: prop.value,
        onValueChanged: onValueChanged,
      ),
    );
  }

  static TFormField<T> number<T extends num>(
    TFieldProp<T> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(T?)>? rules,
    T? min,
    T? max,
    T? increment,
    T? decrement,
    int? decimals,
  }) {
    return TFormField<T>(
      prop: prop,
      builder: (onValueChanged) => TNumberField<T>(
        label: label,
        tag: tag,
        placeholder: placeholder,
        helperText: helperText,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        value: prop.value,
        onValueChanged: onValueChanged,
        min: min,
        max: max,
        increment: increment,
        decrement: decrement,
        decimals: decimals,
      ),
    );
  }

  static TFormField<DateTime> date(
    TFieldProp<DateTime> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(DateTime?)>? rules,
    DateTime? firstDate,
    DateTime? lastDate,
    DateFormat? format,
  }) {
    return TFormField<DateTime>(
      prop: prop,
      builder: (onValueChanged) => TDatePicker(
        label: label,
        tag: tag,
        placeholder: placeholder,
        helperText: helperText,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        value: prop.value,
        onValueChanged: onValueChanged,
        firstDate: firstDate,
        lastDate: lastDate,
        format: format,
      ),
    );
  }

  static TFormField<TimeOfDay> time(
    TFieldProp<TimeOfDay> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(TimeOfDay?)>? rules,
    DateFormat? format,
  }) {
    return TFormField<TimeOfDay>(
      prop: prop,
      builder: (onValueChanged) => TTimePicker(
        label: label,
        tag: tag,
        placeholder: placeholder,
        helperText: helperText,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        value: prop.value,
        onValueChanged: onValueChanged,
        format: format,
      ),
    );
  }

  static TFormField<DateTime> dateTime(
    TFieldProp<DateTime> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(DateTime?)>? rules,
    DateTime? firstDate,
    DateTime? lastDate,
    DateFormat? format,
  }) {
    return TFormField<DateTime>(
      prop: prop,
      builder: (onValueChanged) => TDateTimePicker(
        label: label,
        tag: tag,
        placeholder: placeholder,
        helperText: helperText,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        value: prop.value,
        onValueChanged: onValueChanged,
        firstDate: firstDate,
        lastDate: lastDate,
        format: format,
      ),
    );
  }

  static TFormField<V> select<T, V>(
    TFieldProp<V> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(V?)>? rules,
    List<T>? items,
    ItemTextAccessor<T>? itemText,
    ItemValueAccessor<T, V>? itemValue,
    ItemChildrenAccessor<T>? itemChildren,
    ItemKeyAccessor<T>? itemKey,
    bool multiLevel = false,
    int itemsPerPage = 10,
    TLoadListener<T>? onLoad,
    int searchDelay = 2500,
  }) {
    return TFormField<V>(
      prop: prop,
      builder: (onValueChanged) => TSelect(
        label: label,
        tag: tag,
        placeholder: placeholder,
        helperText: helperText,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        value: prop.value,
        onValueChanged: onValueChanged,
        items: items,
        itemText: itemText,
        itemValue: itemValue,
        itemChildren: itemChildren,
        itemKey: itemKey,
        multiLevel: multiLevel,
        itemsPerPage: itemsPerPage,
        onLoad: onLoad,
        searchDelay: searchDelay,
      ),
    );
  }

  static TFormField<List<V>> multiSelect<T, V>(
    TFieldProp<List<V>> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(List<V>?)>? rules,
    List<T>? items,
    ItemTextAccessor<T>? itemText,
    ItemValueAccessor<T, V>? itemValue,
    ItemChildrenAccessor<T>? itemChildren,
    ItemKeyAccessor<T>? itemKey,
    bool multiLevel = false,
    int itemsPerPage = 10,
    TLoadListener<T>? onLoad,
    int searchDelay = 2500,
  }) {
    return TFormField<List<V>>(
      prop: prop,
      builder: (onValueChanged) => TMultiSelect(
        label: label,
        tag: tag,
        placeholder: placeholder,
        helperText: helperText,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        value: prop.value,
        onValueChanged: onValueChanged,
        items: items,
        itemText: itemText,
        itemValue: itemValue,
        itemChildren: itemChildren,
        itemKey: itemKey,
        multiLevel: multiLevel,
        itemsPerPage: itemsPerPage,
        onLoad: onLoad,
        searchDelay: searchDelay,
      ),
    );
  }
}
