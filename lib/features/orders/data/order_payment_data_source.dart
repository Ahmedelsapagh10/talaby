import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/firestore_paths.dart';
import 'order_record_utils.dart';

class OrderPaymentDataSource {
  OrderPaymentDataSource(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> submitProof({
    required String orderId,
    required String proofUrl,
    required int claimedAmount,
  }) async {
    final userId = _requireUserId();
    if (claimedAmount <= 0) throw StateError('Payment amount is invalid.');
    final uri = Uri.tryParse(proofUrl);
    if (uri == null || uri.scheme != 'https' || !uri.hasAuthority) {
      throw StateError('Payment proof URL is invalid.');
    }
    final orderRef = _firestore.doc(FirestorePaths.order(orderId));
    final paymentId = orderRef.collection('paymentIds').doc().id;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(orderRef);
      final order = snapshot.data();
      if (!snapshot.exists || order?['customerId'] != userId) {
        throw StateError('Order was not found.');
      }
      final payments = orderRecordMaps(order?['payments']);
      payments.add({
        'id': paymentId,
        'proofUrl': proofUrl,
        'claimedAmount': claimedAmount,
        'confirmedAmount': null,
        'status': 'proofSubmitted',
        'createdAt': Timestamp.now(),
        'reviewedAt': null,
        'reviewedBy': null,
      });
      final total = (order?['total'] as num?)?.toInt() ?? 0;
      final summary = calculateOrderPaymentSummary(payments, total);
      transaction.update(orderRef, {
        'payments': payments,
        'paidAmount': summary.paid,
        'remainingAmount': (total - summary.paid).clamp(0, total),
        'paymentStatus': summary.status,
        'events': FieldValue.arrayUnion([
          publicOrderEvent('paymentProofSubmitted'),
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    await addOrderAuditEvent(orderRef, 'paymentProofSubmitted', userId, {
      'paymentId': paymentId,
      'claimedAmount': claimedAmount,
    });
  }

  Future<void> review({
    required String orderId,
    required String paymentId,
    required bool approved,
    int? confirmedAmount,
  }) async {
    final reviewerId = _requireUserId();
    if (approved && (confirmedAmount == null || confirmedAmount <= 0)) {
      throw StateError('Confirmed amount is invalid.');
    }
    final orderRef = _firestore.doc(FirestorePaths.order(orderId));
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(orderRef);
      if (!snapshot.exists) throw StateError('Order was not found.');
      final order = snapshot.data()!;
      final payments = orderRecordMaps(order['payments']);
      final index = payments.indexWhere(
        (payment) => payment['id'] == paymentId,
      );
      if (index < 0 || payments[index]['status'] != 'proofSubmitted') {
        throw StateError('Payment is not awaiting review.');
      }
      payments[index] = {
        ...payments[index],
        'status': approved ? 'approved' : 'rejected',
        'confirmedAmount': approved ? confirmedAmount : null,
        'reviewedAt': Timestamp.now(),
        'reviewedBy': reviewerId,
      };
      final total = (order['total'] as num?)?.toInt() ?? 0;
      final summary = calculateOrderPaymentSummary(payments, total);
      transaction.update(orderRef, {
        'payments': payments,
        'paidAmount': summary.paid,
        'remainingAmount': (total - summary.paid).clamp(0, total),
        'paymentStatus': summary.status,
        'events': FieldValue.arrayUnion([
          publicOrderEvent(approved ? 'paymentApproved' : 'paymentRejected', {
            'confirmedAmount': approved ? confirmedAmount : null,
          }),
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    await addOrderAuditEvent(
      orderRef,
      approved ? 'paymentApproved' : 'paymentRejected',
      reviewerId,
      {'paymentId': paymentId, 'confirmedAmount': confirmedAmount},
    );
  }

  String _requireUserId() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('Authentication is required.');
    return userId;
  }
}
