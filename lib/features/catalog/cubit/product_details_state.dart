import 'package:equatable/equatable.dart';

import '../data/models/product.dart';

enum ProductDetailsStatus { initial, loading, success, empty, failure }

class ProductDetailsState extends Equatable {
  const ProductDetailsState({
    this.status = ProductDetailsStatus.initial,
    this.product,
    this.message,
  });

  final ProductDetailsStatus status;
  final Product? product;
  final String? message;

  @override
  List<Object?> get props => [status, product, message];
}
