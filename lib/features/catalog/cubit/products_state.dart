import 'package:equatable/equatable.dart';

import '../data/models/product.dart';

enum ProductsStatus { initial, loading, success, empty, failure }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.hasMore = false,
    this.message,
  });

  final ProductsStatus status;
  final List<Product> products;
  final bool hasMore;
  final String? message;

  @override
  List<Object?> get props => [status, products, hasMore, message];
}
