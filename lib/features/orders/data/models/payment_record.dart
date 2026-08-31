import 'package:cloud_firestore/cloud_firestore.dart';

import 'payment_status.dart';

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.proofUrl,
    required this.claimedAmount,
    required this.status,
    this.confirmedAmount,
    this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  final String id;
  final String proofUrl;
  final int claimedAmount;
  final int? confirmedAmount;
  final PaymentRecordStatus status;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  factory PaymentRecord.fromMap(Map<String, dynamic> map) => PaymentRecord(
    id: map['id']?.toString() ?? '',
    proofUrl: map['proofUrl']?.toString() ?? '',
    claimedAmount: (map['claimedAmount'] as num?)?.toInt() ?? 0,
    confirmedAmount: (map['confirmedAmount'] as num?)?.toInt(),
    status: PaymentRecordStatusCodec.fromValue(map['status']),
    createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    reviewedAt: (map['reviewedAt'] as Timestamp?)?.toDate(),
    reviewedBy: map['reviewedBy']?.toString(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'proofUrl': proofUrl,
    'claimedAmount': claimedAmount,
    'confirmedAmount': confirmedAmount,
    'status': status.value,
    'createdAt': createdAt,
    'reviewedAt': reviewedAt,
    'reviewedBy': reviewedBy,
  };
}

class PaymentCalculator {
  const PaymentCalculator._();

  static int approvedTotal(Iterable<PaymentRecord> payments) {
    return payments
        .where((payment) => payment.status == PaymentRecordStatus.approved)
        .fold(0, (total, payment) => total + (payment.confirmedAmount ?? 0));
  }
}
