import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

extension LatLngX on LatLng {
  String get formattedString =>
      'latitude:${NumberFormat("0.0#####").format(latitude)}, '
      'longitude:${NumberFormat("0.0#####").format(longitude)}';
}
