import 'package:flutter_bloc/flutter_bloc.dart';

import '../../catalog/data/models/category.dart';
import '../../catalog/data/product_repository.dart';
import 'admin_categories_state.dart';

class AdminCategoriesCubit extends Cubit<AdminCategoriesState> {
  AdminCategoriesCubit(this._repository) : super(const AdminCategoriesState());

  final ProductRepository _repository;

  Future<void> load() async {
    emit(const AdminCategoriesState(status: AdminCategoriesStatus.loading));
    try {
      final categories = await _repository.getAdminCategories();
      emit(
        AdminCategoriesState(
          status: categories.isEmpty
              ? AdminCategoriesStatus.empty
              : AdminCategoriesStatus.success,
          categories: categories,
        ),
      );
    } catch (error) {
      _emitFailure(error);
    }
  }

  Future<String?> save(Category category) async {
    emit(
      AdminCategoriesState(
        status: state.status,
        categories: state.categories,
        isUpdating: true,
      ),
    );
    try {
      final id = await _repository.saveCategory(category);
      await load();
      return id;
    } catch (error) {
      _emitFailure(error);
      return null;
    }
  }

  Future<void> setActive(String categoryId, bool active) async {
    emit(
      AdminCategoriesState(
        status: state.status,
        categories: state.categories,
        isUpdating: true,
      ),
    );
    try {
      await _repository.setCategoryActive(categoryId, active);
      await load();
    } catch (error) {
      _emitFailure(error);
    }
  }

  void _emitFailure(Object error) {
    emit(
      AdminCategoriesState(
        status: AdminCategoriesStatus.failure,
        categories: state.categories,
        message: error.toString(),
      ),
    );
  }
}
