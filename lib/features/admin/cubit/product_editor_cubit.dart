import 'package:flutter_bloc/flutter_bloc.dart';

import '../../catalog/data/models/product.dart';
import '../../catalog/data/product_repository.dart';
import '../../uploads/data/image_upload_repository.dart';
import 'product_editor_state.dart';

class ProductEditorCubit extends Cubit<ProductEditorState> {
  ProductEditorCubit(this._repository, this._imageUploads)
    : super(const ProductEditorState());

  final ProductRepository _repository;
  final ImageUploadRepository _imageUploads;

  Future<void> load({String? productId}) async {
    emit(const ProductEditorState(status: ProductEditorStatus.loading));
    try {
      final categories = await _repository.getAdminCategories();
      final product = productId == null
          ? null
          : await _repository.getProduct(productId);
      emit(
        ProductEditorState(
          status: ProductEditorStatus.ready,
          product: product,
          categories: categories,
        ),
      );
    } catch (error) {
      emit(
        ProductEditorState(
          status: ProductEditorStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> save(Product product) async {
    final categories = state.categories;
    emit(
      ProductEditorState(
        status: ProductEditorStatus.saving,
        product: product,
        categories: categories,
      ),
    );
    try {
      final productId = await _repository.saveProduct(product);
      emit(
        ProductEditorState(
          status: ProductEditorStatus.success,
          product: product,
          categories: categories,
          savedProductId: productId,
        ),
      );
    } catch (error) {
      emit(
        ProductEditorState(
          status: ProductEditorStatus.failure,
          product: product,
          categories: categories,
          message: error.toString(),
        ),
      );
    }
  }

  Future<List<String>> uploadProductImages({int maxFiles = 12}) {
    return _upload(ImageUploadPurpose.product, maxFiles);
  }

  Future<List<String>> uploadColorImages({int maxFiles = 12}) {
    return _upload(ImageUploadPurpose.productColor, maxFiles);
  }

  Future<List<String>> _upload(ImageUploadPurpose purpose, int maxFiles) async {
    emit(
      ProductEditorState(
        status: ProductEditorStatus.uploading,
        product: state.product,
        categories: state.categories,
      ),
    );
    try {
      final urls = await _imageUploads.pickAndUpload(
        purpose: purpose,
        maxFiles: maxFiles,
      );
      emit(
        ProductEditorState(
          status: ProductEditorStatus.ready,
          product: state.product,
          categories: state.categories,
          uploadedImageUrls: urls,
        ),
      );
      return urls;
    } catch (error) {
      emit(
        ProductEditorState(
          status: ProductEditorStatus.failure,
          product: state.product,
          categories: state.categories,
          message: error.toString(),
        ),
      );
      return const [];
    }
  }
}
