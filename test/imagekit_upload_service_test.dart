import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:new_strucuture/core/services/imagekit_upload_service.dart';

void main() {
  test('uploads directly using ImageKit basic authentication', () async {
    final client = _RecordingClient();
    final service = ImageKitUploadService(
      config: const ImageKitConfig(
        publicKey: 'public_key',
        privateKey: 'private_key',
        uploadFolder: '/tenant/uploads/',
      ),
      client: client,
    );

    final result = await service.upload(
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'proof.png',
      purpose: 'paymentProof',
    );

    final request = client.request! as http.MultipartRequest;
    expect(request.headers['Authorization'], 'Basic cHJpdmF0ZV9rZXk6');
    expect(request.fields['folder'], '/tenant/uploads/paymentProof');
    expect(result.url, 'https://ik.imagekit.io/talaby/proof.png');
    expect(result.path, 'file-id');
  });

  test('reports unconfigured when either ImageKit key is absent', () {
    final service = ImageKitUploadService(
      config: const ImageKitConfig(
        publicKey: 'public_key',
        privateKey: '',
        uploadFolder: '/uploads',
      ),
      client: _RecordingClient(),
    );

    expect(service.isConfigured, isFalse);
  });
}

class _RecordingClient extends http.BaseClient {
  http.BaseRequest? request;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request;
    final body = jsonEncode({
      'url': 'https://ik.imagekit.io/talaby/proof.png',
      'fileId': 'file-id',
    });
    return http.StreamedResponse(Stream.value(utf8.encode(body)), 200);
  }
}
