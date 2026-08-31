import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'image_upload_service.dart';

class ImageKitConfig {
  const ImageKitConfig({
    required this.publicKey,
    required this.privateKey,
    required this.uploadFolder,
  });

  factory ImageKitConfig.fromEnvironment() => const ImageKitConfig(
    publicKey: String.fromEnvironment('IMAGEKIT_PUBLIC_KEY'),
    privateKey: String.fromEnvironment('IMAGEKIT_PRIVATE_KEY'),
    uploadFolder: String.fromEnvironment(
      'IMAGEKIT_UPLOAD_FOLDER',
      defaultValue: '/talaby/uploads',
    ),
  );

  final String publicKey;
  final String privateKey;
  final String uploadFolder;
  bool get isConfigured =>
      publicKey.trim().isNotEmpty && privateKey.trim().isNotEmpty;
}

class ImageKitUploadService implements ImageUploadService {
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
  Future<ImageUploadResult> upload({
    required Uint8List bytes,
    required String fileName,
    String purpose = 'product',
  }) async {
    if (!isConfigured) {
      throw const ImageUploadException('إعداد ImageKit غير مكتمل.');
    }
    if (bytes.isEmpty) {
      throw const ImageUploadException('ملف الصورة فارغ.');
    }
    final uploadFileName = _safeFileName(fileName);
    final request = http.MultipartRequest('POST', _uploadUri)
      ..headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('${_config.privateKey.trim()}:'))}'
      ..fields['fileName'] = uploadFileName
      ..fields['folder'] = '${_normalizedFolder(_config.uploadFolder)}/$purpose'
      ..fields['useUniqueFileName'] = 'true'
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: uploadFileName),
      );
    final client = _client ?? http.Client();
    try {
      final response = await client
          .send(request)
          .timeout(const Duration(minutes: 2));
      final data = _decode(await response.stream.bytesToString());
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ImageUploadException(_errorMessage(data, response.statusCode));
      }
      final url = data['url']?.toString().trim() ?? '';
      final fileId = data['fileId']?.toString().trim() ?? '';
      final uri = Uri.tryParse(url);
      if (uri == null || uri.scheme != 'https' || !uri.hasAuthority) {
        throw const ImageUploadException(
          'اكتمل الرفع لكن ImageKit لم يُرجع رابطاً صالحاً.',
        );
      }
      return ImageUploadResult(url: url, path: fileId);
    } on TimeoutException {
      throw const ImageUploadException('استغرق رفع الصورة وقتاً طويلاً.');
    } on ImageUploadException {
      rethrow;
    } catch (_) {
      throw const ImageUploadException('تعذر الاتصال بـ ImageKit.');
    } finally {
      if (_client == null) client.close();
    }
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      final value = jsonDecode(body);
      return value is Map<String, dynamic> ? value : const {};
    } catch (_) {
      return const {};
    }
  }

  static String _errorMessage(Map<String, dynamic> data, int statusCode) {
    final message = data['message']?.toString().trim();
    return message?.isNotEmpty == true
        ? 'تعذر رفع الصورة: $message'
        : 'تعذر رفع الصورة إلى ImageKit (رمز $statusCode).';
  }

  static String _safeFileName(String value) {
    final lastSegment = value.replaceAll('\\', '/').split('/').last.trim();
    final safe = lastSegment.replaceAll(RegExp(r'[^a-zA-Z0-9.\-]'), '_');
    final name = safe.isEmpty ? 'image.jpg' : safe;
    return '${DateTime.now().microsecondsSinceEpoch}_$name';
  }

  static String _normalizedFolder(String value) {
    final folder = value.trim();
    if (folder.isEmpty) return '/talaby/uploads';
    return folder.startsWith('/') ? folder : '/$folder';
  }
}
