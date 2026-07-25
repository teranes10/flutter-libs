// ignore_for_file: uri_does_not_exist, undefined_class, deprecated_member_use, undefined_prefixed_name, unused_import
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

final Map<void Function(bool), StreamSubscription> _subscriptions = {};

bool getIsFullscreen() {
  return html.window.document.fullscreenElement != null;
}

void toggleFullscreenMode() {
  final doc = html.window.document;
  if (doc.fullscreenElement != null) {
    doc.exitFullscreen();
  } else {
    doc.documentElement?.requestFullscreen();
  }
}

void registerFullscreenListener(void Function(bool isFullscreen) callback) {
  final sub = html.window.document.onFullscreenChange.listen((event) {
    callback(getIsFullscreen());
  });
  _subscriptions[callback] = sub;
}

void unregisterFullscreenListener(void Function(bool isFullscreen) callback) {
  final sub = _subscriptions.remove(callback);
  sub?.cancel();
}
