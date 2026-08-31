import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/product_repository.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._repository) : super(const CategoriesState());

  final ProductRepository _repository;

  Future<void> load() async {
    emit(const CategoriesState(status: CategoriesStatus.loading));
    try {
      final categories = await _repository.getActiveCategories();
      emit(
        CategoriesState(
          status: categories.isEmpty
              ? CategoriesStatus.empty
              : CategoriesStatus.success,
          categories: categories,
        ),
      );
    } catch (error) {
      emit(
        CategoriesState(
          status: CategoriesStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
