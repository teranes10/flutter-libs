part of 'form_builder.dart';

class TFieldProp<T> {
  T _value;

  TFieldProp(T value) : _value = value;

  T get value => _value;

  @override
  String toString() {
    return value.toString();
  }
}
