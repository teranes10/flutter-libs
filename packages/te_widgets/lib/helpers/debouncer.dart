import 'dart:async';
import 'package:flutter/material.dart';

class TDebouncer {
  final int milliseconds;
  Timer? _timer;

  TDebouncer({required this.milliseconds});

  void run(VoidCallback action, [int? milliseconds]) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds ?? this.milliseconds), action);
  }

  bool get isActive => _timer?.isActive ?? false;

  void cancel() => _timer?.cancel();

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
