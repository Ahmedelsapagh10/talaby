import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../../orders/data/models/commerce_order.dart';
import 'models/customer.dart';

class CustomerPage {
  const CustomerPage({required this.customers, this.nextCursor});

  final List<Customer> customers;
  final DocumentSnapshot<Map<String, dynamic>>? nextCursor;
  bool get hasMore => nextCursor != null;
}

class CustomerRepository {
  CustomerRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<Customer?> findByPhone(String phone) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.customers)
        .where('phone', isEqualTo: phone.trim())
        .limit(1)
        .get();
    return snapshot.docs.isEmpty
        ? null
        : Customer.fromDocument(snapshot.docs.first);
  }

  Future<CustomerPage> getCustomers({
    int limit = 30,
    DocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestorePaths.customers)
        .orderBy('lastOrderAt', descending: true)
        .limit(limit);
    if (after != null) query = query.startAfterDocument(after);
    final snapshot = await query.get();
    return CustomerPage(
      customers: snapshot.docs.map(Customer.fromDocument).toList(),
      nextCursor: snapshot.docs.length == limit ? snapshot.docs.last : null,
    );
  }

  Future<List<CommerceOrder>> getOrders(
    String customerId, {
    int limit = 20,
  }) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.orders)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(CommerceOrder.fromDocument).toList();
  }

  Future<CommerceOrder?> getLastOrder(String customerId) async {
    final orders = await getOrders(customerId, limit: 1);
    return orders.isEmpty ? null : orders.first;
  }
}
