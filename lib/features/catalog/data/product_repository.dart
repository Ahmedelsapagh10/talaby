import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_paths.dart';
import 'models/category.dart';
import 'models/product.dart';

class ProductPage {
  const ProductPage({required this.products, this.nextCursor});

  final List<Product> products;
  final DocumentSnapshot<Map<String, dynamic>>? nextCursor;
  bool get hasMore => nextCursor != null;
}

class ProductRepository {
  ProductRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<Category>> getActiveCategories() async {
    final snapshot = await _firestore
        .collection(FirestorePaths.categories)
        .where('active', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snapshot.docs.map(Category.fromDocument).toList();
  }

  Future<List<Category>> getAdminCategories() async {
    final snapshot = await _firestore
        .collection(FirestorePaths.categories)
        .orderBy('sortOrder')
        .get();
    return snapshot.docs.map(Category.fromDocument).toList();
  }

  Future<ProductPage> getActiveProducts({
    int limit = 24,
    String? categoryId,
    bool? featured,
    DocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestorePaths.products)
        .where('active', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (featured != null) {
      query = query.where('featured', isEqualTo: featured);
    }
    if (after != null) query = query.startAfterDocument(after);
    final snapshot = await query.get();
    return ProductPage(
      products: snapshot.docs.map(Product.fromDocument).toList(),
      nextCursor: snapshot.docs.length == limit ? snapshot.docs.last : null,
    );
  }

  Future<ProductPage> getAdminProducts({
    int limit = 30,
    DocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestorePaths.products)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (after != null) query = query.startAfterDocument(after);
    final snapshot = await query.get();
    return ProductPage(
      products: snapshot.docs.map(Product.fromDocument).toList(),
      nextCursor: snapshot.docs.length == limit ? snapshot.docs.last : null,
    );
  }

  Future<Product?> getProduct(String productId) async {
    final document = await _firestore
        .doc(FirestorePaths.product(productId))
        .get();
    return document.exists ? Product.fromDocument(document) : null;
  }

  Stream<Product?> watchProduct(String productId) {
    return _firestore
        .doc(FirestorePaths.product(productId))
        .snapshots()
        .map((doc) => doc.exists ? Product.fromDocument(doc) : null);
  }

  Future<String> saveProduct(Product product) async {
    final collection = _firestore.collection(FirestorePaths.products);
    final document = product.id.isEmpty
        ? collection.doc()
        : collection.doc(product.id);
    final data = product.toMap()
      ..['ownerId'] = AppConfig.ownerId
      ..['updatedAt'] = FieldValue.serverTimestamp();
    if (product.id.isEmpty) data['createdAt'] = FieldValue.serverTimestamp();
    await document.set(data, SetOptions(merge: true));
    return document.id;
  }

  Future<String> saveCategory(Category category) async {
    final collection = _firestore.collection(FirestorePaths.categories);
    final document = category.id.isEmpty
        ? collection.doc()
        : collection.doc(category.id);
    await document.set({
      ...category.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (category.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return document.id;
  }

  Future<void> setCategoryActive(String categoryId, bool active) {
    return _firestore.doc('${FirestorePaths.categories}/$categoryId').update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setProductActive(String productId, bool active) {
    return _firestore.doc(FirestorePaths.product(productId)).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setFeatured(String productId, bool featured) {
    return _firestore.doc(FirestorePaths.product(productId)).update({
      'featured': featured,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
