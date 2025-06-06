import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImage(BuildContext context) async {
    // Optionally, you can show a dialog to let the user choose between camera and gallery.
    // For simplicity, this implementation always picks from the gallery.
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return image.path;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
    return null;
  }
}
