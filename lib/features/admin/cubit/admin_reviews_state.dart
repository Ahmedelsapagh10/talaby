import 'package:equatable/equatable.dart';

import '../../reviews/data/models/review.dart';

enum AdminReviewsStatus { initial, loading, success, empty, failure }

class AdminReviewsState extends Equatable {
  const AdminReviewsState({
    this.status = AdminReviewsStatus.initial,
    this.reviews = const [],
    this.approvedFilter,
    this.hasMore = false,
    this.isUpdating = false,
    this.message,
  });

  final AdminReviewsStatus status;
  final List<Review> reviews;
  final bool? approvedFilter;
  final bool hasMore;
  final bool isUpdating;
  final String? message;

  AdminReviewsState copyWith({
    AdminReviewsStatus? status,
    List<Review>? reviews,
    bool? approvedFilter,
    bool clearFilter = false,
    bool? hasMore,
    bool? isUpdating,
    String? message,
  }) => AdminReviewsState(
    status: status ?? this.status,
    reviews: reviews ?? this.reviews,
    approvedFilter: clearFilter ? null : approvedFilter ?? this.approvedFilter,
    hasMore: hasMore ?? this.hasMore,
    isUpdating: isUpdating ?? this.isUpdating,
    message: message,
  );

  @override
  List<Object?> get props => [
    status,
    reviews,
    approvedFilter,
    hasMore,
    isUpdating,
    message,
  ];
}
