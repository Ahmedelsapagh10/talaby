import 'package:equatable/equatable.dart';

import '../../catalog/data/models/category.dart';

enum AdminCategoriesStatus { initial, loading, success, empty, failure }

class AdminCategoriesState extends Equatable {
  const AdminCategoriesState({
    this.status = AdminCategoriesStatus.initial,
    this.categories = const [],
    this.isUpdating = false,
    this.message,
  });

  final AdminCategoriesStatus status;
  final List<Category> categories;
  final bool isUpdating;
  final String? message;

  @override
  List<Object?> get props => [status, categories, isUpdating, message];
}
