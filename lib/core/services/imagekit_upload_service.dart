import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ImageKitConfig {
  const ImageKitConfig({
    required this.publicKey,
    required this.privateKey,
    required this.uploadFolder,
  });

  factory ImageKitConfig.fromEnvironment() {
    return const ImageKitConfig(
      publicKey: String.fromEnvironment(
        'IMAGEKIT_PUBLIC_KEY',
        defaultValue: 'public_/g6fXfLlAms0/Z7QIrTeUBc5fn8=',
      ),
      privateKey: String.fromEnvironment(
        'IMAGEKIT_PRIVATE_KEY',
        defaultValue: 'private_ZB4PuHTJ+FoKEzBMfWneyrMf1YA=',
      ),
      uploadFolder: String.fromEnvironment(
        'IMAGEKIT_UPLOAD_FOLDER',
        defaultValue: '/talaby/products',
      ),
    );
  }

  final String publicKey;
  final String privateKey;
  final String uploadFolder;

  bool get isConfigured =>
      publicKey.trim().isNotEmpty && privateKey.trim().isNotEmpty;
}

class ImageKitUploadResult {
  const ImageKitUploadResult({required this.url, required this.fileId});

  final String url;
  final String fileId;
}

abstract interface class TemplateImageUploader {
  bool get isConfigured;

  Future<ImageKitUploadResult> upload({
    required Uint8List bytes,
    required String fileName,
  });
}

class ImageKitUploadException implements Exception {
  const ImageKitUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ImageKitUploadService implements TemplateImageUploader {
  ImageKitUploadService({ImageKitConfig? config, http.Client? client})
    : _config = config ?? ImageKitConfig.fromEnvironment(),
      _client = client;

  static final _uploadUri = Uri.https(
    'upload.imagekit.io',
    '/api/v1/files/upload',
  );

  final ImageKitConfig _config;
  final http.Client? _client;

  @override
  bool get isConfigured => _config.isConfigured;

  @override
  Future<ImageKitUploadResult> upload({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (!isConfigured) {
      throw const ImageKitUploadException(
        'إعداد ImageKit غير مكتمل. شغّل التطبيق بملف إعداد المفاتيح.',
      );
    }
    if (bytes.isEmpty) {
      throw const ImageKitUploadException('ملف الصورة فارغ.');
    }

    final uploadFileName = _safeFileName(fileName);
    final request = http.MultipartRequest('POST', _uploadUri)
      ..headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('${_config.privateKey.trim()}:'))}'
      ..fields['fileName'] = uploadFileName
      ..fields['folder'] = _normalizedFolder(_config.uploadFolder)
      ..fields['useUniqueFileName'] = 'true'
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: uploadFileName),
      );

    final client = _client ?? http.Client();
    try {
      final streamedResponse = await client
          .send(request)
          .timeout(const Duration(minutes: 2));
      final responseBody = await streamedResponse.stream.bytesToString();
      final responseData = _decodeResponse(responseBody);

      if (streamedResponse.statusCode < 200 ||
          streamedResponse.statusCode >= 300) {
        throw ImageKitUploadException(
          _errorMessage(responseData, streamedResponse.statusCode),
        );
      }

      final url = responseData['url']?.toString().trim() ?? '';
      final fileId = responseData['fileId']?.toString().trim() ?? '';
      final uri = Uri.tryParse(url);
      if (uri == null || uri.scheme != 'https' || !uri.hasAuthority) {
        throw const ImageKitUploadException(
          'اكتمل الرفع لكن ImageKit لم يُرجع رابطاً صالحاً.',
        );
      }

      return ImageKitUploadResult(url: url, fileId: fileId);
    } on TimeoutException {
      throw const ImageKitUploadException(
        'استغرق رفع الصورة وقتاً طويلاً. حاول مرة أخرى.',
      );
    } on ImageKitUploadException {
      rethrow;
    } catch (_) {
      throw const ImageKitUploadException(
        'تعذر الاتصال بـ ImageKit. تحقق من الإنترنت وحاول مرة أخرى.',
      );
    } finally {
      if (_client == null) client.close();
    }
  }

  static Map<String, dynamic> _decodeResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic>
          ? decoded
          : const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  static String _errorMessage(Map<String, dynamic> data, int statusCode) {
    final apiMessage = data['message']?.toString().trim();
    if (statusCode == 401 || statusCode == 403) {
      return 'رفض ImageKit بيانات الدخول. تحقق من إعداد المفاتيح.';
    }
    if (statusCode == 413) {
      return 'حجم الصورة أكبر من الحد المسموح في ImageKit.';
    }
    if (apiMessage != null && apiMessage.isNotEmpty) {
      return 'تعذر رفع الصورة: $apiMessage';
    }
    return 'تعذر رفع الصورة إلى ImageKit (رمز $statusCode).';
  }

  static String _safeFileName(String value) {
    final lastSegment = value.replaceAll('\\', '/').split('/').last.trim();
    final sanitized = lastSegment.replaceAll(RegExp(r'[^a-zA-Z0-9.\-]'), '_');
    final base = sanitized.isEmpty ? 'template.jpg' : sanitized;
    return 'template_${DateTime.now().microsecondsSinceEpoch}_$base';
  }

  static String _normalizedFolder(String value) {
    final folder = value.trim();
    if (folder.isEmpty) return '/talaby/products';
    return folder.startsWith('/') ? folder : '/$folder';
  }
}
