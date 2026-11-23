part of 'form_builder.dart';

/// Drives section navigation and validation feedback for a [TFormBuilder].
///
/// Pass it to [TFormBuilder.controller] and use it to build the form footer:
/// show **Next** until [isLast], then **Save**. [TFormService] and the CRUD
/// table inline form do this automatically.
///
/// - Tabs / accordion: sections are freely navigable; [next] just moves on
///   (and flags the section it left if it still has errors).
/// - Steppers: [next] and [goTo] refuse to pass a step with errors; the
///   step is flagged, its errors shown and the first one scrolled into view.
///
/// ```dart
/// final controller = TFormController();
///
/// TFormBuilder(input: form, controller: controller);
///
/// ListenableBuilder(
///   listenable: controller,
///   builder: (context, _) => controller.isLast
///       ? TButton(text: 'Save', onPressed: (_) => save())
///       : TButton(text: 'Next', onPressed: (_) => controller.next()),
/// );
///
/// Future<void> save() async {
///   if (!await controller.validate()) return; // flags, navigates and scrolls to the first error
///   ...
/// }
/// ```
class TFormController extends ChangeNotifier {
  _TFormBuilderState? _state;

  /// The builder that owns the sections. Differs from [_state] when the tabs
  /// are a nested field (`TFormField.tabs`) inside a form's regular fields.
  _TFormBuilderState? _sections;
  bool _disposed = false;

  TFormType? _type;
  int _index = 0;
  int _count = 0;

  /// Index of the visible section (tab/step). Always 0 for single-section forms.
  int get index => _index;

  /// Number of sections (tabs/steps); 0 for a form without sub-form tabs.
  int get sectionCount => _count;

  /// The layout currently rendered, or null for a form without sections.
  TFormType? get formType => _count > 0 ? _type : null;

  /// Whether sections are shown one at a time (tabs or stepper).
  bool get isPaged => _count > 1 && (_type?.isPaged ?? false);

  /// Whether sections must be completed in order.
  bool get isStepper => isPaged && _type!.isStepper;

  /// Whether the visible section is the last one (or the form is not paged).
  /// The footer shows Save when true and Next otherwise.
  bool get isLast => !isPaged || _index >= _count - 1;

  /// Whether there is a previous section to go back to.
  bool get canGoBack => isPaged && _index > 0;

  /// Moves to the next section. For steppers, fails (returns false) and
  /// reveals the errors when the current step is invalid.
  Future<bool> next() async => await (_sections ?? _state)?._goTo(_index + 1, fromNext: true) ?? false;

  /// Moves to the previous section.
  Future<bool> back() async => await (_sections ?? _state)?._goTo(_index - 1) ?? false;

  /// Moves to section [index]. For steppers every step before [index] must be valid.
  Future<bool> goTo(int index) async => await (_sections ?? _state)?._goTo(index) ?? false;

  /// Validates the whole form. Returns true when valid; otherwise calls [revealErrors].
  Future<bool> validate() async {
    final state = _state;
    if (state == null || !state._hasErrors) return true;
    await revealErrors();
    return false;
  }

  /// Flags every section with errors, opens the first one, shows each field's
  /// error message in it and scrolls the first invalid field into view.
  Future<void> revealErrors() async {
    final state = _state;
    if (state == null) return;
    final target = await state._revealErrors();
    if (target != null && target.mounted) state._scrollTo(target);
  }

  void _attach(_TFormBuilderState state) => _state = state;

  void _detach(_TFormBuilderState state) {
    if (_state == state) _state = null;
  }

  /// Claims navigation for a nested sections builder; false if another owns it.
  bool _claimSections(_TFormBuilderState state) {
    if (_sections != null && _sections != state) return false;
    _sections = state;
    return true;
  }

  void _releaseSections(_TFormBuilderState state) {
    if (_sections == state) {
      _sections = null;
      _report(null, 0, 0);
    }
  }

  /// Called by the builder during build; listeners are notified after the frame.
  void _report(TFormType? type, int index, int count) {
    if (type == _type && index == _index && count == _count) return;
    _type = type;
    _index = index;
    _count = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _state = null;
    _sections = null;
    super.dispose();
  }
}
