import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../catalog/data/product_repository.dart';
import 'admin_products_state.dart';

class AdminProductsCubit extends Cubit<AdminProductsState> {
  AdminProductsCubit(this._repository) : super(const AdminProductsState());

  final ProductRepository _repository;
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _loadingMore = false;

  Future<void> load() async {
    emit(const AdminProductsState(status: AdminProductsStatus.loading));
    try {
      final page = await _repository.getAdminProducts();
      _cursor = page.nextCursor;
      emit(
        AdminProductsState(
          status: page.products.isEmpty
              ? AdminProductsStatus.empty
              : AdminProductsStatus.success,
          products: page.products,
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
      final page = await _repository.getAdminProducts(after: _cursor);
      _cursor = page.nextCursor;
      emit(
        state.copyWith(
          status: AdminProductsStatus.success,
          products: [...state.products, ...page.products],
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      _emitFailure(error);
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> setActive(String productId, bool active) async {
    await _update(() => _repository.setProductActive(productId, active));
  }

  Future<void> setFeatured(String productId, bool featured) async {
    await _update(() => _repository.setFeatured(productId, featured));
  }

  Future<void> _update(Future<void> Function() operation) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await operation();
      await load();
    } catch (error) {
      _emitFailure(error);
    }
  }

  void _emitFailure(Object error) {
    emit(
      state.copyWith(
        status: AdminProductsStatus.failure,
        isUpdating: false,
        message: error.toString(),
      ),
    );
  }
}
