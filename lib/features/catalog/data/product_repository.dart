import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_paths.dart';
import '../../../core/utils/search_normalizer.dart';
import 'models/catalog_query.dart';
import 'models/category.dart';
import 'models/product.dart';
import 'product_search_data_source.dart';

class ProductPage {
  const ProductPage({required this.products, this.nextCursor});

  final List<Product> products;
  final DocumentSnapshot<Map<String, dynamic>>? nextCursor;
  bool get hasMore => nextCursor != null;
}

class ProductRepository {
  ProductRepository(FirebaseFirestore firestore)
    : _firestore = firestore,
      _searchDataSource = ProductSearchDataSource(firestore);

  final FirebaseFirestore _firestore;
  final ProductSearchDataSource _searchDataSource;

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
    CatalogQuery query = const CatalogQuery(),
    DocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    final search = SearchNormalizer.normalize(query.searchQuery ?? '');
    if (search.length >= 2) {
      final result = await _searchDataSource.searchActive(
        search: search,
        limit: limit,
        categoryId: query.categoryId,
        featured: query.featured,
        after: after,
      );
      return ProductPage(
        products: result.documents.map(Product.fromDocument).toList(),
        nextCursor: result.nextCursor,
      );
    }
    Query<Map<String, dynamic>> request = _firestore
        .collection(FirestorePaths.products)
        .where('active', isEqualTo: true);
    if (query.categoryId != null) {
      request = request.where('categoryId', isEqualTo: query.categoryId);
    }
    if (query.featured != null) {
      request = request.where('featured', isEqualTo: query.featured);
    }
    if (query.sort == ProductSort.newest) {
      request = request.orderBy('createdAt', descending: true);
    }
    if (after != null) request = request.startAfterDocument(after);
    final snapshot = await request.limit(limit).get();
    return ProductPage(
      products: snapshot.docs.map(Product.fromDocument).toList(),
      nextCursor: snapshot.docs.length == limit ? snapshot.docs.last : null,
    );
  }

  Future<ProductPage> getAdminProducts({
    int limit = 30,
    String searchQuery = '',
    DocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    final search = SearchNormalizer.normalize(searchQuery);
    Query<Map<String, dynamic>> query = _firestore.collection(
      FirestorePaths.products,
    );
    if (search.length >= 2) {
      query = query.where('searchPrefixes', arrayContains: search);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }
    query = query.limit(limit);
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
      ..['searchPrefixes'] = SearchNormalizer.prefixes(product.name)
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

  Future<void> deleteProduct(String productId) {
    return _firestore.doc(FirestorePaths.product(productId)).delete();
  }

  Future<void> backfillSearchPrefixes() =>
      _searchDataSource.backfillSearchPrefixes();
}
