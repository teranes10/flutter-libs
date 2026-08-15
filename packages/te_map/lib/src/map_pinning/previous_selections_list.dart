import 'package:flutter/material.dart';
import 'package:te_map/te_map.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TPreviousSelectionsList extends StatefulWidget {
  final ValueChanged<LatLng> onLocationSelected;
  final ValueChanged<String> onAddressSelected;

  const TPreviousSelectionsList({super.key, required this.onLocationSelected, required this.onAddressSelected});

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
    if (_previousSelections.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Recent Locations',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.onSurface),
        ),
        const SizedBox(height: 6),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _previousSelections.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final parts = _previousSelections[index].split('|');
            final String addr = parts[0];
            final String coords = parts.length > 1 ? parts[1] : '';
            final String timestamp = parts.length > 2 ? parts[2] : '';

            return TCard(
              padding: const EdgeInsets.all(12),
              margin: EdgeInsets.zero,
              onTap: () {
                final coordinates = TLocationHelper.parseCoordinates(coords);
                widget.onAddressSelected(addr);
                widget.onLocationSelected(coordinates);
              },
              child: Row(
                children: [
                  Icon(Icons.history_outlined, color: colors.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          addr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (timestamp.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text('Recorded: $timestamp', style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant.withAlpha(160))),
                        ],
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
                  TButton(icon: Icons.close, type: TButtonType.outline, color: colors.error, onTap: () => deletePreviousSelection(index)),
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
