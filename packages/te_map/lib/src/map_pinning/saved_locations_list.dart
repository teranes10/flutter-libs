import 'package:flutter/material.dart';
import 'package:te_map/te_map.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TSavedLocationsList extends StatefulWidget {
  final ValueChanged<LatLng> onLocationSelected;
  final ValueChanged<String> onAddressSelected;

  const TSavedLocationsList({super.key, required this.onLocationSelected, required this.onAddressSelected});

  @override
  State<TSavedLocationsList> createState() => TSavedLocationsListState();
}

class TSavedLocationsListState extends State<TSavedLocationsList> {
  List<String> _savedLocations = [];

  @override
  void initState() {
    super.initState();
    loadSavedLocations();
  }

  void loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedLocations = prefs.getStringList('saved_locations') ?? [];
    });
  }

  void saveCurrentLocation(String currentAddress, LatLng currentCoordinates) async {
    if (currentAddress.isEmpty) return;

    TAlertService.prompt(
      context,
      title: 'Save Location',
      placeholder: 'Enter a name for this location (e.g., Home, Work)',
      initialValue: currentAddress.split(',').first,
      onConfirm: (name) async {
        if (name.isEmpty) return;

        final prefs = await SharedPreferences.getInstance();
        final item = "$name|$currentAddress|${currentCoordinates.latitude},${currentCoordinates.longitude}";

        _savedLocations.removeWhere((loc) {
          final parts = loc.split('|');
          if (parts.length >= 3) {
            return parts[1] == currentAddress && parts[2] == "${currentCoordinates.latitude},${currentCoordinates.longitude}";
          } else if (parts.length == 2) {
            return parts[0] == currentAddress && parts[1] == "${currentCoordinates.latitude},${currentCoordinates.longitude}";
          }
          return false;
        });

        setState(() {
          _savedLocations.insert(0, item);
        });
        await prefs.setStringList('saved_locations', _savedLocations);
        if (mounted) {
          TToastService.success(context, "Location saved successfully!");
        }
      },
    );
  }

  void deleteSavedLocation(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedLocations.removeAt(index);
    });
    await prefs.setStringList('saved_locations', _savedLocations);
    if (mounted) {
      TToastService.success(context, "Location removed!");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_savedLocations.isEmpty) {
      return const TCard(
        margin: EdgeInsets.zero,
        child: TEmptyState(
          compact: true,
          icon: HugeIcons.strokeRoundedBookmark01,
          title: 'No saved locations',
          padding: EdgeInsetsGeometry.all(12),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _savedLocations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final parts = _savedLocations[index].split('|');
        final String displayName = parts[0];
        final String addr = parts.length >= 3 ? parts[1] : parts[0];
        final String coords = parts.length >= 3 ? parts[2] : (parts.length > 1 ? parts[1] : '');

        return TLocationTile(
          icon: Icons.location_on,
          text: displayName,
          details: [
            if (addr != displayName) (HugeIcons.strokeRoundedMapsLocation01, addr),
            if (coords.isNotEmpty) (Icons.location_on, coords),
          ],
          removeTitle: 'Remove "$displayName"?',
          onTap: () {
            widget.onAddressSelected(displayName);
            widget.onLocationSelected(TLocationHelper.parseCoordinates(coords));
          },
          onRemove: () => deleteSavedLocation(index),
        );
      },
    );
  }
}

/// Minimal location row: icon, one-line text, info popover and remove popconfirm.
class TLocationTile extends StatelessWidget {
  final dynamic icon;
  final String text;
  final List<(dynamic, String)> details;
  final String removeTitle;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const TLocationTile({
    super.key,
    required this.icon,
    required this.text,
    required this.details,
    required this.removeTitle,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: EdgeInsets.zero,
      onTap: onTap,
      child: Row(
        children: [
          TIcon.raw(icon, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: colors.onSurface),
            ),
          ),
          // Absorb taps so the buttons never also trigger the card's onTap.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TPopover(
                  alignment: TPopupAlignment.topRight,
                  width: 260,
                  title: text,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (icon, value) in details)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TIcon.raw(icon, size: 14, color: colors.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SelectableText(
                                  value,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: colors.onSurface),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  child: TButton(
                    icon: HugeIcons.strokeRoundedInformationCircle,
                    type: TButtonType.text,
                    size: TSize.xs,
                    color: AppColors.info,
                  ),
                ),
                TPopConfirm.danger(
                  title: removeTitle,
                  confirmText: 'Remove',
                  onConfirm: onRemove,
                  child: TButton(icon: HugeIcons.strokeRoundedDelete02, type: TButtonType.text, size: TSize.xs, color: colors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
