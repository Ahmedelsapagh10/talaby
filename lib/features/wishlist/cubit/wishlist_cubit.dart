import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/wishlist_repository.dart';
import 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit(this._repository) : super(const WishlistState());

  final WishlistRepository _repository;
  StreamSubscription<WishlistData>? _subscription;
  String? _userId;

  Future<void> bind(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    await _subscription?.cancel();
    if (userId == null) {
      emit(const WishlistState());
      return;
    }
    emit(const WishlistState(status: WishlistStatus.loading));
    _subscription = _repository
        .watch(userId)
        .listen(
          (data) => emit(
            WishlistState(
              status: data.products.isEmpty
                  ? WishlistStatus.empty
                  : WishlistStatus.success,
              productIds: data.productIds,
              products: data.products,
            ),
          ),
          onError: (Object error) => emit(
            WishlistState(
              status: WishlistStatus.failure,
              productIds: state.productIds,
              products: state.products,
              message: error.toString(),
            ),
          ),
        );
  }

  Future<void> toggle(String productId) async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await _repository.setFavorite(
        userId: userId,
        productId: productId,
        favorite: !state.contains(productId),
      );
    } catch (error) {
      emit(
        WishlistState(
          status: WishlistStatus.failure,
          productIds: state.productIds,
          products: state.products,
          message: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
