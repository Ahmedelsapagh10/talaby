import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/product.dart';
import '../data/product_repository.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._repository) : super(const ProductDetailsState());

  final ProductRepository _repository;
  StreamSubscription<Product?>? _subscription;

  Future<void> watch(String productId) async {
    emit(const ProductDetailsState(status: ProductDetailsStatus.loading));
    await _subscription?.cancel();
    _subscription = _repository
        .watchProduct(productId)
        .listen(
          (product) => emit(
            ProductDetailsState(
              status: product == null
                  ? ProductDetailsStatus.empty
                  : ProductDetailsStatus.success,
              product: product,
            ),
          ),
          onError: (Object error) => emit(
            ProductDetailsState(
              status: ProductDetailsStatus.failure,
              message: error.toString(),
            ),
          ),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
