import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Visual style of [TTabs].
enum TTabStyle {
  /// Classic tabs with an underline (or side) indicator.
  underline,

  /// Segmented control: a filled track with a raised pill under the selected tab.
  segmented,
}

/// A tab item for use with TTabs.
///
/// Type parameter:
/// - [T]: The type of the tab value
class TTab<T> {
  /// The value associated with this tab.
  final T value;

  /// The text label for the tab.
  final String? text;

  /// The icon for the tab.
  final dynamic icon;

  /// Whether the tab is enabled.
  final bool isEnabled;

  /// Whether to show an active indicator dot.
  final bool isActive;

  /// Optional count shown as a pill after the label (e.g. `All (12)`).
  final int? count;

  /// Optional content builder for this tab.
  ///
  /// When provided, this content will be displayed when the tab is selected.
  /// Used with [TTabContent] or [TTabView] widgets.
  final Widget Function(BuildContext context)? content;

  /// Optional additional data to attach to this tab.
  ///
  /// Can be used to pass custom metadata, configuration, or any other
  /// information that should be associated with the tab.
  ///
  /// Example:
  /// ```dart
  /// TTab(
  ///   value: 0,
  ///   text: 'Products',
  ///   data: {'color': Colors.blue, 'badge': 5, 'route': '/products'},
  /// )
  /// ```
  final Map<String, dynamic>? data;

  /// Permission (`String` or [TPermission]) required to see/use this tab.
  final Object? permission;

  /// Overrides the denied behaviour; defaults to hidden for tabs.
  final TAuthMode? onDenied;

  /// Creates a tab item.
  const TTab({
    required this.value,
    this.text,
    this.icon,
    this.isEnabled = true,
    this.isActive = false,
    this.count,
    this.content,
    this.data,
    this.permission,
    this.onDenied,
  }) : assert(icon != null || text != null, 'Either icon or text must be provided');

  /// Copy of this tab with [isEnabled] forced to false.
  TTab<T> asDisabled() => TTab<T>(
        value: value,
        text: text,
        icon: icon,
        isEnabled: false,
        isActive: isActive,
        count: count,
        content: content,
        data: data,
        permission: permission,
        onDenied: onDenied,
      );
}

extension TTabAuthX<T> on List<TTab<T>> {
  /// Tabs that are not hidden by permission, with denied-disabled ones switched off.
  List<TTab<T>> authorized(BuildContext context) {
    final result = <TTab<T>>[];
    for (final tab in this) {
      final r = context.authResolve(tab.permission, target: TAuthTarget.tab, onDenied: tab.onDenied);
      if (r.isHidden) continue;
      result.add(r.isDisabled ? tab.asDisabled() : tab);
    }
    return result;
  }
}
