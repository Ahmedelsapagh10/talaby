import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../../../core/widgets/app_buttons.dart';
import '../../../catalog/data/models/category.dart';
import '../../../catalog/data/models/discount.dart';
import '../../../catalog/data/models/product_color.dart';
import '../../../catalog/data/models/product_variant.dart';
import '../../cubit/product_editor_state.dart';
import 'product_editor_form_sections.dart';
import 'product_editor_mapper.dart';
import 'product_form_fields.dart';
import 'product_inventory_fields.dart';
import 'product_options_editor.dart';

class ProductEditorContent extends StatelessWidget {
  const ProductEditorContent({
    super.key,
    required this.isEditing,
    required this.status,
    required this.fields,
    required this.categories,
    required this.categoryId,
    required this.discountType,
    required this.active,
    required this.featured,
    required this.stockControl,
    required this.images,
    required this.colors,
    required this.variants,
    required this.onCategoryChanged,
    required this.onDiscountTypeChanged,
    required this.onActiveChanged,
    required this.onFeaturedChanged,
    required this.onStockControlChanged,
    required this.onUploadImages,
    required this.onRemoveImage,
    required this.onMoveImage,
    required this.onAddColor,
    required this.onRemoveColor,
    required this.onAddVariant,
    required this.onRemoveVariant,
    required this.onSave,
  });

  final bool isEditing;
  final ProductEditorStatus status;
  final ProductFormFields fields;
  final List<Category> categories;
  final String? categoryId;
  final DiscountType discountType;
  final bool active;
  final bool featured;
  final bool stockControl;
  final List<String> images;
  final List<ProductColor> colors;
  final List<ProductVariant> variants;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<DiscountType> onDiscountTypeChanged;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onFeaturedChanged;
  final ValueChanged<bool> onStockControlChanged;
  final Future<void> Function() onUploadImages;
  final ValueChanged<String> onRemoveImage;
  final void Function(int index, int offset) onMoveImage;
  final Future<void> Function() onAddColor;
  final ValueChanged<ProductColor> onRemoveColor;
  final Future<void> Function() onAddVariant;
  final ValueChanged<ProductVariant> onRemoveVariant;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(AppTokens.s24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditing ? 'edit_product'.tr() : 'new_product'.tr(),
          style: AppTypography.h2,
        ),
        const SizedBox(height: AppTokens.s24),
        ProductBasicFields(
          fields: fields,
          categories: categories,
          categoryId: categoryId,
          onCategoryChanged: onCategoryChanged,
        ),
        const SizedBox(height: AppTokens.s24),
        ProductPricingFields(
          fields: fields,
          discountType: discountType,
          onDiscountTypeChanged: onDiscountTypeChanged,
        ),
        const SizedBox(height: AppTokens.s24),
        ProductInventoryFields(
          fields: fields,
          active: active,
          featured: featured,
          stockControl: stockControl,
          onActiveChanged: onActiveChanged,
          onFeaturedChanged: onFeaturedChanged,
          onStockControlChanged: onStockControlChanged,
        ),
        const SizedBox(height: AppTokens.s24),
        ProductOptionsEditor(
          images: images,
          colors: colors,
          variants: variants,
          sizes: parseProductSizes(fields.sizes.text),
          onUploadImages: onUploadImages,
          onRemoveImage: onRemoveImage,
          onMoveImage: onMoveImage,
          onAddColor: onAddColor,
          onRemoveColor: onRemoveColor,
          onAddVariant: onAddVariant,
          onRemoveVariant: onRemoveVariant,
        ),
        const SizedBox(height: AppTokens.s32),
        AppButton(
          text: 'save_product'.tr(),
          isLoading: status == ProductEditorStatus.saving,
          onPressed: onSave,
        ),
      ],
    ),
  );
}
