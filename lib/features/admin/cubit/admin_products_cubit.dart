import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../catalog/data/product_repository.dart';
import '../../reviews/data/review_repository.dart';
import 'admin_products_state.dart';

class AdminProductsCubit extends Cubit<AdminProductsState> {
  AdminProductsCubit(this._repository, this._reviews)
    : super(const AdminProductsState());

  final ProductRepository _repository;
  final ReviewRepository _reviews;
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _loadingMore = false;
  bool _searchPrepared = false;

  Future<void> load({String? query}) async {
    final searchQuery = query ?? state.query;
    emit(
      AdminProductsState(
        status: AdminProductsStatus.loading,
        products: state.products,
        query: searchQuery,
      ),
    );
    try {
      if (!_searchPrepared) {
        await _repository.backfillSearchPrefixes();
        _searchPrepared = true;
      }
      final page = await _repository.getAdminProducts(searchQuery: searchQuery);
      _cursor = page.nextCursor;
      emit(
        AdminProductsState(
          status: page.products.isEmpty
              ? AdminProductsStatus.empty
              : AdminProductsStatus.success,
          products: page.products,
          hasMore: page.hasMore,
          query: searchQuery,
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
      final page = await _repository.getAdminProducts(
        searchQuery: state.query,
        after: _cursor,
      );
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

  Future<void> delete(String productId) async {
    await _update(() async {
      await _repository.deleteProduct(productId);
      await _reviews.deleteForProduct(productId);
    });
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
