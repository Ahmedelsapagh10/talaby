import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_paths.dart';
import '../../catalog/data/models/product.dart';
import '../../catalog/data/product_repository.dart';

class WishlistData {
  const WishlistData({required this.productIds, required this.products});

  final Set<String> productIds;
  final List<Product> products;
}

class WishlistRepository {
  WishlistRepository(this._firestore, this._products);

  final FirebaseFirestore _firestore;
  final ProductRepository _products;

  Stream<WishlistData> watch(String userId) {
    return _firestore
        .collection(FirestorePaths.userWishlist(userId))
        .snapshots()
        .asyncMap((snapshot) => _resolve(userId, snapshot.docs));
  }

  Future<void> setFavorite({
    required String userId,
    required String productId,
    required bool favorite,
  }) async {
    final reference = _firestore.doc(
      FirestorePaths.wishlistItem(userId, productId),
    );
    if (!favorite) return reference.delete();
    await reference.set({
      'productId': productId,
      'ownerId': AppConfig.ownerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<WishlistData> _resolve(
    String userId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) async {
    final products = <Product>[];
    final staleIds = <String>[];
    for (final document in documents) {
      final product = await _products.getProduct(document.id);
      if (product == null || !product.active) {
        staleIds.add(document.id);
      } else {
        products.add(product);
      }
    }
    if (staleIds.isNotEmpty) {
      final batch = _firestore.batch();
      for (final id in staleIds) {
        batch.delete(_firestore.doc(FirestorePaths.wishlistItem(userId, id)));
      }
      await batch.commit();
    }
    return WishlistData(
      productIds: documents
          .map((document) => document.id)
          .where((id) => !staleIds.contains(id))
          .toSet(),
      products: products,
    );
  }
}
