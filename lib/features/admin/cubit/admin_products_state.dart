import 'package:equatable/equatable.dart';

import '../../catalog/data/models/product.dart';

enum AdminProductsStatus { initial, loading, success, empty, failure }

class AdminProductsState extends Equatable {
  const AdminProductsState({
    this.status = AdminProductsStatus.initial,
    this.products = const [],
    this.hasMore = false,
    this.isUpdating = false,
    this.query = '',
    this.message,
  });

  final AdminProductsStatus status;
  final List<Product> products;
  final bool hasMore;
  final bool isUpdating;
  final String query;
  final String? message;

  AdminProductsState copyWith({
    AdminProductsStatus? status,
    List<Product>? products,
    bool? hasMore,
    bool? isUpdating,
    String? query,
    String? message,
  }) => AdminProductsState(
    status: status ?? this.status,
    products: products ?? this.products,
    hasMore: hasMore ?? this.hasMore,
    isUpdating: isUpdating ?? this.isUpdating,
    query: query ?? this.query,
    message: message,
  );

  @override
  List<Object?> get props => [
    status,
    products,
    hasMore,
    isUpdating,
    query,
    message,
  ];
}
