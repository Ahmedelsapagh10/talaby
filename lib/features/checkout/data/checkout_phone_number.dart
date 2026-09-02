class CheckoutPhoneNumber {
  const CheckoutPhoneNumber._();

  static String nationalDigits({
    required String countryCode,
    required String input,
  }) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (countryCode == 'EG' && digits.length == 11 && digits.startsWith('0')) {
      return digits.substring(1);
    }
    return digits;
  }

  static String complete({
    required String countryCode,
    required String dialCode,
    required String input,
  }) {
    final nationalNumber = nationalDigits(
      countryCode: countryCode,
      input: input,
    );
    final normalizedDialCode = dialCode.startsWith('+')
        ? dialCode
        : '+$dialCode';
    return '$normalizedDialCode$nationalNumber';
  }

  static bool isValid({
    required String countryCode,
    required String input,
    required int minLength,
    required int maxLength,
  }) {
    final nationalNumber = nationalDigits(
      countryCode: countryCode,
      input: input,
    );
    return nationalNumber.length >= minLength &&
        nationalNumber.length <= maxLength;
  }
}
