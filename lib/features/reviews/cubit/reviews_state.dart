import 'package:equatable/equatable.dart';

import '../data/models/review.dart';

enum ReviewsStatus { initial, loading, success, empty, submitting, failure }

class ReviewsState extends Equatable {
  const ReviewsState({
    this.status = ReviewsStatus.initial,
    this.reviews = const [],
    this.submitted = false,
    this.message,
  });

  final ReviewsStatus status;
  final List<Review> reviews;
  final bool submitted;
  final String? message;

  @override
  List<Object?> get props => [status, reviews, submitted, message];
}
