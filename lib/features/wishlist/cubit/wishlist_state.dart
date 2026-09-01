import 'package:equatable/equatable.dart';

import '../../catalog/data/models/product.dart';

enum WishlistStatus { initial, loading, success, empty, failure }

class WishlistState extends Equatable {
  const WishlistState({
    this.status = WishlistStatus.initial,
    this.productIds = const {},
    this.products = const [],
    this.message,
  });

  final WishlistStatus status;
  final Set<String> productIds;
  final List<Product> products;
  final String? message;

  bool contains(String productId) => productIds.contains(productId);

  @override
  List<Object?> get props => [status, productIds, products, message];
}
