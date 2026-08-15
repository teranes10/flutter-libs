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
    if (_savedLocations.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Saved Locations',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.onSurface),
        ),
        const SizedBox(height: 6),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _savedLocations.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final parts = _savedLocations[index].split('|');
            final String displayName;
            final String addr;
            final String coords;
            if (parts.length >= 3) {
              displayName = parts[0];
              addr = parts[1];
              coords = parts[2];
            } else {
              displayName = parts[0];
              addr = parts[0];
              coords = parts.length > 1 ? parts[1] : '';
            }

            return TCard(
              padding: const EdgeInsets.all(12),
              margin: EdgeInsets.zero,
              onTap: () {
                final coordinates = TLocationHelper.parseCoordinates(coords);
                widget.onAddressSelected(displayName); // Use displayName for search field
                widget.onLocationSelected(coordinates);
              },
              child: Row(
                children: [
                  Icon(Icons.pin_drop_outlined, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          addr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          coords,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant.withAlpha(180)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TButton(
                    icon: Icons.bookmark_remove_outlined,
                    type: TButtonType.outline,
                    color: colors.error,
                    onTap: () {
                      TAlertService.show(
                        context,
                        title: 'Remove Saved Location',
                        text: 'Are you sure you want to remove "$displayName"?',
                        icon: Icons.delete_forever_rounded,
                        color: colors.error,
                        confirmButton: AlertButton(text: 'Remove', onClick: () => deleteSavedLocation(index)),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
