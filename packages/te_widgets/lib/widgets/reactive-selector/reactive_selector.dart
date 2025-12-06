import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A reactive widget that rebuilds only when selected value changes.
///
/// `TReactiveSelector` provides efficient rebuilds with:
/// - Selective listening to ValueListenable
/// - Only rebuilds when selector result changes
/// - Access to old and new values
/// - Performance optimization for complex state
///
/// ## Basic Usage
///
/// ```dart
/// final counter = ValueNotifier<int>(0);
///
/// TReactiveSelector<int, bool>(
///   listenable: counter,
///   selector: (count) => count > 10,
///   builder: (context, isAboveTen, oldValue) {
///     return Text(isAboveTen ? 'High' : 'Low');
///   },
/// )
/// ```
///
/// ## With Complex State
///
/// ```dart
/// final user = ValueNotifier<User>(currentUser);
///
/// TReactiveSelector<User, String>(
///   listenable: user,
///   selector: (user) => user.name,
///   builder: (context, name, oldName) {
///     if (oldName != null && oldName != name) {
///       print('Name changed from \$oldName to \$name');
///     }
///     return Text('Hello, \$name');
///   },
/// )
/// ```
///
/// Type parameters:
/// - [T]: The type of the listenable value
/// - [S]: The type of the selected value
///
/// See also:
/// - [ValueListenableBuilder] for simple listening
class TReactiveSelector<T, S> extends StatefulWidget {
  /// The value listenable to watch.
  final ValueListenable<T> listenable;

  /// Function to select a value from the listenable.
  final S Function(T) selector;

  /// Builder that receives the selected value and old value.
  final Widget Function(BuildContext context, S value, S? oldValue) builder;

  /// Creates a reactive selector.
  const TReactiveSelector({
    required this.listenable,
    required this.selector,
    required this.builder,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _TReactiveSelectorState<T, S>();
}

class _TReactiveSelectorState<T, S> extends State<TReactiveSelector<T, S>> {
  late S value;
  S? oldValue;

  @override
  void initState() {
    super.initState();
    value = widget.selector(widget.listenable.value);
    widget.listenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(TReactiveSelector<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_valueChanged);
      widget.listenable.addListener(_valueChanged);
    }

    final newValue = widget.selector(widget.listenable.value);
    oldValue = value;
    value = newValue;
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged() {
    final newValue = widget.selector(widget.listenable.value);
    if (value == newValue) return;

    setState(() {
      oldValue = value;
      value = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, oldValue);
  }
}
