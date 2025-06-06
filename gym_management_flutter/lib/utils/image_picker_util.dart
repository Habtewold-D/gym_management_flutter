import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  static Future<Map<String, dynamic>?> pickImageFromGallery() async {
    try {
      const ImageSource source = ImageSource.gallery;

      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return null; // User cancelled picker

      if (kIsWeb) {
        // On web, return bytes and the blob URL as 'path'
        final bytes = await image.readAsBytes();
        return {
          'path': image.path, // image.path is the blob URL on web
          'bytes': bytes,
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
      // Throw an exception to be caught by the calling widget
      throw Exception('Failed to pick image: $e');
    }
  }
}