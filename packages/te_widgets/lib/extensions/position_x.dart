import 'package:geolocator/geolocator.dart';
import 'package:te_widgets/te_widgets.dart';

extension PositionX on Position {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}
