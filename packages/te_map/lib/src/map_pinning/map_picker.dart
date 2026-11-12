import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

import '../map.dart';
import 'package:latlong2/latlong.dart';
import '../place_autocomplete.dart';
import 'map_picker_controller.dart';
import 'previous_selections_list.dart';
import 'saved_locations_list.dart';

/// Static texts shared by every part of the picker.
class TMapPickerConfig {
  final String title;
  final String? googleMapApiKey;
  final String? placeholder;
  final String? fromLabel;
  final String? toLabel;
  final String? fromPlaceholder;
  final String? toPlaceholder;

  const TMapPickerConfig({
    required this.title,
    this.googleMapApiKey,
    this.placeholder,
    this.fromLabel,
    this.toLabel,
    this.fromPlaceholder,
    this.toPlaceholder,
  });

  String labelOf(TMapPointType type) => type == TMapPointType.from ? (fromLabel ?? 'Pickup Point') : (toLabel ?? 'Drop-off Point');

  String placeholderOf(TMapPointType type, bool isTwoPoints) {
    if (!isTwoPoints) return placeholder ?? 'Search address or place';
    return type == TMapPointType.from ? (fromPlaceholder ?? 'Search pickup location...') : (toPlaceholder ?? 'Search drop-off location...');
  }
}

/// Opens the picker through [TModalService.showAdaptive]: a modal on desktop,
/// a [TPageWrapper] page on mobile.
Future<TMapPickerResult?> showTMapPicker(
  BuildContext context, {
  required TMapPickerController controller,
  required TMapPickerConfig config,
}) {
  return TModalService.showAdaptive<TMapPickerResult>(
    context,
    (modal) => _PickerBody(controller: controller, config: config, onDone: modal.close, onCancel: modal.close),
    title: config.title.isEmpty ? 'Choose location' : config.title,
    width: 960,
  );
}

class _PickerBody extends StatelessWidget {
  final TMapPickerController controller;
  final TMapPickerConfig config;
  final ValueChanged<TMapPickerResult?> onDone;
  final VoidCallback onCancel;

  const _PickerBody({required this.controller, required this.config, required this.onDone, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final map = _MapPane(controller: controller, config: config);
    final info = _InfoCard(controller: controller, config: config);
    final search = _SearchFields(controller: controller, config: config);
    final results = _ResultsArea(controller: controller);

    final inModal = context.isDesktop;

    // Page mode and narrow modals scroll, so every block gets a fixed height.
    Widget stacked() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        search,
        const SizedBox(height: 12),
        SizedBox(height: 240, child: map),
        const SizedBox(height: 12),
        SizedBox(height: 300, child: results),
        const SizedBox(height: 8),
        info,
        const SizedBox(height: 12),
        _Footer(controller: controller, onDone: onDone, expandConfirm: true),
      ],
    );

    if (!inModal) return stacked();

    // TPageWrapper (used for both modal and page) already pads the content.
    return LayoutBuilder(builder: (context, box) => box.maxWidth < 720 ? stacked() : wide(colors));
  }

  Widget wide(ColorScheme colors) {
    final map = _MapPane(controller: controller, config: config);
    final info = _InfoCard(controller: controller, config: config);
    final search = _SearchFields(controller: controller, config: config);
    final results = _ResultsArea(controller: controller);

    return SizedBox(
      height: controller.isTwoPoints ? 600 : 540,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        search,
                        const SizedBox(height: 12),
                        Expanded(child: results),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: colors.outlineVariant),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: map),
                        const SizedBox(height: 12),
                        info,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Footer(controller: controller, onDone: onDone, onCancel: onCancel),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search fields
// ---------------------------------------------------------------------------

class _SearchFields extends StatelessWidget {
  final TMapPickerController controller;
  final TMapPickerConfig config;

  const _SearchFields({required this.controller, required this.config});

