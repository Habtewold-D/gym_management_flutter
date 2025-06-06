import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  static Future<Map<String, dynamic>?> pickImage(BuildContext context) async {
    try {
      // Show dialog to choose between gallery and camera (optional)
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Camera'),
            ),
          ],
        ),
      );

      if (source == null) return null;

      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return null;

      if (kIsWeb) {
        // On web, return bytes and a blob URL
        final bytes = await image.readAsBytes();
        final blobUrl = image.path; // May be a blob URL
        return {
          'bytes': bytes,
          'blobUrl': blobUrl.isNotEmpty ? blobUrl : null,
          'name': image.name,
        };
      } else {
        // On mobile, return the file path
        return {
          'path': image.path,
          'name': image.name,
        };
      }
    } catch (e) {
      print('Error picking image: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
      return null;
    }
  }
}