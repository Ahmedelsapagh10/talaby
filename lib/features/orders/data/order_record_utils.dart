import 'package:cloud_firestore/cloud_firestore.dart';

class OrderPaymentSummary {
  const OrderPaymentSummary(this.paid, this.status);

  final int paid;
  final String status;
}

List<Map<String, dynamic>> orderRecordMaps(Object? value) =>
    (value as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

OrderPaymentSummary calculateOrderPaymentSummary(
  List<Map<String, dynamic>> payments,
  int total,
) {
  final paid = payments
      .where((payment) => payment['status'] == 'approved')
      .fold<int>(
        0,
        (totalPaid, payment) =>
            totalPaid + ((payment['confirmedAmount'] as num?)?.toInt() ?? 0),
      );
  if (paid >= total) return OrderPaymentSummary(paid, 'paid');
  if (paid > 0) return OrderPaymentSummary(paid, 'partiallyPaid');
  if (payments.any((payment) => payment['status'] == 'proofSubmitted')) {
    return const OrderPaymentSummary(0, 'proofSubmitted');
  }
  return OrderPaymentSummary(0, payments.isEmpty ? 'unpaid' : 'rejected');
}

Map<String, dynamic> publicOrderEvent(
  String type, [
  Map<String, dynamic> metadata = const {},
]) => {
  'type': type,
  'timestamp': Timestamp.now(),
  'customerVisible': true,
  'metadata': metadata,
};

Future<void> addOrderAuditEvent(
  DocumentReference<Map<String, dynamic>> orderRef,
  String type,
  String userId,
  Map<String, dynamic> metadata,
) {
  return orderRef.collection('adminEvents').add({
    'type': type,
    'performedBy': userId,
    'metadata': metadata,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
