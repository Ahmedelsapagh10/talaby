import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_paths.dart';
import 'models/review.dart';

class ReviewPage {
  const ReviewPage({required this.reviews, this.nextCursor});

  final List<Review> reviews;
  final DocumentSnapshot<Map<String, dynamic>>? nextCursor;
  bool get hasMore => nextCursor != null;
}

class ReviewRepository {
  ReviewRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<Review>> getApprovedForProduct(
    String productId, {
    int limit = 20,
  }) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.reviews)
        .where('productId', isEqualTo: productId)
        .where('approved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(Review.fromDocument).toList();
  }

  Future<ReviewPage> getAdminReviews({
    int limit = 30,
    bool? approved,
    DocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(
      FirestorePaths.reviews,
    );
    if (approved != null) {
      query = query.where('approved', isEqualTo: approved);
    }
    query = query.orderBy('createdAt', descending: true).limit(limit);
    if (after != null) query = query.startAfterDocument(after);
    final snapshot = await query.get();
    return ReviewPage(
      reviews: snapshot.docs.map(Review.fromDocument).toList(),
      nextCursor: snapshot.docs.length == limit ? snapshot.docs.last : null,
    );
  }

  Future<String> submit({
    required String productId,
    required String customerId,
    required String displayName,
    required int rating,
    required String feedback,
  }) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError.value(rating, 'rating', 'Must be between 1 and 5.');
    }
    final document = _firestore.collection(FirestorePaths.reviews).doc();
    await document.set({
      'productId': productId,
      'customerId': customerId,
      'displayName': displayName.trim(),
      'rating': rating,
      'feedback': feedback.trim(),
      'approved': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return document.id;
  }

  Future<void> setApproved(String reviewId, bool approved) async {
    final reviewRef = _firestore.doc(FirestorePaths.review(reviewId));
    await _firestore.runTransaction((transaction) async {
      final reviewSnapshot = await transaction.get(reviewRef);
      if (!reviewSnapshot.exists) throw StateError('Review was not found.');
      final review = reviewSnapshot.data()!;
      final wasApproved = review['approved'] == true;
      final productId = review['productId']?.toString() ?? '';
      final productRef = productId.isEmpty
          ? null
          : _firestore.doc(FirestorePaths.product(productId));
      final productSnapshot = wasApproved == approved || productRef == null
          ? null
          : await transaction.get(productRef);

      transaction.update(reviewRef, {
        'approved': approved,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (productRef != null && productSnapshot?.exists == true) {
        _updateRating(
          transaction,
          productRef,
          productSnapshot!.data()!,
          countChange: approved ? 1 : -1,
          ratingChange:
              (approved ? 1 : -1) * ((review['rating'] as num?)?.toInt() ?? 0),
        );
      }
    });
  }

  Future<void> delete(String reviewId) async {
    final reviewRef = _firestore.doc(FirestorePaths.review(reviewId));
    await _firestore.runTransaction((transaction) async {
      final reviewSnapshot = await transaction.get(reviewRef);
      if (!reviewSnapshot.exists) return;
      final review = reviewSnapshot.data()!;
      final approved = review['approved'] == true;
      final productId = review['productId']?.toString() ?? '';
      final productRef = productId.isEmpty
          ? null
          : _firestore.doc(FirestorePaths.product(productId));
      final productSnapshot = approved && productRef != null
          ? await transaction.get(productRef)
          : null;

      transaction.delete(reviewRef);
      if (productRef != null && productSnapshot?.exists == true) {
        _updateRating(
          transaction,
          productRef,
          productSnapshot!.data()!,
          countChange: -1,
          ratingChange: -((review['rating'] as num?)?.toInt() ?? 0),
        );
      }
    });
  }

  void _updateRating(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> productRef,
    Map<String, dynamic> product, {
    required int countChange,
    required int ratingChange,
  }) {
    final currentCount = (product['reviewsCount'] as num?)?.toInt() ?? 0;
    final currentTotal = (product['ratingTotal'] as num?)?.toInt() ?? 0;
    final reviewsCount = (currentCount + countChange).clamp(0, 1 << 31);
    final ratingTotal = (currentTotal + ratingChange).clamp(0, 1 << 53);
    transaction.update(productRef, {
      'reviewsCount': reviewsCount,
      'ratingTotal': ratingTotal,
      'averageRating': reviewsCount == 0 ? 0 : ratingTotal / reviewsCount,
    });
  }
}