  Widget _field(BuildContext context, TMapPointType type) {
    final colors = context.colors;
    final two = controller.isTwoPoints;
    final focused = two && controller.active == type;
    final accent = type == TMapPointType.from ? Colors.green : Colors.redAccent;

    final base = context.theme.textFieldTheme;
    final icon = Padding(
      padding: const EdgeInsets.only(left: 4),
      child: two
          ? Icon(Icons.circle, size: 10, color: accent)
          : TIcon.raw(HugeIcons.strokeRoundedSearch01, size: 18, color: colors.onSurfaceVariant),
    );

    // The active field is marked by its own border colour (no extra outer outline).
    return TTextField<String?>(
      theme: base.copyWith(preWidget: icon, borderColor: focused ? WidgetStateProperty.all(colors.primary) : null),
      textController: type == TMapPointType.from ? controller.fromText : controller.toText,
      placeholder: config.placeholderOf(type, two),
      clearable: true,
      onTap: two ? () => controller.setActive(type) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isTwoPoints) return _field(context, TMapPointType.from);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(context, TMapPointType.from),
            Align(
              child: TButton(icon: HugeIcons.strokeRoundedArrowUpDown, type: TButtonType.softText, size: TSize.xs, onTap: controller.swap),
            ),
            _field(context, TMapPointType.to),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Results: saved / recent, temporarily replaced by suggestions while typing
// ---------------------------------------------------------------------------

class _ResultsArea extends StatefulWidget {
  final TMapPickerController controller;

  const _ResultsArea({required this.controller});

  @override
  State<_ResultsArea> createState() => _ResultsAreaState();
}

class _ResultsAreaState extends State<_ResultsArea> {
  int _tab = 0;
  // Saved/recent lists report address and coordinates in two calls; pair them up.
  String? _pendingAddress;

  TMapPickerController get c => widget.controller;

  void _picked(LatLng coords) {
    c.setPoint(coords, address: _pendingAddress);
    _pendingAddress = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        // Saved/recent stay mounted (offstage) so the save button can still reach the saved list.
        final browse = Offstage(
          offstage: c.suggesting,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TButton(
                  text: 'Use current location',
                  icon: HugeIcons.strokeRoundedNavigation03,
                  type: TButtonType.softText,
                  size: TSize.sm,
                  loading: c.locating,
                  onTap: c.useCurrentLocation,
                ),
              ),
              const SizedBox(height: 8),
              TTabs<int>(
                fill: true,
                inline: true,
                borderColor: colors.outlineVariant,
                selectedValue: _tab,
                onTabChanged: (v) => setState(() => _tab = v),
                tabs: const [
                  TTab(value: 0, text: 'Saved'),
                  TTab(value: 1, text: 'Recent'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: IndexedStack(
                  index: _tab,
                  children: [
                    SingleChildScrollView(
                      child: TSavedLocationsList(
                        key: c.savedKey,
                        onAddressSelected: (a) => _pendingAddress = a,
                        onLocationSelected: _picked,
                      ),
                    ),
                    SingleChildScrollView(
                      child: TPreviousSelectionsList(onAddressSelected: (a) => _pendingAddress = a, onLocationSelected: _picked),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return Stack(
          children: [
            Positioned.fill(child: browse),
            if (c.suggesting) Positioned.fill(child: _Suggestions(controller: c)),
          ],
        );
      },
    );
  }
}

class _Suggestions extends StatelessWidget {
  final TMapPickerController controller;

  const _Suggestions({required this.controller});

  Widget _tile(BuildContext context, TPlaceResult place) {
    final colors = context.colors;
    final comma = place.address.indexOf(',');
    final title = comma > 0 ? place.address.substring(0, comma) : place.address;
    final subtitle = comma > 0 ? place.address.substring(comma + 1).trim() : '';

    return TCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.zero,
      onTap: () => controller.selectSuggestion(place),
      child: Row(
        children: [
          TIcon.raw(Icons.location_on, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
              ],
            ),
          ),
          TIcon.raw(HugeIcons.strokeRoundedArrowRight01, size: 16, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Suggestions',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.onSurface),
            ),
            const SizedBox(width: 8),
            if (controller.loadingSuggestions) const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TList<TPlaceResult, String>(
            controller: controller.suggestionList,
            autoItemsPerPage: false,
            theme: context.theme.listTheme.copyWith(
              animationDuration: const Duration(milliseconds: 250),
              loadingBuilder: (_) => const SizedBox.shrink(),
              listSeparatorBuilder: (_, _) => const SizedBox(height: 6),
              emptyStateBuilder: (_) => controller.loadingSuggestions
                  ? const SizedBox.shrink()
                  : const Align(
                      alignment: Alignment.topCenter,
                      child: TCard(
                        margin: EdgeInsets.zero,
                        child: TEmptyState(
                          compact: true,
                          icon: HugeIcons.strokeRoundedSearch01,
                          title: 'No places found',
                          description: 'Try a different search.',
                        ),
                      ),
                    ),
            ),
            itemBuilder: (context, item, index) => _tile(context, item.data),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Map, info card, footer
// ---------------------------------------------------------------------------

class _MapPane extends StatelessWidget {
  final TMapPickerController controller;
  final TMapPickerConfig config;

  const _MapPane({required this.controller, required this.config});

  Widget _chip(BuildContext context, Widget child) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withAlpha(235),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withAlpha(150)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final route = controller.route;
        final hint = controller.isTwoPoints ? 'Tap the map to set ${config.labelOf(controller.active)}' : 'Tap the map to adjust the pin';
        final two = controller.isTwoPoints && controller.from != null && controller.to != null;

        return Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, box) => TMap(
                  initialCoordinates: controller.mapCenter,
                  bounds: controller.bounds,
                  boundsPadding: const EdgeInsets.all(52),
                  zoom: two ? 13 : 15,
                  height: box.maxHeight,
                  googleMapApiKey: config.googleMapApiKey,
                  onCoordinatesChanged: (p) => controller.setPoint(p, fromMap: true),
                  pins: controller.pins(context, fromLabel: config.fromLabel, toLabel: config.toLabel),
                  polylines: controller.polylines(context),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Align(
                alignment: Alignment.topLeft,
                child: _chip(
                  context,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TIcon.raw(Icons.location_on, size: 14, color: colors.primary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          hint,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (route != null)
              Positioned(
                left: 10,
                bottom: 10,
                child: _chip(
                  context,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TIcon.raw(HugeIcons.strokeRoundedRoute01, size: 14, color: colors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${route.formattedDistance} • ${route.formattedDuration}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final TMapPickerController controller;
  final TMapPickerConfig config;

  const _InfoCard({required this.controller, required this.config});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final coords = controller.activeCoords;
        final address = controller.addressOf(controller.active);
        final title = coords == null
            ? 'No location selected'
            : (controller.resolving && controller.activeAddress.isEmpty ? 'Looking up address...' : address);
        final prefix = controller.isTwoPoints ? '${config.labelOf(controller.active)} · ' : '';
        final accent = controller.isTwoPoints && controller.active == TMapPointType.to ? Colors.redAccent : colors.primary;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              TIcon.raw(Icons.location_on, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$prefix$title',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    if (coords == null) Text('Search above or tap the map', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
              if (coords != null) ...[
                const SizedBox(width: 8),
                TButton(
                  text: 'Save',
                  icon: HugeIcons.strokeRoundedBookmarkAdd01,
                  type: TButtonType.softText,
                  onTap: () => controller.saveActive(context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  final TMapPickerController controller;
  final ValueChanged<TMapPickerResult?> onDone;
  final VoidCallback? onCancel;
  final bool expandConfirm;

  const _Footer({required this.controller, required this.onDone, this.onCancel, this.expandConfirm = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final confirm = TButton(
          text: controller.isTwoPoints ? 'Confirm route' : 'Use this location',
          loading: true,
          loadingText: 'Resolving...',
          onPressed: controller.canConfirm
              ? (options) async {
                  final result = await controller.finalize();
                  options.stopLoading();
                  if (context.mounted) onDone(result);
                }
              : null,
        );

        if (expandConfirm) return confirm;

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TButton(text: 'Cancel', type: TButtonType.outline, onTap: onCancel),
            const SizedBox(width: 12),
            confirm,
          ],
        );
      },
    );
  }
}
