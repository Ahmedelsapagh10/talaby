import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../reviews/data/review_repository.dart';
import 'admin_reviews_state.dart';

class AdminReviewsCubit extends Cubit<AdminReviewsState> {
  AdminReviewsCubit(this._repository) : super(const AdminReviewsState());

  final ReviewRepository _repository;
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _loadingMore = false;

  Future<void> load({bool? approved}) async {
    emit(
      AdminReviewsState(
        status: AdminReviewsStatus.loading,
        approvedFilter: approved,
      ),
    );
    try {
      final page = await _repository.getAdminReviews(approved: approved);
      _cursor = page.nextCursor;
      emit(
        AdminReviewsState(
          status: page.reviews.isEmpty
              ? AdminReviewsStatus.empty
              : AdminReviewsStatus.success,
          reviews: page.reviews,
          approvedFilter: approved,
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      _emitFailure(error);
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || _cursor == null) return;
    _loadingMore = true;
    try {
      final page = await _repository.getAdminReviews(
        approved: state.approvedFilter,
        after: _cursor,
      );
      _cursor = page.nextCursor;
      emit(
        state.copyWith(
          status: AdminReviewsStatus.success,
          reviews: [...state.reviews, ...page.reviews],
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      _emitFailure(error);
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> setApproved(String reviewId, bool approved) async {
    await _update(() => _repository.setApproved(reviewId, approved));
  }

  Future<void> delete(String reviewId) async {
    await _update(() => _repository.delete(reviewId));
  }

  Future<void> _update(Future<void> Function() operation) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await operation();
      await load(approved: state.approvedFilter);
    } catch (error) {
      _emitFailure(error);
    }
  }

  void _emitFailure(Object error) {
    emit(
      state.copyWith(
        status: AdminReviewsStatus.failure,
        isUpdating: false,
        message: error.toString(),
      ),
    );
  }
}
