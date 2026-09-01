import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_paths.dart';
import '../../cart/data/models/cart_item.dart';
import '../../checkout/data/models/checkout_details.dart';
import 'order_item_resolver.dart';
import 'order_record_utils.dart';
import '../../../core/utils/search_normalizer.dart';

class OrderCheckoutDataSource {
  OrderCheckoutDataSource(this._firestore, this._auth, this._itemResolver);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final OrderItemResolver _itemResolver;

  Future<String> finalizeOrder({
    required List<CartItem> items,
    required CheckoutDetails details,
  }) async {
    final userId = _requireUserId();
    if (items.isEmpty || items.length > 50) {
      throw StateError('Order items are invalid.');
    }
    final customer = _customerData(details);
    final ownerRef = _firestore.doc(FirestorePaths.owner);
    final counterRef = _firestore.doc(FirestorePaths.orderCounter);
    final customerRef = _firestore.doc(FirestorePaths.customer(userId));
    final orderRef = _firestore.collection(FirestorePaths.orders).doc();

    await _firestore.runTransaction((transaction) async {
      final owner = await transaction.get(ownerRef);
      final counter = await transaction.get(counterRef);
      final customerSnapshot = await transaction.get(customerRef);
      if (!owner.exists || owner.data()?['active'] != true) {
        throw StateError('Store is not active.');
      }

      final productIds = items.map((item) => item.productId).toSet();
      final products = <String, Map<String, dynamic>>{};
      for (final productId in productIds) {
        final snapshot = await transaction.get(
          _firestore.doc(FirestorePaths.product(productId)),
        );
        if (!snapshot.exists) throw StateError('A product is unavailable.');
        products[productId] = Map<String, dynamic>.from(snapshot.data()!);
      }

      final resolvedItems = <Map<String, dynamic>>[];
      final productUpdates = <String, Map<String, dynamic>>{};
      var subtotal = 0;
      var discountAmount = 0;
      for (final requested in items) {
        final product = products[requested.productId];
        if (product == null) throw StateError('A product is unavailable.');
        final resolved = _itemResolver.resolve(requested, product);
        resolvedItems.add(resolved.item);
        subtotal += (resolved.item['unitPrice'] as int) * requested.quantity;
        discountAmount += resolved.item['discountAmount'] as int;
        if (resolved.stockUpdate != null) {
          productUpdates[requested.productId] = resolved.stockUpdate!;
        }
      }

      final previousSequence =
          (counter.data()?['value'] as num?)?.toInt() ?? 10451;
      final sequence = previousSequence + 1;
      final total = subtotal - discountAmount;
      final now = FieldValue.serverTimestamp();
      transaction.set(counterRef, {
        'value': sequence,
        'updatedAt': now,
      }, SetOptions(merge: true));
      for (final update in productUpdates.entries) {
        transaction.update(_firestore.doc(FirestorePaths.product(update.key)), {
          ...update.value,
          'updatedAt': now,
        });
      }
      transaction.set(orderRef, {
        'readableOrderNumber': 'ORD-$sequence',
        'ownerId': AppConfig.ownerId,
        'customerId': userId,
        'customerName': customer['name'],
        'phone': customer['mobile'],
        'email': _auth.currentUser?.email,
        'defaultCity': customer['city'],
        'defaultAddress': customer['address'],
        'searchName': SearchNormalizer.normalize(customer['name']!),
        'searchPhone': SearchNormalizer.normalizePhone(customer['mobile']!),
        'searchPrefixes': SearchNormalizer.prefixes(
          'ORD-$sequence ${customer['name']} ${customer['mobile']} '
          '${SearchNormalizer.normalizePhone(customer['mobile']!)}',
        ),
        'city': customer['city'],
        'address': customer['address'],
        'notes': customer['notes'],
        'items': resolvedItems,
        'subtotal': subtotal,
        'discountAmount': discountAmount,
        'deliveryFee': null,
        'total': total,
        'paidAmount': 0,
        'remainingAmount': total,
        'paymentStatus': 'unpaid',
        'orderStatus': 'pending',
        'payments': const [],
        'events': [publicOrderEvent('orderCreated')],
        'createdAt': now,
        'updatedAt': now,
      });
      transaction.set(customerRef, {
        'name': customer['name'],
        'phone': customer['mobile'],
        'email': _auth.currentUser?.email,
        'defaultCity': customer['city'],
        'defaultAddress': customer['address'],
        'searchName': SearchNormalizer.normalize(customer['name']!),
        'searchPhone': SearchNormalizer.normalizePhone(customer['mobile']!),
        'orderCount': FieldValue.increment(1),
        'lastOrderAt': now,
        'updatedAt': now,
        if (!customerSnapshot.exists) 'createdAt': now,
      }, SetOptions(merge: true));
    });

    await addOrderAuditEvent(orderRef, 'orderCreated', userId, const {});
    return orderRef.id;
  }

  String _requireUserId() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('Authentication is required.');
    return userId;
  }

  Map<String, String?> _customerData(CheckoutDetails details) => {
    'name': _required(details.name, 'customer.name', 120),
    'mobile': _required(details.mobile, 'customer.mobile', 30),
    'city': _required(details.city, 'customer.city', 120),
    'address': _required(details.address, 'customer.address', 500),
    'notes': _optionalNotes(details.notes),
  };

  String? _optionalNotes(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.length <= 1000 ? trimmed : trimmed.substring(0, 1000);
  }

  String _required(String value, String field, int maxLength) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) {
      throw StateError('$field is invalid.');
    }
    return trimmed;
  }
}
