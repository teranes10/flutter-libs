part of 'form_builder.dart';

class TFieldProp<T> {
  T? _value;
  ValueNotifier<T?>? _valueNotifier;
  final T? initialValue;
  final ValueChanged<T?>? onValueChanged;
  final Map<TFieldProp, _TPropSubscriber> _subscribers = {};

  bool _wasUserInput = false;

  TFieldProp(T value, {bool useNotifier = false, this.onValueChanged})
      : _value = value,
        initialValue = value,
        _valueNotifier = useNotifier ? ValueNotifier(value) : null;

  T get value => _value as T;

  ValueNotifier<T?>? get valueNotifier => _valueNotifier;

  bool get wasUserInput => _wasUserInput;

  set value(T newValue) => _setValue(newValue);

  void _setUserValue(T? newValue) {
    if (!_wasUserInput) _wasUserInput = true;
    _setValue(newValue);
  }

  void _setValue(T? newValue) {
    if (_value == newValue) return;

    _value = newValue;
    _valueNotifier?.value = newValue;
    onValueChanged?.call(newValue);

    // Collect subscribers to remove first
    final toRemove = <TFieldProp>[];

    for (final entry in _subscribers.entries) {
      if (entry.value.cancelOnUserEdit && entry.key._wasUserInput) {
        toRemove.add(entry.key);
        continue;
      }
      entry.value.onValueChanged(newValue);
    }

    // Remove after iteration
    for (final key in toRemove) {
      _subscribers.remove(key);
    }
  }

  void reset() => _setValue(initialValue);

  void subscribe<V>(TFieldProp<V> source, T Function(V val) formatter, {bool cancelOnUserEdit = false}) {
    _valueNotifier ??= ValueNotifier<T>(value);

    final subscriber = _TPropSubscriber(
      cancelOnUserEdit: cancelOnUserEdit,
      onValueChanged: (value) => _setValue(formatter(value)),
    );

    source._subscribers[this] = subscriber;
  }

  void subscribeToMany(List<TFieldProp> sources, T Function() setter, {bool cancelOnUserEdit = false}) {
    _valueNotifier ??= ValueNotifier<T>(value);

    for (final source in sources) {
      final subscriber = _TPropSubscriber(
        cancelOnUserEdit: cancelOnUserEdit,
        onValueChanged: (value) => _setValue(setter()),
      );

      source._subscribers[this] = subscriber;
    }
  }

  void unsubscribe(TFieldProp<T> source) {
    source._subscribers.remove(this);
  }

  void dispose() {
    _valueNotifier?.dispose();
    _subscribers.clear();

    if (value is TFormBase) {
      (value as TFormBase).dispose();
    }

    if (value is List<TFormBase>) {
      for (var f in (value as List<TFormBase>)) {
        f.dispose();
      }
    }
  }

  @override
  String toString() => value.toString();
}

class _TPropSubscriber {
  final ValueChanged<dynamic> onValueChanged;
  final bool cancelOnUserEdit;

  _TPropSubscriber({
    required this.onValueChanged,
    this.cancelOnUserEdit = false,
  });
}
