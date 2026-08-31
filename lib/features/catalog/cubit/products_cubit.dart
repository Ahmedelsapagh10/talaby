import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_repository.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._repository) : super(const ProductsState());

  final ProductRepository _repository;
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _loadingMore = false;
  String? _categoryId;
  bool? _featured;

  Future<void> load({String? categoryId, bool? featured}) async {
    emit(const ProductsState(status: ProductsStatus.loading));
    _cursor = null;
    _categoryId = categoryId;
    _featured = featured;
    try {
      final page = await _repository.getActiveProducts(
        categoryId: categoryId,
        featured: featured,
      );
      _cursor = page.nextCursor;
      emit(
        ProductsState(
          status: page.products.isEmpty
              ? ProductsStatus.empty
              : ProductsStatus.success,
          products: page.products,
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      emit(
        ProductsState(
          status: ProductsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || _cursor == null) return;
    _loadingMore = true;
    try {
      final page = await _repository.getActiveProducts(
        categoryId: _categoryId,
        featured: _featured,
        after: _cursor,
      );
      _cursor = page.nextCursor;
      emit(
        ProductsState(
          status: ProductsStatus.success,
          products: [...state.products, ...page.products],
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      emit(
        ProductsState(
          status: ProductsStatus.failure,
          products: state.products,
          message: error.toString(),
        ),
      );
    } finally {
      _loadingMore = false;
    }
  }
}
