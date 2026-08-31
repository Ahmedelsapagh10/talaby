import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/firestore_paths.dart';
import 'models/order_status.dart';
import 'order_record_utils.dart';

class OrderAdminDataSource {
  OrderAdminDataSource(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> updateDeliveryFee(String orderId, int deliveryFee) async {
    final userId = _requireUserId();
    if (deliveryFee < 0) throw StateError('Delivery fee is invalid.');
    final orderRef = _firestore.doc(FirestorePaths.order(orderId));
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(orderRef);
      if (!snapshot.exists) throw StateError('Order was not found.');
      final order = snapshot.data()!;
      final subtotal = (order['subtotal'] as num?)?.toInt() ?? 0;
      final discount = (order['discountAmount'] as num?)?.toInt() ?? 0;
      final total = subtotal - discount + deliveryFee;
      final payments = orderRecordMaps(order['payments']);
      final summary = calculateOrderPaymentSummary(payments, total);
      transaction.update(orderRef, {
        'deliveryFee': deliveryFee,
        'total': total,
        'paidAmount': summary.paid,
        'remainingAmount': (total - summary.paid).clamp(0, total),
        'paymentStatus': summary.status,
        'events': FieldValue.arrayUnion([
          publicOrderEvent('deliveryFeeUpdated', {'deliveryFee': deliveryFee}),
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    await addOrderAuditEvent(orderRef, 'deliveryFeeUpdated', userId, {
      'deliveryFee': deliveryFee,
    });
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final userId = _requireUserId();
    final eventType = status == OrderStatus.confirmed
        ? 'orderConfirmed'
        : status.value;
    final orderRef = _firestore.doc(FirestorePaths.order(orderId));
    final batch = _firestore.batch();
    batch.update(orderRef, {
      'orderStatus': status.value,
      'events': FieldValue.arrayUnion([publicOrderEvent(eventType)]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(orderRef.collection('adminEvents').doc(), {
      'type': eventType,
      'performedBy': userId,
      'metadata': const <String, dynamic>{},
      'timestamp': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  String _requireUserId() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('Authentication is required.');
    return userId;
  }
}
