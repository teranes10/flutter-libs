import 'package:flutter/foundation.dart' show kIsWeb;
import 'fullscreen_stub.dart' if (dart.library.html) 'fullscreen_web.dart' if (dart.library.io) 'fullscreen_mobile.dart';

abstract class TFullscreen {
  static bool get isFullscreen {
    if (kIsWeb) {
      return getIsFullscreen();
    }
    return false;
  }

  static void toggleFullscreen() {
    if (kIsWeb) {
      toggleFullscreenMode();
    }
  }

  static void registerListener(void Function(bool isFullscreen) callback) {
    if (kIsWeb) {
      registerFullscreenListener(callback);
    }
  }

  static void unregisterListener(void Function(bool isFullscreen) callback) {
    if (kIsWeb) {
      unregisterFullscreenListener(callback);
    }
  }
}
