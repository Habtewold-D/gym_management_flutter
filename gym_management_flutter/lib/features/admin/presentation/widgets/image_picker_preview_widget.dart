import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Reusing color constants, consider moving to a shared theme/constants file if used widely
const DeepBlue = Color(0xFF0000CD);
const LightBlue = Color(0xFFE6E9FD);

class ImagePickerPreviewWidget extends StatelessWidget {
  final Map<String, dynamic>? imageData;
  final VoidCallback onPickImage;
  final String pickButtonText;
  final String changeButtonText;
  final double height;

  const ImagePickerPreviewWidget({
    Key? key,
    required this.imageData,
    required this.onPickImage,
    this.pickButtonText = 'Select Image',
    this.changeButtonText = 'Change Image',
    this.height = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget previewContent;
    bool hasImage = false;

    if (imageData != null) {
      String? path = imageData!['path'] as String?;
      Uint8List? bytes = imageData!['bytes'] as Uint8List?;
      String? blobUrl = imageData!['blobUrl'] as String?;

      if (kIsWeb) {
        if (bytes != null && bytes.isNotEmpty) {
          previewContent = Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: height);
          hasImage = true;
        } else if (blobUrl != null && blobUrl.isNotEmpty) {
          previewContent = Image.network(blobUrl, fit: BoxFit.cover, width: double.infinity, height: height,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
          );
          hasImage = true;
        // If path is a web URL, it can also be displayed in web preview
        } else if (path != null && path.isNotEmpty && path.startsWith('http')) {
           previewContent = Image.network(path, fit: BoxFit.cover, width: double.infinity, height: height,
             errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
           );
           hasImage = true;
        } else {
          previewContent = Icon(Icons.add_a_photo, size: 50, color: Colors.grey[600]);
        }
      } else { // Native (Mobile)
        if (path != null && path.isNotEmpty) {
          if (path.startsWith('http')) { // Network image URL
            previewContent = Image.network(path, fit: BoxFit.cover, width: double.infinity, height: height,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
            );
            hasImage = true;
          } else { // Local file image path
            final file = File(path);
            if (file.existsSync()){
                previewContent = Image.file(file, fit: BoxFit.cover, width: double.infinity, height: height);
                hasImage = true;
            } else {
                // If file doesn't exist at path, show broken image icon
                print('Image file not found at path: $path');
                previewContent = Icon(Icons.broken_image, size: 50, color: Colors.grey[600]);
            }
          }
        } else {
          previewContent = Icon(Icons.add_a_photo, size: 50, color: Colors.grey[600]);
        }
      }
    } else {
      previewContent = Icon(Icons.add_a_photo, size: 50, color: Colors.grey[600]);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(7.5), // Slightly less than container to avoid border overlap issues
              child: previewContent,
          ),
          alignment: Alignment.center,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onPickImage,
          icon: Icon(hasImage ? Icons.edit_outlined : Icons.add_photo_alternate_outlined),
          label: Text(hasImage ? changeButtonText : pickButtonText),
          style: ElevatedButton.styleFrom(
              backgroundColor: LightBlue, 
              foregroundColor: DeepBlue,
              textStyle: const TextStyle(fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );
  }
}
