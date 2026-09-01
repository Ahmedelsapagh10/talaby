import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/widgets/app_text_fields.dart';
import 'product_editor_form_sections.dart';
import 'product_form_fields.dart';

class ProductInventoryFields extends StatelessWidget {
  const ProductInventoryFields({
    super.key,
    required this.fields,
    required this.active,
    required this.featured,
    required this.stockControl,
    required this.onActiveChanged,
    required this.onFeaturedChanged,
    required this.onStockControlChanged,
  });

  final ProductFormFields fields;
  final bool active;
  final bool featured;
  final bool stockControl;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onFeaturedChanged;
  final ValueChanged<bool> onStockControlChanged;

  @override
  Widget build(BuildContext context) => ProductFormSection(
    title: 'inventory_visibility'.tr(),
    children: [
      AppTextField(label: 'sku'.tr(), controller: fields.sku),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        label: 'stock'.tr(),
        controller: fields.stock,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        label: 'sizes_comma_separated'.tr(),
        controller: fields.sizes,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('track_stock'.tr()),
        value: stockControl,
        onChanged: onStockControlChanged,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('active'.tr()),
        value: active,
        onChanged: onActiveChanged,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('featured'.tr()),
        value: featured,
        onChanged: onFeaturedChanged,
      ),
    ],
  );
}
