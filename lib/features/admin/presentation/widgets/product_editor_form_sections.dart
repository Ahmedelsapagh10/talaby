import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../../../core/widgets/app_text_fields.dart';
import '../../../catalog/data/models/category.dart';
import '../../../catalog/data/models/discount.dart';
import 'product_form_fields.dart';

class ProductBasicFields extends StatelessWidget {
  const ProductBasicFields({
    super.key,
    required this.fields,
    required this.categories,
    required this.categoryId,
    required this.onCategoryChanged,
  });

  final ProductFormFields fields;
  final List<Category> categories;
  final String? categoryId;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) => ProductFormSection(
    title: 'basic_information'.tr(),
    children: [
      AppTextField(
        label: 'name'.tr(),
        controller: fields.name,
        validator: _required,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        label: 'short_description'.tr(),
        controller: fields.shortDescription,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        label: 'description'.tr(),
        controller: fields.description,
        maxLines: 5,
      ),
      const SizedBox(height: AppTokens.s16),
      AppDropdown<String>(
        label: 'category'.tr(),
        value: categoryId,
        onChanged: onCategoryChanged,
        items: categories
            .map(
              (value) =>
                  DropdownMenuItem(value: value.id, child: Text(value.name)),
            )
            .toList(),
      ),
    ],
  );
}

class ProductPricingFields extends StatelessWidget {
  const ProductPricingFields({
    super.key,
    required this.fields,
    required this.discountType,
    required this.onDiscountTypeChanged,
  });

  final ProductFormFields fields;
  final DiscountType discountType;
  final ValueChanged<DiscountType> onDiscountTypeChanged;

  @override
  Widget build(BuildContext context) => ProductFormSection(
    title: 'pricing'.tr(),
    children: [
      AppTextField(
        label: 'price_egp'.tr(),
        controller: fields.price,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: _positive,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        label: 'old_price_optional'.tr(),
        controller: fields.oldPrice,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: AppTokens.s16),
      AppDropdown<DiscountType>(
        label: 'discount_type'.tr(),
        value: discountType,
        onChanged: (value) {
          if (value != null) onDiscountTypeChanged(value);
        },
        items: DiscountType.values
            .map(
              (value) =>
                  DropdownMenuItem(value: value, child: Text(value.name.tr())),
            )
            .toList(),
      ),
      if (discountType != DiscountType.none) ...[
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          label:
              (discountType == DiscountType.percentage
                      ? 'discount_percentage'
                      : 'discount_egp')
                  .tr(),
          controller: fields.discount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    ],
  );
}

class ProductFormSection extends StatelessWidget {
  const ProductFormSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 900),
    padding: const EdgeInsets.all(AppTokens.s24),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(AppTokens.r8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h4),
        const SizedBox(height: AppTokens.s20),
        ...children,
      ],
    ),
  );
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'required_field'.tr() : null;

String? _positive(String? value) =>
    (double.tryParse(value ?? '') ?? 0) <= 0 ? 'amount_positive'.tr() : null;
