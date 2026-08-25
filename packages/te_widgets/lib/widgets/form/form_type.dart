part of 'form_builder.dart';

/// Form layout presentation types for forms with sub-forms.
enum TFormType {
  accordion,
  horizontalTabs,
  verticalTabs;

  /// User-friendly display label.
  String get label {
    switch (this) {
      case TFormType.accordion:
        return 'Accordion';
      case TFormType.horizontalTabs:
        return 'Horizontal Tabs';
      case TFormType.verticalTabs:
        return 'Vertical Tabs';
    }
  }

  /// Icon representing this form type.
  IconData get icon {
    switch (this) {
      case TFormType.accordion:
        return Icons.view_agenda_outlined;
      case TFormType.horizontalTabs:
        return Icons.tab_outlined;
      case TFormType.verticalTabs:
        return Icons.view_sidebar_outlined;
    }
  }

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

  /// Resolves initial form type synchronously using in-memory cache, [PageStorage], or default.
  static TFormType getInitialType(BuildContext context, TFormBase form) {
    if (!form.persistFormType) {
      return form.defaultFormType ?? TFormType.horizontalTabs;
    }

    final key = resolveKey(context, form);

    // 1. In-memory cache
    if (_inMemoryCache.containsKey(key)) {
      return _inMemoryCache[key]!;
    }

    // 2. PageStorage
    final pageStorage = PageStorage.maybeOf(context);
    if (pageStorage != null) {
      final saved = pageStorage.readState(context, identifier: 'form_type_$key') as String?;
      if (saved != null) {
        final match = TFormType.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => form.defaultFormType ?? TFormType.horizontalTabs,
        );
        _inMemoryCache[key] = match;
        return match;
      }
    }

    return form.defaultFormType ?? TFormType.horizontalTabs;
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
      final saved = prefs.getString('te_form_type_$key');
      if (saved != null) {
        final match = TFormType.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => notifier.value,
        );
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

/// Toggle switch button for switching form types (accordion, horizontal tabs, vertical tabs).
class TFormTypeToggleSwitch extends StatelessWidget {
  /// The reactive notifier holding the active [TFormType].
  final ValueNotifier<TFormType> notifier;

  /// Optional callback invoked when the form type is changed.
  final ValueChanged<TFormType>? onChanged;

  /// Whether to cycle through form types on single button taps. Defaults to true.
  final bool cycle;

  const TFormTypeToggleSwitch({
    super.key,
    required this.notifier,
    this.onChanged,
    this.cycle = true,
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
          initialIndex: currentType.index,
          onIndexChanged: (index) {
            final newType = TFormType.values[index];
            notifier.value = newType;
            onChanged?.call(newType);
          },
          items: [
            TButtonGroupItem(
              icon: Icons.view_agenda_outlined,
              tooltip: 'Form Layout: Accordion',
              active: currentType == TFormType.accordion,
            ),
            TButtonGroupItem(
              icon: Icons.tab_outlined,
              tooltip: 'Form Layout: Horizontal Tabs',
              active: currentType == TFormType.horizontalTabs,
            ),
            TButtonGroupItem(
              icon: Icons.view_sidebar_outlined,
              tooltip: 'Form Layout: Vertical Tabs',
              active: currentType == TFormType.verticalTabs,
            ),
          ],
        );

        if (cycle) {
          return Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: buttonGroup,
          );
        }

        return buttonGroup;
      },
    );
  }
}
