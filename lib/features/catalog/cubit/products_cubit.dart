import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_repository.dart';
import '../data/models/catalog_query.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._repository) : super(const ProductsState());

  final ProductRepository _repository;
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _loadingMore = false;
  CatalogQuery _query = const CatalogQuery();

  Future<void> load({CatalogQuery query = const CatalogQuery()}) async {
    emit(const ProductsState(status: ProductsStatus.loading));
    _cursor = null;
    _query = query;
    try {
      final page = await _repository.getActiveProducts(query: query);
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
        query: _query,
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
