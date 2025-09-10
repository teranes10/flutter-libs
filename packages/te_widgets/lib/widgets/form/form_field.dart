part of 'form_builder.dart';

class TFormField<T> {
  final TFieldProp<T> prop;
  final Widget Function(ValueChanged<T>) builder;

  late final Widget _field;
  TFieldSize _size = const TFieldSize();
  VoidCallback? _callback;

  TFormField({required this.builder, required this.prop}) {
    _field = builder.call(_onValueChanged);
  }

  void _onValueChanged(T value) {
    prop._setUserValue(value);
    _callback?.call();
  }

  void _attach(VoidCallback callback) {
    assert(_callback == null, 'Form field value listener already attached.');
    _callback = callback;
  }

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
        valueNotifier: prop.valueNotifier,
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
        valueNotifier: prop.valueNotifier,
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
        valueNotifier: prop.valueNotifier,
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
        valueNotifier: prop.valueNotifier,
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
        valueNotifier: prop.valueNotifier,
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
        valueNotifier: prop.valueNotifier,
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
        valueNotifier: prop.valueNotifier,
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
        valueNotifier: prop.valueNotifier,
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

  static TFormField<T> group<T extends TFormBase>(TFieldProp<T> prop, {String? label}) {
    return TFormField<T>(
      prop: prop,
      builder: (onValueChanged) => TFormBuilder(
        label: label,
        input: prop.value,
        onValueChanged: () {
          onValueChanged(prop.value);
        },
      ),
    );
  }

  static TFormField<List<T>> items<T extends TFormBase>(
    TFieldProp<List<T>> prop,
    T Function() onNewItem, {
    String? label,
    String buttonLabel = 'Add New',
    TItemAddPosition itemAddPosition = TItemAddPosition.first,
  }) {
    return TFormField<List<T>>(
      prop: prop,
      builder: (onValueChanged) => TItemsFormBuilder(
        label: label,
        buttonLabel: buttonLabel,
        onNewItem: onNewItem,
        itemAddPosition: itemAddPosition,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: (value) {
          onValueChanged(value);
        },
      ),
    );
  }

  static TFormField<bool> toggle(
    TFieldProp<bool> prop,
    String? label, {
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(bool?)>? rules,
    Color? color,
  }) {
    return TFormField<bool>(
      prop: prop,
      builder: (onValueChanged) => TSwitch(
        color: color,
        label: label,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
      ),
    );
  }

  static TFormField<bool?> checkbox(
    TFieldProp<bool?> prop,
    String? label, {
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(bool?)>? rules,
    Color? color,
  }) {
    return TFormField<bool?>(
      prop: prop,
      builder: (onValueChanged) => TCheckbox(
        color: color,
        label: label,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
      ),
    );
  }

  static TFormField<List<T>> checkboxGroup<T>(
    TFieldProp<List<T>> prop,
    String? label,
    List<TCheckboxGroupItem<T>> items, {
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(List<T>?)>? rules,
    Color? color,
  }) {
    return TFormField<List<T>>(
      prop: prop,
      builder: (onValueChanged) => TCheckboxGroup<T>(
        items: items,
        color: color,
        label: label,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
      ),
    );
  }

  static TFormField<List<TFile>> filePicker<T>(
    TFieldProp<List<TFile>> prop,
    String? label, {
    bool isRequired = false,
    bool disabled = false,
    List<String? Function(List<TFile>?)>? rules,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
    int? maxFiles,
    TFileType fileType = TFileType.any,
  }) {
    return TFormField<List<TFile>>(
      prop: prop,
      builder: (onValueChanged) => TFilePicker(
        label: label,
        isRequired: isRequired,
        disabled: disabled,
        rules: rules,
        allowMultiple: allowMultiple,
        allowedExtensions: allowedExtensions,
        maxFiles: maxFiles,
        fileType: fileType,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
      ),
    );
  }
}
