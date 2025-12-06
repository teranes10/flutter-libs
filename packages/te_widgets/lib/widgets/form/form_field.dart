part of 'form_builder.dart';

/// A form field wrapper with factory methods for all input types.
///
/// `TFormField` provides a unified interface for creating form fields with:
/// - Automatic value binding to TFieldProp
/// - Factory methods for all widget types
/// - Responsive sizing (sm, md, lg)
/// - Integration with TFormBuilder
///
/// ## Factory Methods
///
/// - `text()` - Text input
/// - `number()` - Number input
/// - `date()` - Date picker
/// - `time()` - Time picker
/// - `dateTime()` - Date-time picker
/// - `select()` - Single selection
/// - `multiSelect()` - Multiple selection
/// - `toggle()` - Switch
/// - `checkbox()` - Checkbox
/// - `checkboxGroup()` - Checkbox group
/// - `filePicker()` - File upload
/// - `group()` - Nested form
/// - `items()` - Dynamic list of forms
///
/// ## Usage Example
///
/// ```dart
/// final name = TFieldProp<String>('');
///
/// TFormField.text(name, 'Name',
///   isRequired: true,
///   rules: [Validations.required],
/// ).size(6)  // 6 columns on medium screens
/// ```
///
/// Type parameter:
/// - [T]: The type of the field value
///
/// See also:
/// - [TFieldProp] for reactive properties
/// - [TFormBuilder] for form layout
class TFormField<T> {
  /// The reactive property for this field.
  final TFieldProp<T> prop;

  /// Builder function that creates the widget.
  final Widget Function(ValueChanged<T?>) builder;

  late final Widget _field;
  TFieldSize _size = const TFieldSize();
  VoidCallback? _callback;

  /// Creates a form field.
  TFormField({required this.builder, required this.prop}) {
    _field = builder.call(_onValueChanged);
  }

  void _onValueChanged(T? value) {
    prop._setUserValue(value);
    _callback?.call();
  }

  void _attach(VoidCallback callback) {
    assert(_callback == null, 'Form field value listener already attached.');
    _callback = callback;
  }

