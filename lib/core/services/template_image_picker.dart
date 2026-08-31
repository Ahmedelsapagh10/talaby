import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class PickedTemplateImage {
  const PickedTemplateImage({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

abstract interface class TemplateImagePicker {
  Future<List<PickedTemplateImage>> pickImages();
}

class GalleryTemplateImagePicker implements TemplateImagePicker {
  GalleryTemplateImagePicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<List<PickedTemplateImage>> pickImages() async {
    final files = await _picker.pickMultiImage(limit: 12);
    final images = <PickedTemplateImage>[];
    for (final file in files) {
      final bytes = await file.readAsBytes();
      if (bytes.isNotEmpty) {
        images.add(PickedTemplateImage(fileName: file.name, bytes: bytes));
      }
    }
    return images;
  }
}
