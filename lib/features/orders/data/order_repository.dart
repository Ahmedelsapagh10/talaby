import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../../cart/data/models/cart_item.dart';
import '../../checkout/data/models/checkout_details.dart';
import '../../uploads/data/image_upload_repository.dart';
import 'models/commerce_order.dart';
import 'models/order_status.dart';
import 'order_admin_data_source.dart';
import 'order_checkout_data_source.dart';
import 'order_payment_data_source.dart';

class OrderPage {
  const OrderPage({required this.orders, this.nextCursor});

  final List<CommerceOrder> orders;
  final DocumentSnapshot<Map<String, dynamic>>? nextCursor;
  bool get hasMore => nextCursor != null;
}

class OrderRepository {
  OrderRepository(
    this._firestore,
    this._checkout,
    this._payments,
    this._admin,
    this._imageUploads,
  );

  final FirebaseFirestore _firestore;
  final OrderCheckoutDataSource _checkout;
  final OrderPaymentDataSource _payments;
  final OrderAdminDataSource _admin;
  final ImageUploadRepository _imageUploads;

  Future<String> finalizeOrder({
    required List<CartItem> items,
    required CheckoutDetails details,
  }) => _checkout.finalizeOrder(items: items, details: details);

  Stream<CommerceOrder?> watchOrder(String orderId) {
    return _firestore
        .doc(FirestorePaths.order(orderId))
        .snapshots()
        .map((doc) => doc.exists ? CommerceOrder.fromDocument(doc) : null);
  }

  Future<OrderPage> getOrders({
    required int limit,
    String? customerId,
    DocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestorePaths.orders)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (customerId != null) {
      query = query.where('customerId', isEqualTo: customerId);
    }
    if (after != null) query = query.startAfterDocument(after);
    final snapshot = await query.get();
    return OrderPage(
      orders: snapshot.docs.map(CommerceOrder.fromDocument).toList(),
      nextCursor: snapshot.docs.length == limit ? snapshot.docs.last : null,
    );
  }

  Future<bool> submitPaymentProof({
    required String orderId,
    required int claimedAmount,
  }) async {
    final urls = await _imageUploads.pickAndUpload(
      purpose: ImageUploadPurpose.paymentProof,
      maxFiles: 1,
    );
    if (urls.isEmpty) return false;
    await _payments.submitProof(
      orderId: orderId,
      proofUrl: urls.single,
      claimedAmount: claimedAmount,
    );
    return true;
  }

  Future<void> reviewPayment({
    required String orderId,
    required String paymentId,
    required bool approved,
    int? confirmedAmount,
  }) => _payments.review(
    orderId: orderId,
    paymentId: paymentId,
    approved: approved,
    confirmedAmount: confirmedAmount,
  );

  Future<void> updateDeliveryFee(String orderId, int deliveryFee) =>
      _admin.updateDeliveryFee(orderId, deliveryFee);

  Future<void> updateStatus(String orderId, OrderStatus status) =>
      _admin.updateStatus(orderId, status);
}
