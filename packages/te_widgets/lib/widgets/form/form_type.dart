part of 'form_builder.dart';

/// Form layout presentation types for forms with sub-forms.
///
/// - Tabs and accordion allow free navigation between sections.
/// - Steppers are sequential: a later step can only be opened once every
///   step before it is valid.
enum TFormType {
  accordion,
  horizontalTabs,
  verticalTabs,
  horizontalStepper,
  verticalStepper;

  /// Free-navigation layouts (the toggle set for regular forms).
  static const List<TFormType> freeTypes = [accordion, horizontalTabs, verticalTabs];

  /// Sequential layouts (the toggle set for forms whose default is a stepper).
  static const List<TFormType> stepperTypes = [horizontalStepper, verticalStepper];

  /// Whether this layout forces sections to be completed in order.
  bool get isStepper => this == horizontalStepper || this == verticalStepper;

  /// Whether this layout shows one section at a time (tabs or stepper),
  /// so the form footer shows Next until the last section.
  bool get isPaged => this != accordion;

  /// The tabs layout with the same axis, used where a stepper does not fit
  /// (e.g. a nested sub-form inheriting a stepper scope).
  TFormType get asTabs => switch (this) {
        horizontalStepper => horizontalTabs,
        verticalStepper => verticalTabs,
        _ => this,
      };

  /// User-friendly display label.
  String get label => switch (this) {
        accordion => 'Accordion',
        horizontalTabs => 'Horizontal Tabs',
        verticalTabs => 'Vertical Tabs',
        horizontalStepper => 'Horizontal Stepper',
        verticalStepper => 'Vertical Stepper',
      };

  /// Icon representing this form type.
  dynamic get icon => switch (this) {
        accordion => HugeIcons.strokeRoundedViewAgenda,
        horizontalTabs => HugeIcons.strokeRoundedBrowser,
        verticalTabs => HugeIcons.strokeRoundedSidebarLeft,
        horizontalStepper => HugeIcons.strokeRoundedProgress02,
        verticalStepper => HugeIcons.strokeRoundedLeftToRightListNumber,
      };

  /// Tooltip description for toggle buttons.
  String get tooltip => 'Form Layout: $label';
}

/// Helper service for persisting and retrieving user form type layout preference.
class TFormTypePersistence {
  static final Map<String, TFormType> _inMemoryCache = {};

  /// Clears the in-memory cache of saved form types.
  static void clearCache() {
    _inMemoryCache.clear();
  }

  /// Resolves the storage identifier key for a form model.
  static String resolveKey(BuildContext? context, TFormBase form) {
    if (form.storageKey != null && form.storageKey!.isNotEmpty) {
      return form.storageKey!;
    }
    return form.runtimeType.toString();
  }

  static TFormType _defaultOf(TFormBase form) {
    final types = form.availableFormTypes;
    return form.defaultFormType ?? (types.contains(TFormType.horizontalTabs) ? TFormType.horizontalTabs : types.first);
  }

  /// Parses a persisted name, accepting only layouts the form offers.
  static TFormType? _parse(TFormBase form, String? saved) {
    if (saved == null) return null;
    for (final type in form.availableFormTypes) {
      if (type.name == saved) return type;
    }
    return null;
  }

  /// Resolves initial form type synchronously using in-memory cache, [PageStorage], or default.
  static TFormType getInitialType(BuildContext context, TFormBase form) {
    if (!form.persistFormType) return _defaultOf(form);

    final key = resolveKey(context, form);

    // 1. In-memory cache
    final cached = _inMemoryCache[key];
    if (cached != null && form.availableFormTypes.contains(cached)) return cached;

    // 2. PageStorage
    final pageStorage = PageStorage.maybeOf(context);
    final match = _parse(form, pageStorage?.readState(context, identifier: 'form_type_$key') as String?);
    if (match != null) {
      _inMemoryCache[key] = match;
      return match;
    }

    return _defaultOf(form);
  }

