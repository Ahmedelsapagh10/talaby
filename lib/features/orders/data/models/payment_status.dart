enum PaymentStatus { unpaid, proofSubmitted, partiallyPaid, paid, rejected }

extension PaymentStatusCodec on PaymentStatus {
  String get value => name;

  static PaymentStatus fromValue(Object? value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }
}

enum PaymentRecordStatus { proofSubmitted, approved, rejected }

extension PaymentRecordStatusCodec on PaymentRecordStatus {
  String get value => name;

  static PaymentRecordStatus fromValue(Object? value) {
    return PaymentRecordStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PaymentRecordStatus.proofSubmitted,
    );
  }
}
