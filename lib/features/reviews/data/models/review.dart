import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  const Review({
    required this.id,
    required this.productId,
    this.productName,
    required this.rating,
    required this.feedback,
    required this.displayName,
    required this.approved,
    this.customerId,
    this.createdAt,
  });

  final String id;
  final String productId;
  final String? productName;
  final String? customerId;
  final int rating;
  final String feedback;
  final String displayName;
  final bool approved;
  final DateTime? createdAt;

  factory Review.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const <String, dynamic>{};
    return Review(
      id: doc.id,
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString(),
      customerId: map['customerId']?.toString(),
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      feedback: map['feedback']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      approved: map['approved'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
