import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/review_repository.dart';
import 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  ReviewsCubit(this._repository) : super(const ReviewsState());

  final ReviewRepository _repository;
  String? _productId;

  Future<void> load(String productId) async {
    _productId = productId;
    emit(const ReviewsState(status: ReviewsStatus.loading));
    try {
      final reviews = await _repository.getApprovedForProduct(productId);
      emit(
        ReviewsState(
          status: reviews.isEmpty ? ReviewsStatus.empty : ReviewsStatus.success,
          reviews: reviews,
        ),
      );
    } catch (error) {
      _emitFailure(error);
    }
  }

  Future<void> submit({
    required String productId,
    required String customerId,
    required String displayName,
    required int rating,
    required String feedback,
  }) async {
    emit(
      ReviewsState(status: ReviewsStatus.submitting, reviews: state.reviews),
    );
    try {
      await _repository.submit(
        productId: productId,
        customerId: customerId,
        displayName: displayName,
        rating: rating,
        feedback: feedback,
      );
      emit(
        ReviewsState(
          status: state.reviews.isEmpty
              ? ReviewsStatus.empty
              : ReviewsStatus.success,
          reviews: state.reviews,
          submitted: true,
        ),
      );
    } catch (error) {
      _emitFailure(error);
    }
  }

  Future<void> refresh() async {
    if (_productId != null) await load(_productId!);
  }

  void _emitFailure(Object error) {
    emit(
      ReviewsState(
        status: ReviewsStatus.failure,
        reviews: state.reviews,
        message: error.toString(),
      ),
    );
  }
}
