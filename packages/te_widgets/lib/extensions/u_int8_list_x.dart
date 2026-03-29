import 'dart:typed_data';

extension UInt8ListX on Uint8List {
  bool listEquals(Uint8List other) {
    if (lengthInBytes != other.lengthInBytes) return false;
    for (int i = 0; i < lengthInBytes; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }

  int bytesHash() {
    int hash = 0;
    for (final b in this) {
      hash = 0x1fffffff & (hash + b);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= (hash >> 6);
    }
    return hash;
  }
}
