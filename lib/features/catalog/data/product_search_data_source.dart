import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../../../core/utils/search_normalizer.dart';

class ProductSearchDocuments {
  const ProductSearchDocuments({required this.documents, this.nextCursor});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents;
  final DocumentSnapshot<Map<String, dynamic>>? nextCursor;
}

class ProductSearchDataSource {
  ProductSearchDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<ProductSearchDocuments> searchActive({
    required String search,
    required int limit,
    String? categoryId,
    bool? featured,
    DocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    Query<Map<String, dynamic>> request = _firestore
        .collection(FirestorePaths.products)
        .where('active', isEqualTo: true);
    if (categoryId != null) {
      request = request.where('categoryId', isEqualTo: categoryId);
    }
    if (featured != null) {
      request = request.where('featured', isEqualTo: featured);
    }
    Query<Map<String, dynamic>> indexedRequest = request.where(
      'searchPrefixes',
      arrayContains: search,
    );
    if (after != null) {
      indexedRequest = indexedRequest.startAfterDocument(after);
    }
    try {
      final snapshot = await indexedRequest.limit(limit).get();
      if (snapshot.docs.isNotEmpty || after != null) {
        return ProductSearchDocuments(
          documents: snapshot.docs,
          nextCursor: snapshot.docs.length == limit ? snapshot.docs.last : null,
        );
      }
    } on FirebaseException catch (error) {
      if (error.code != 'failed-precondition') rethrow;
    }

    final fallback = await request.limit(500).get();
    final matches = fallback.docs
        .where(
          (document) => SearchNormalizer.matchesPrefix(
            document.data()['name']?.toString() ?? '',
            search,
          ),
        )
        .take(limit)
        .toList();
    return ProductSearchDocuments(documents: matches);
  }

  Future<void> backfillSearchPrefixes() async {
    final marker = _firestore.doc(FirestorePaths.searchBackfillSettings);
    if ((await marker.get()).data()?['productsV2'] == true) return;
    DocumentSnapshot<Map<String, dynamic>>? cursor;
    while (true) {
      Query<Map<String, dynamic>> request = _firestore
          .collection(FirestorePaths.products)
          .orderBy(FieldPath.documentId)
          .limit(400);
      if (cursor != null) request = request.startAfterDocument(cursor);
      final snapshot = await request.get();
      if (snapshot.docs.isEmpty) break;
      final batch = _firestore.batch();
      var changed = false;
      for (final document in snapshot.docs) {
        final expected = SearchNormalizer.prefixes(
          document.data()['name']?.toString() ?? '',
        );
        final current =
            (document.data()['searchPrefixes'] as List?)
                ?.map((value) => value.toString())
                .toSet() ??
            const <String>{};
        if (current.length == expected.length &&
            current.containsAll(expected)) {
          continue;
        }
        batch.update(document.reference, {'searchPrefixes': expected});
        changed = true;
      }
      if (changed) await batch.commit();
      cursor = snapshot.docs.last;
      if (snapshot.docs.length < 400) break;
    }
    await marker.set({
      'productsV2': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