  /// Asynchronously loads persisted form type from [SharedPreferences] into [notifier].
  static Future<void> loadPersistedType(
    BuildContext context,
    TFormBase form,
    ValueNotifier<TFormType> notifier,
  ) async {
    if (!form.persistFormType) return;
    final key = resolveKey(context, form);

    try {
      final prefs = await SharedPreferences.getInstance();
      final match = _parse(form, prefs.getString('te_form_type_$key'));
      if (match != null) {
        if (notifier.value != match) {
          notifier.value = match;
          _inMemoryCache[key] = match;
        }
      }
    } catch (_) {}
  }

  /// Saves selected form type into memory, [PageStorage], and [SharedPreferences].
  static void saveType(BuildContext context, TFormBase form, TFormType type) {
    if (!form.persistFormType) return;
    final key = resolveKey(context, form);

    _inMemoryCache[key] = type;

    final pageStorage = PageStorage.maybeOf(context);
    if (pageStorage != null) {
      pageStorage.writeState(context, type.name, identifier: 'form_type_$key');
    }

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('te_form_type_$key', type.name);
    }).catchError((_) {});
  }
}

/// Inherited scope providing the active [TFormType] to descendant form widgets.
class TFormTypeScope extends InheritedNotifier<ValueNotifier<TFormType>> {
  const TFormTypeScope({
    super.key,
    required ValueNotifier<TFormType> formTypeNotifier,
    required super.child,
  }) : super(notifier: formTypeNotifier);

  /// Retrieves the current form type if available within the widget tree.
  static TFormType? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TFormTypeScope>()?.notifier?.value;
  }

  /// Retrieves current form type or falls back to [TFormType.horizontalTabs].
  static TFormType of(BuildContext context) {
    return maybeOf(context) ?? TFormType.horizontalTabs;
  }
}

/// Extension for convenient access to [TFormType] on [BuildContext].
extension TFormTypeContextExt on BuildContext {
  /// Current [TFormType] from the nearest [TFormTypeScope], defaulting to [TFormType.horizontalTabs].
  TFormType get formType => TFormTypeScope.of(this);

  /// Current [TFormType] from the nearest [TFormTypeScope], or null if not in a form type scope.
  TFormType? get maybeFormType => TFormTypeScope.maybeOf(this);
}

/// Toggle switch button for switching form types.
class TFormTypeToggleSwitch extends StatelessWidget {
  /// The reactive notifier holding the active [TFormType].
  final ValueNotifier<TFormType> notifier;

  /// Layouts offered by the toggle. Defaults to [TFormType.freeTypes];
  /// pass [TFormBase.availableFormTypes] to follow the form's choice.
  final List<TFormType> types;

  /// Optional callback invoked when the form type is changed.
  final ValueChanged<TFormType>? onChanged;

  /// Whether to cycle through form types on single button taps. Defaults to true.
  final bool cycle;

  const TFormTypeToggleSwitch({
    super.key,
    required this.notifier,
    this.onChanged,
    this.cycle = true,
    this.types = TFormType.freeTypes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ValueListenableBuilder<TFormType>(
      valueListenable: notifier,
      builder: (context, currentType, _) {
        final buttonGroup = TButtonGroup(
          cycle: cycle,
          type: TButtonGroupType.icon,
          size: TButtonSize.xs.copyWith(icon: 18),
          initialIndex: types.indexOf(currentType).clamp(0, types.length - 1),
          onIndexChanged: (index) {
            final newType = types[index];
            notifier.value = newType;
            onChanged?.call(newType);
          },
          items: [
            for (final type in types) TButtonGroupItem(icon: type.icon, tooltip: type.tooltip, active: currentType == type),
          ],
        );

        if (cycle) {
          final glass = TGlassStyle.resolve(context);
          return Container(
            decoration: BoxDecoration(
              // Glass: a frosted disc with a visible edge instead of an opaque near-white one.
              color: glass != null ? Colors.white.withAlpha(colors.isDarkMode ? 24 : 150) : colors.surfaceContainerLowest,
              shape: BoxShape.circle,
              border: glass != null ? Border.all(color: glass.fieldEdge(context)) : null,
            ),
            child: buttonGroup,
          );
        }

        return buttonGroup;
      },
    );
  }
}