  /// Sets the responsive size of the field.
  ///
  /// - [md]: Medium screen size (required, 1-12 columns)
  /// - [sm]: Small screen size (optional, 1-12 columns)
  /// - [lg]: Large screen size (optional, 1-12 columns)
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
    bool autoFocus = false,
    bool readOnly = false,
    TTextFieldTheme? theme,
    FocusNode? focusNode,
    VoidCallback? onTap,
    TextEditingController? textController,
    List<String? Function(String?)>? rules,
    int rows = 1,
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
        autoFocus: autoFocus,
        readOnly: readOnly,
        theme: theme,
        focusNode: focusNode,
        onTap: onTap,
        textController: textController,
        rules: rules,
        rows: rows,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
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
    bool autoFocus = false,
    bool readOnly = false,
    TTagsFieldTheme? theme,
    FocusNode? focusNode,
    VoidCallback? onTap,
    TTagsController? textController,
    List<String? Function(List<String>?)>? rules,
    String? inputValue,
    ValueChanged<String>? onInputChanged,
    bool addTagOnEnter = true,
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
        autoFocus: autoFocus,
        readOnly: readOnly,
        theme: theme,
        focusNode: focusNode,
        onTap: onTap,
        textController: textController,
        rules: rules,
        addTagOnEnter: addTagOnEnter,
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
    bool autoFocus = false,
    bool readOnly = false,
    TNumberFieldTheme? theme,
    FocusNode? focusNode,
    VoidCallback? onTap,
    TextEditingController? textController,
    List<String? Function(T?)>? rules,
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
        autoFocus: autoFocus,
        readOnly: readOnly,
        theme: theme,
        focusNode: focusNode,
        onTap: onTap,
        textController: textController,
        rules: rules,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
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
    bool autoFocus = false,
    bool readOnly = false,
    TTextFieldTheme? theme,
    FocusNode? focusNode,
    VoidCallback? onTap,
    TextEditingController? textController,
    List<String? Function(DateTime?)>? rules,
    VoidCallback? onShow,
    VoidCallback? onHide,
    DateFormat? format,
    DateTime? firstDate,
    DateTime? lastDate,
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
        autoFocus: autoFocus,
        readOnly: readOnly,
        theme: theme,
        focusNode: focusNode,
        onTap: onTap,
        textController: textController,
        rules: rules,
        onShow: onShow,
        onHide: onHide,
        format: format,
        firstDate: firstDate,
        lastDate: lastDate,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
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
    bool autoFocus = false,
    bool readOnly = false,
    TTextFieldTheme? theme,
    FocusNode? focusNode,
    VoidCallback? onTap,
    TextEditingController? textController,
    List<String? Function(TimeOfDay?)>? rules,
    VoidCallback? onShow,
    VoidCallback? onHide,
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
        autoFocus: autoFocus,
        readOnly: readOnly,
        theme: theme,
        focusNode: focusNode,
        onTap: onTap,
        textController: textController,
        rules: rules,
        onShow: onShow,
        onHide: onHide,
        format: format,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
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
    bool autoFocus = false,
    bool readOnly = false,
    TTextFieldTheme? theme,
    FocusNode? focusNode,
    VoidCallback? onTap,
    TextEditingController? textController,
    List<String? Function(DateTime?)>? rules,
    VoidCallback? onShow,
    VoidCallback? onHide,
    DateFormat? format,
    DateTime? firstDate,
    DateTime? lastDate,
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
        autoFocus: autoFocus,
        readOnly: readOnly,
        theme: theme,
        focusNode: focusNode,
        onTap: onTap,
        textController: textController,
        rules: rules,
        onShow: onShow,
        onHide: onHide,
        format: format,
        firstDate: firstDate,
        lastDate: lastDate,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
      ),
    );
  }

  static TFormField<V?> select<T, V, K>(
    TFieldProp<V?> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    bool autoFocus = false,
    bool readOnly = false,
    TTextFieldTheme? theme,
    FocusNode? focusNode,
    VoidCallback? onTap,
    TextEditingController? textController,
    List<String? Function(V?)>? rules,
    List<T>? items,
    ItemKeyAccessor<T, K>? itemKey,
    ItemValueAccessor<T, V>? itemValue,
    ItemTextAccessor<T>? itemText,
    ItemTextAccessor<T>? itemSubText,
    ItemTextAccessor<T>? itemImageUrl,
    ItemChildrenAccessor<T>? itemChildren,
    int? itemsPerPage = 6,
    TLoadListener<T>? onLoad,
    int? searchDelay,
  }) {
    return TFormField<V?>(
      prop: prop,
      builder: (onValueChanged) => TSelect<T, V, K>(
        label: label,
        tag: tag,
        placeholder: placeholder,
        helperText: helperText,
        isRequired: isRequired,
        disabled: disabled,
        autoFocus: autoFocus,
        readOnly: readOnly,
        theme: theme,
        focusNode: focusNode,
        onTap: onTap,
        textController: textController,
        rules: rules,
        items: items,
        itemText: itemText,
        itemSubText: itemSubText,
        itemImageUrl: itemImageUrl,
        itemChildren: itemChildren,
        itemValue: itemValue,
        itemKey: itemKey,
        itemsPerPage: itemsPerPage,
        onLoad: onLoad,
        searchDelay: searchDelay,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
      ),
    );
  }

  static TFormField<List<V>> multiSelect<T, V, K>(
    TFieldProp<List<V>> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    bool autoFocus = false,
    bool readOnly = false,
    TTagsFieldTheme? theme,
    FocusNode? focusNode,
    VoidCallback? onTap,
    TTagsController? textController,
    List<String? Function(List<V>?)>? rules,
    List<T>? items,
    ItemKeyAccessor<T, K>? itemKey,
    ItemValueAccessor<T, V>? itemValue,
    ItemTextAccessor<T>? itemText,
    ItemTextAccessor<T>? itemSubText,
    ItemTextAccessor<T>? itemImageUrl,
    ItemChildrenAccessor<T>? itemChildren,
    int itemsPerPage = 10,
    TLoadListener<T>? onLoad,
    int? searchDelay,
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
        autoFocus: autoFocus,
        readOnly: readOnly,
        theme: theme,
        focusNode: focusNode,
        onTap: onTap,
        textController: textController,
        rules: rules,
        items: items,
        itemText: itemText,
        itemSubText: itemSubText,
        itemImageUrl: itemImageUrl,
        itemChildren: itemChildren,
        itemValue: itemValue,
        itemKey: itemKey,
        itemsPerPage: itemsPerPage,
        onLoad: onLoad,
        searchDelay: searchDelay,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
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
    FocusNode? focusNode,
    bool isRequired = false,
    List<String? Function(bool?)>? rules,
    bool autoFocus = false,
    bool disabled = false,
    Color? color,
    TInputSize? size,
  }) {
    return TFormField<bool>(
      prop: prop,
      builder: (onValueChanged) => TSwitch(
        label: label,
        focusNode: focusNode,
        isRequired: isRequired,
        rules: rules,
        autoFocus: autoFocus,
        disabled: disabled,
        color: color,
        size: size,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
      ),
    );
  }

  static TFormField<bool?> checkbox(
    TFieldProp<bool?> prop,
    String? label, {
    FocusNode? focusNode,
    bool isRequired = false,
    List<String? Function(bool?)>? rules,
    bool autoFocus = false,
    bool disabled = false,
    Color? color,
    TInputSize? size,
  }) {
    return TFormField<bool?>(
      prop: prop,
      builder: (onValueChanged) => TCheckbox(
        label: label,
        focusNode: focusNode,
        isRequired: isRequired,
        rules: rules,
        autoFocus: autoFocus,
        disabled: disabled,
        color: color,
        size: size,
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
    String? tag,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    bool autoFocus = false,
    TInputFieldTheme? theme,
    FocusNode? focusNode,
    VoidCallback? onTap,
    List<String? Function(List<T>?)>? rules,
    Color? color,
    bool block = true,
    bool vertical = false,
  }) {
    return TFormField<List<T>>(
      prop: prop,
      builder: (onValueChanged) => TCheckboxGroup<T>(
        label: label,
        tag: tag,
        helperText: helperText,
        isRequired: isRequired,
        disabled: disabled,
        autoFocus: autoFocus,
        theme: theme,
        focusNode: focusNode,
        onTap: onTap,
        rules: rules,
        items: items,
        color: color,
        block: block,
        vertical: vertical,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
      ),
    );
  }

  static TFormField<List<TFile>> filePicker<T>(
    TFieldProp<List<TFile>> prop,
    String? label, {
    String? tag,
    String? placeholder,
    String? helperText,
    bool isRequired = false,
    bool disabled = false,
    bool autoFocus = false,
    TFilePickerTheme? theme,
    FocusNode? focusNode,
    VoidCallback? onTap,
    List<String? Function(List<TFile>?)>? rules,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
    TFileType fileType = TFileType.any,
  }) {
    return TFormField<List<TFile>>(
      prop: prop,
      builder: (onValueChanged) => TFilePicker(
        label: label,
        tag: tag,
        placeholder: placeholder,
        helperText: helperText,
        isRequired: isRequired,
        disabled: disabled,
        autoFocus: autoFocus,
        theme: theme,
        focusNode: focusNode,
        onTap: onTap,
        rules: rules,
        allowMultiple: allowMultiple,
        allowedExtensions: allowedExtensions,
        fileType: fileType,
        value: prop.value,
        valueNotifier: prop.valueNotifier,
        onValueChanged: onValueChanged,
      ),
    );
  }
}
