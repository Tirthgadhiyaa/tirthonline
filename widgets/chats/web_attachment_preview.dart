// lib/chat/widgets/web_attachment_preview.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';

class WebAttachmentPreview extends StatelessWidget {
  final String fileName;
  final String mimeType;
  final int fileSize;
  final Uint8List bytes;
  final VoidCallback onRemove;

  const WebAttachmentPreview({
    Key? key,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.bytes,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final extension = fileName.split('.').last.toLowerCase();

    // Check if it's an image
    final isImage = mimeType.startsWith('image/');

    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // File preview
          Center(
            child: isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      bytes,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    _getFileIcon(extension),
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),

          // Remove button
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // File name tooltip on hover
          if (!isImage)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  fileName.length > 10
                      ? '${fileName.substring(0, 7)}...'
                      : fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }
}
