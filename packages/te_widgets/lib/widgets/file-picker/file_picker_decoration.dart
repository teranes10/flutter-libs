import 'package:flutter/material.dart';
import 'package:te_widgets/mixins/input_field_mixin.dart';
import 'package:te_widgets/widgets/file-picker/file_picker_config.dart';

class TFilePickerDecoration {
  final double? chipWidth;
  final double? chipHeight;
  final bool showImagePreview;
  final Widget Function(TFile file, VoidCallback onRemove)? fileChipBuilder;

  const TFilePickerDecoration({
    this.chipWidth,
    this.chipHeight,
    this.showImagePreview = false,
    this.fileChipBuilder,
  });

  Widget buildFileChip(ColorScheme theme, TInputSize? size, TFile file, VoidCallback onRemove) {
    if (fileChipBuilder != null) {
      return fileChipBuilder!(file, onRemove);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          getFileIcon(file.extension, theme),
          const SizedBox(width: 5),
          Text(
            file.name,
            style: TextStyle(color: theme.onSurfaceVariant, fontSize: size.fontSize),
          ),
          const SizedBox(width: 5.0),
          GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: onRemove,
            child: Icon(Icons.close, size: 12.0, color: theme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget buildImagePreview(TFile file, String fileName, ColorScheme theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            file.bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => buildFileInfo(fileName, fileName.split('.').last, theme),
          ),
          // Hover overlay with filename
          Positioned.fill(
            child: MouseRegion(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      fileName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFileInfo(String fileName, String extension, ColorScheme theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        getFileIcon(extension, theme),
        if (chipWidth == null || chipWidth! > 60) ...[
          const SizedBox(width: 6.0),
          Flexible(
            child: Text(
              fileName,
              style: TextStyle(color: theme.onSurface, fontSize: 12.0, fontWeight: FontWeight.w400),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ],
    );
  }

  Widget getFileIcon(String extension, ColorScheme theme) {
    Color iconColor = Colors.grey;

    IconData iconData = switch (extension.toLowerCase()) {
      'pdf' => Icons.picture_as_pdf,
      'doc' || 'docx' => Icons.description,
      'xls' || 'xlsx' => Icons.table_chart,
      'ppt' || 'pptx' => Icons.slideshow,
      'jpg' || 'jpeg' || 'png' || 'gif' || 'bmp' || 'webp' => Icons.image,
      'mp4' || 'avi' || 'mov' || 'wmv' => Icons.video_file,
      'mp3' || 'wav' || 'aac' => Icons.audio_file,
      'zip' || 'rar' || '7z' => Icons.archive,
      'txt' => Icons.text_snippet,
      'json' => Icons.code,
      _ => Icons.insert_drive_file,
    };

    return Icon(
      iconData,
      size: 16.0,
      color: iconColor,
    );
  }

  bool isImageFile(String extension) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(extension.toLowerCase());
  }
}
