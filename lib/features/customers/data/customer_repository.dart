import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../../../core/utils/search_normalizer.dart';
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
    String searchQuery = '',
    DocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    final phoneSearch = RegExp(r'^\+?[0-9 ()-]+$').hasMatch(searchQuery.trim());
    final search = phoneSearch
        ? SearchNormalizer.normalizePhone(searchQuery)
        : SearchNormalizer.normalize(searchQuery);
    Query<Map<String, dynamic>> query = _firestore.collection(
      FirestorePaths.customers,
    );
    if (search.isNotEmpty) {
      final field = phoneSearch ? 'searchPhone' : 'searchName';
      query = query.orderBy(field).startAt([search]).endAt(['$search\uf8ff']);
    } else {
      query = query.orderBy('lastOrderAt', descending: true);
    }
    query = query.limit(limit);
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

  Future<void> backfillSearchFields() async {
    final marker = _firestore.doc(FirestorePaths.searchBackfillSettings);
    if ((await marker.get()).data()?['customersV1'] == true) return;
    DocumentSnapshot<Map<String, dynamic>>? cursor;
    while (true) {
      Query<Map<String, dynamic>> request = _firestore
          .collection(FirestorePaths.customers)
          .orderBy(FieldPath.documentId)
          .limit(400);
      if (cursor != null) request = request.startAfterDocument(cursor);
      final snapshot = await request.get();
      if (snapshot.docs.isEmpty) break;
      final batch = _firestore.batch();
      var changed = false;
      for (final document in snapshot.docs) {
        final data = document.data();
        if (data['searchName'] != null && data['searchPhone'] != null) continue;
        batch.update(document.reference, {
          'searchName': SearchNormalizer.normalize(
            data['name']?.toString() ?? '',
          ),
          'searchPhone': SearchNormalizer.normalizePhone(
            data['phone']?.toString() ?? '',
          ),
        });
        changed = true;
      }
      if (changed) await batch.commit();
      cursor = snapshot.docs.last;
      if (snapshot.docs.length < 400) break;
    }
    await marker.set({
      'customersV1': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
