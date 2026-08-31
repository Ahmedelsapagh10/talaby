import 'dart:typed_data';

class ImageUploadResult {
  const ImageUploadResult({required this.url, required this.path});

  final String url;
  final String path;
}

abstract interface class ImageUploadService {
  bool get isConfigured;

  Future<ImageUploadResult> upload({
    required Uint8List bytes,
    required String fileName,
    String purpose = 'product',
  });
}

class ImageUploadException implements Exception {
  const ImageUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}
