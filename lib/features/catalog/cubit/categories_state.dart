import 'package:equatable/equatable.dart';

import '../data/models/category.dart';

enum CategoriesStatus { initial, loading, success, empty, failure }

class CategoriesState extends Equatable {
  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.message,
  });

  final CategoriesStatus status;
  final List<Category> categories;
  final String? message;

  @override
  List<Object?> get props => [status, categories, message];
}
