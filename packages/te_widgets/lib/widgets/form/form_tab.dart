part of 'form_builder.dart';

/// A tab configuration for sub forms within [TFormBuilder] and [TFormField.tabs].
///
/// Each [TFormTab] represents a tab containing either a form model ([input])
/// or a list of form fields ([fields]), with optional sidebar fields and styling.
///
/// Example:
/// ```dart
/// TFormTab(
///   title: 'Account',
///   icon: Icons.person,
///   input: AccountForm(),
/// )
/// ```
class TFormTab {
  /// The value identifying this tab.
  ///
  /// Defaults to [title] if not provided.
  final dynamic value;

  /// The title/label displayed on the tab.
  final String title;

  /// Optional subtitle or helper text.
  final String? subtitle;

  /// Optional icon displayed on the tab.
  final IconData? icon;

  /// The form model for this tab's content.
  final TFormBase? input;

  /// Manual list of fields for this tab's content (alternative to [input]).
  final List<TFormField>? fields;

  /// Optional sidebar fields for this tab.
  final List<TFormField>? sidebarFields;

  /// Optional sidebar span sizing for this tab.
  final TGridSize? sidebarSize;

  /// Optional footer widget displayed at the bottom of this tab.
  final Widget? footer;

  /// Whether this tab is enabled.
  final bool isEnabled;

  /// Whether to show an active indicator dot on the tab.
  final bool isActive;

  /// Optional metadata attached to this tab.
  final Map<String, dynamic>? data;

  /// Creates a tab item for sub forms.
  const TFormTab({
    this.value,
    required this.title,
    this.subtitle,
    this.icon,
    this.input,
    this.fields,
    this.sidebarFields,
    this.sidebarSize,
    this.footer,
    this.isEnabled = true,
    this.isActive = false,
    this.data,
  }) : assert(input != null || fields != null, 'Provide either "input" or "fields" for TFormTab.');

  /// Creates a form tab from a [TFormBase] model.
  factory TFormTab.form({
    dynamic value,
    String? title,
    String? subtitle,
    IconData? icon,
    required TFormBase form,
    bool isEnabled = true,
    bool isActive = false,
    Widget? footer,
    Map<String, dynamic>? data,
  }) {
    return TFormTab(
      value: value ?? title ?? form.formTitle,
      title: title ?? form.formTitle,
      subtitle: subtitle,
      icon: icon,
      input: form,
      footer: footer ?? form.footer,
      isEnabled: isEnabled,
      isActive: isActive,
      data: data,
    );
  }

  /// Creates a form tab from a list of [TFormField]s.
  factory TFormTab.fields({
    dynamic value,
    required String title,
    String? subtitle,
    IconData? icon,
    required List<TFormField> fields,
    List<TFormField>? sidebarFields,
    TGridSize? sidebarSize,
    bool isEnabled = true,
    bool isActive = false,
    Widget? footer,
    Map<String, dynamic>? data,
  }) {
    return TFormTab(
      value: value ?? title,
      title: title,
      subtitle: subtitle,
      icon: icon,
      fields: fields,
      sidebarFields: sidebarFields,
      sidebarSize: sidebarSize,
      isEnabled: isEnabled,
      isActive: isActive,
      footer: footer,
      data: data,
    );
  }

  /// Converts this [TFormTab] to a [TTab] widget representation.
  TTab<dynamic> toTab([dynamic effectiveValue]) {
    return TTab<dynamic>(
      value: effectiveValue ?? value ?? title,
      text: title,
      icon: icon,
      isEnabled: isEnabled,
      isActive: isActive,
      data: data,
    );
  }
}
