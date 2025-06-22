part of 'form_builder.dart';

class TFieldProp<T> {
  T _value;
  final T initialValue;

  TFieldProp(T value)
      : _value = value,
        initialValue = value;

  T get value => _value;

  void reset() {
    _value = initialValue;
  }

  @override
  String toString() {
    return value.toString();
  }
}
