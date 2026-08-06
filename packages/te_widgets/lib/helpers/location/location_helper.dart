import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class TLocationHelper {
  static LocationSettings getLocationSettings({
    LocationAccuracy accuracy = LocationAccuracy.high,
    ActivityType activityType = ActivityType.automotiveNavigation,
    int distanceFilter = 100,
    Duration interval = const Duration(seconds: 10),
    String notificationTitle = "Running in Background",
    String notificationText = "App will continue to receive your location even when you aren't using it",
  }) {
    late LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        intervalDuration: interval,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: notificationTitle,
          notificationText: notificationText,
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: accuracy,
        activityType: activityType,
        distanceFilter: distanceFilter,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically: false,
      );
    } else if (kIsWeb) {
      locationSettings = WebSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        maximumAge: Duration(minutes: 5),
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      );
    }

    return locationSettings;
  }

  static Future<bool> canFetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return true;
  }

  static Future<Position?> getCurrentLocation(LocationSettings locationSettings) async {
    try {
      await canFetchLocation();
      return Geolocator.getCurrentPosition(locationSettings: locationSettings);
    } catch (_) {
      return null;
    }
  }

  static Future<Stream<Position>?> getCurrentLocationUpdates(LocationSettings locationSettings) async {
    try {
      await canFetchLocation();
      return Geolocator.getPositionStream(locationSettings: locationSettings);
    } catch (_) {
      return null;
    }
  }
}
