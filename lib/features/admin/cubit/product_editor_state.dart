import 'package:equatable/equatable.dart';

import '../../catalog/data/models/category.dart';
import '../../catalog/data/models/product.dart';

enum ProductEditorStatus {
  initial,
  loading,
  ready,
  uploading,
  saving,
  success,
  failure,
}

class ProductEditorState extends Equatable {
  const ProductEditorState({
    this.status = ProductEditorStatus.initial,
    this.product,
    this.categories = const [],
    this.uploadedImageUrls = const [],
    this.savedProductId,
    this.message,
  });

  final ProductEditorStatus status;
  final Product? product;
  final List<Category> categories;
  final List<String> uploadedImageUrls;
  final String? savedProductId;
  final String? message;

  @override
  List<Object?> get props => [
    status,
    product,
    categories,
    uploadedImageUrls,
    savedProductId,
    message,
  ];
}
