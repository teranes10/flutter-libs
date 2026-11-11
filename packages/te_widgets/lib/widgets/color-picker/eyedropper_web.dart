import 'dart:js_interop';
import 'dart:js_interop_unsafe';

bool get eyeDropperSupported => globalContext.has('EyeDropper');

/// Opens the browser eyedropper; returns an opaque ARGB value, or null if cancelled/unsupported.
Future<int?> pickScreenColor() async {
  try {
    final ctor = globalContext['EyeDropper'] as JSFunction;
    final dropper = ctor.callAsConstructor<JSObject>();
    final result = await dropper.callMethod<JSPromise<JSObject>>('open'.toJS).toDart;
    final hex = (result['sRGBHex'] as JSString).toDart; // "#rrggbb"
    return int.tryParse('FF${hex.substring(1)}', radix: 16);
  } catch (_) {
    return null;
  }
}
