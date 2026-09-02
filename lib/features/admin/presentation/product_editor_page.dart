import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/widgets/ux_states.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../catalog/data/models/discount.dart';
import '../../catalog/data/models/product.dart';
import '../../catalog/data/models/product_color.dart';
import '../../catalog/data/models/product_variant.dart';
import '../cubit/product_editor_cubit.dart';
import '../cubit/product_editor_state.dart';
import 'widgets/product_editor_content.dart';
import 'widgets/product_editor_mapper.dart';
import 'widgets/product_form_fields.dart';
import 'widgets/product_option_dialogs.dart';

class ProductEditorPage extends StatefulWidget {
  const ProductEditorPage({super.key});

  @override
  State<ProductEditorPage> createState() => _ProductEditorPageState();
}

class _ProductEditorPageState extends State<ProductEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final fields = ProductFormFields();
  String? _categoryId;
  DiscountType _discountType = DiscountType.none;
  bool _active = true;
  bool _featured = false;
  bool _stockControl = true;
  List<String> _images = [];
  List<ProductColor> _colors = [];
  List<ProductVariant> _variants = [];
  bool _initialized = false;

  @override
  void dispose() {
    fields.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductEditorCubit, ProductEditorState>(
      listener: _listen,
      builder: (context, state) {
        if (state.status == ProductEditorStatus.loading) {
          return const LoadingState();
        }
        if (state.status == ProductEditorStatus.failure && !_initialized) {
          return ErrorState(
            message: 'load_product_failed'.tr(),
            onRetry: context.read<ProductEditorCubit>().load,
          );
        }
        _initialize(state.product);
        return Form(
          key: _formKey,
          child: ProductEditorContent(
            isEditing: state.product != null,
            status: state.status,
            fields: fields,
            categories: state.categories,
            categoryId: _categoryId,
            discountType: _discountType,
            active: _active,
            featured: _featured,
            stockControl: _stockControl,
            images: _images,
            colors: _colors,
            variants: _variants,
            onCategoryChanged: (value) => setState(() => _categoryId = value),
            onDiscountTypeChanged: (value) =>
                setState(() => _discountType = value),
            onActiveChanged: (value) => setState(() => _active = value),
            onFeaturedChanged: (value) => setState(() => _featured = value),
            onStockControlChanged: (value) =>
                setState(() => _stockControl = value),
            onUploadImages: _uploadImages,
            onRemoveImage: (value) => setState(() => _images.remove(value)),
            onMoveImage: _moveImage,
            onAddColor: _addColor,
            onRemoveColor: (value) => setState(() => _colors.remove(value)),
            onAddVariant: _addVariant,
            onRemoveVariant: (value) => setState(() => _variants.remove(value)),
            onSave: _save,
          ),
        );
      },
    );
  }

  List<String> get _sizes => parseProductSizes(fields.sizes.text);

  void _initialize(Product? product) {
    if (_initialized) return;
    _initialized = true;
    fields.fill(product);
    if (product == null) return;
    _categoryId = product.categoryId;
    _discountType = product.discount.type;
    _active = product.active;
    _featured = product.featured;
    _stockControl = product.stockControlEnabled;
    _images = [...product.images];
    _colors = [...product.colors];
    _variants = [...product.variants];
  }

  void _listen(BuildContext context, ProductEditorState state) {
    if (state.status == ProductEditorStatus.success) {
      context.go('/admin/products');
    }
    if (state.status == ProductEditorStatus.failure && _initialized) {
      AppToast.error(context, state.message ?? 'save_product_failed'.tr());
    }
  }

  Future<void> _uploadImages() async {
    final urls = await context.read<ProductEditorCubit>().uploadProductImages();
    if (mounted) setState(() => _images = [..._images, ...urls]);
  }

  void _moveImage(int from, int offset) {
    final to = from + offset;
    if (to < 0 || to >= _images.length) return;
    setState(() {
      final value = _images.removeAt(from);
      _images.insert(to, value);
    });
  }

  Future<void> _addColor() async {
    final images = await context.read<ProductEditorCubit>().uploadColorImages();
    if (!mounted) return;
    final color = await showProductColorDialog(context, images);
    if (color != null) setState(() => _colors.add(color));
  }

  Future<void> _addVariant() async {
    final variant = await showProductVariantDialog(context, _colors, _sizes);
    if (variant != null) setState(() => _variants.add(variant));
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final validationKey = validateProductForm(
      fields: fields,
      categoryId: _categoryId,
      discountType: _discountType,
      images: _images,
      colors: _colors,
      variants: _variants,
    );
    if (validationKey != null) {
      AppToast.error(context, validationKey.tr());
      return;
    }
    final current = context.read<ProductEditorCubit>().state.product;
    context.read<ProductEditorCubit>().save(
      mapProductForm(
        fields: fields,
        current: current,
        categoryId: _categoryId!,
        discountType: _discountType,
        images: _images,
        colors: _colors,
        variants: _variants,
        active: _active,
        featured: _featured,
        stockControl: _stockControl,
      ),
    );
  }
}
