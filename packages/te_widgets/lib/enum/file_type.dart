import 'package:file_picker/file_picker.dart';

enum TFileType {
  any,
  media,
  image,
  video,
  audio,
  custom,
}

extension TFileTypeX on TFileType {
  FileType toFilePickerType() {
    switch (this) {
      case TFileType.any:
        return FileType.any;
      case TFileType.media:
        return FileType.media;
      case TFileType.image:
        return FileType.image;
      case TFileType.video:
        return FileType.video;
      case TFileType.audio:
        return FileType.audio;
      case TFileType.custom:
        return FileType.custom;
    }
  }
}
