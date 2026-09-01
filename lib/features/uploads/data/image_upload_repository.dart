import '../../../core/services/image_upload_service.dart';
import '../../../core/services/template_image_picker.dart';

enum ImageUploadPurpose {
  product,
  productColor,
  storeLogo,
  storeBanner,
  paymentProof,
  review,
}

class ImageUploadRepository {
  ImageUploadRepository(this._picker, this._uploader);

  final TemplateImagePicker _picker;
  final ImageUploadService _uploader;

  Future<List<String>> pickAndUpload({
    required ImageUploadPurpose purpose,
    int maxFiles = 12,
  }) async {
    final images = await _picker.pickImages();
    final selected = images.take(maxFiles);
    final urls = <String>[];
    for (final image in selected) {
      final result = await _uploader.upload(
        bytes: image.bytes,
        fileName: '${purpose.name}_${image.fileName}',
        purpose: purpose.name,
      );
      urls.add(result.url);
    }
    return urls;
  }
}
