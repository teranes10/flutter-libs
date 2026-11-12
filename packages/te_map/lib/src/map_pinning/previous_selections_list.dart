import 'package:flutter/material.dart';
import 'package:te_map/te_map.dart';
import 'package:te_widgets/te_widgets.dart';
import 'saved_locations_list.dart' show TLocationTile;
import 'package:shared_preferences/shared_preferences.dart';

class TPreviousSelectionsList extends StatefulWidget {
  final ValueChanged<LatLng> onLocationSelected;
  final ValueChanged<String> onAddressSelected;

  const TPreviousSelectionsList({super.key, required this.onLocationSelected, required this.onAddressSelected});

  /// Stores [address] / [coordinates] at the top of the recent list (max 20, no duplicates).
  static Future<void> record(String address, LatLng coordinates) async {
    if (address.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final coords = '${coordinates.latitude},${coordinates.longitude}';
    final list = prefs.getStringList('previous_selections') ?? [];
    list.removeWhere((e) {
      final parts = e.split('|');
      return parts.length > 1 && parts[0] == address && parts[1] == coords;
    });
    list.insert(0, '$address|$coords|${DateTime.now().toString().substring(0, 16)}');
    await prefs.setStringList('previous_selections', list.take(20).toList());
  }

  @override
  State<TPreviousSelectionsList> createState() => TPreviousSelectionsListState();
}

class TPreviousSelectionsListState extends State<TPreviousSelectionsList> {
  List<String> _previousSelections = [];

  @override
  void initState() {
    super.initState();
    loadPreviousSelections();
  }

  void loadPreviousSelections() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _previousSelections = prefs.getStringList('previous_selections') ?? [];
    });
  }

  void deletePreviousSelection(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _previousSelections.removeAt(index);
    });
    await prefs.setStringList('previous_selections', _previousSelections);
    if (mounted) {
      TToastService.success(context, "Location removed from recent list!");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_previousSelections.isEmpty) {
      return const TCard(
        margin: EdgeInsets.zero,
        child: TEmptyState(
          compact: true,
          icon: HugeIcons.strokeRoundedClock01,
          title: 'No recent locations',
          padding: EdgeInsetsGeometry.all(12),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _previousSelections.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final parts = _previousSelections[index].split('|');
        final String addr = parts[0];
        final String coords = parts.length > 1 ? parts[1] : '';
        final String timestamp = parts.length > 2 ? parts[2] : '';

        return TLocationTile(
          icon: HugeIcons.strokeRoundedClock01,
          text: addr,
          details: [
            if (coords.isNotEmpty) (Icons.location_on, coords),
            if (timestamp.isNotEmpty) (HugeIcons.strokeRoundedClock01, timestamp),
          ],
          removeTitle: 'Remove from recent?',
          onTap: () {
            widget.onAddressSelected(addr);
            widget.onLocationSelected(TLocationHelper.parseCoordinates(coords));
          },
          onRemove: () => deletePreviousSelection(index),
        );
      },
    );
  }
}
