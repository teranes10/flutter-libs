import 'package:intl/intl.dart';
import 'package:te_widgets/te_widgets.dart';

extension LatLngX on LatLng {
  String get formattedString => 'latitude:${NumberFormat("0.0#####").format(latitude)}, '
      'longitude:${NumberFormat("0.0#####").format(longitude)}';
}
