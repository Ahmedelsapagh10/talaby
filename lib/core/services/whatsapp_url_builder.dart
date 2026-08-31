class WhatsAppUrlBuilder {
  const WhatsAppUrlBuilder._();

  static Uri build({required String phone, String? message}) {
    final normalized = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) {
      throw ArgumentError.value(phone, 'phone', 'A phone number is required.');
    }
    return Uri.https(
      'wa.me',
      '/$normalized',
      message == null || message.trim().isEmpty
          ? null
          : <String, String>{'text': message.trim()},
    );
  }
}
