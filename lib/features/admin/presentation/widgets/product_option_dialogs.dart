import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../../catalog/data/models/product_color.dart';
import '../../../catalog/data/models/product_variant.dart';

const _dialogContentWidth = 400.0;

Future<ProductColor?> showProductColorDialog(
  BuildContext context,
  List<String> images,
) async {
  final name = TextEditingController();
  final hex = TextEditingController(text: '#000000');
  final result = await showDialog<ProductColor>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(AppTokens.s24),
      title: Text('add_color'.tr()),
      content: SizedBox(
        width: _dialogContentWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(label: 'name'.tr(), controller: name),
            const SizedBox(height: AppTokens.s16),
            AppTextField(label: 'hex_color'.tr(), controller: hex),
            const SizedBox(height: AppTokens.s16),
            Text(
              'uploaded_images_count'.tr(
                namedArgs: {'count': '${images.length}'},
              ),
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('cancel'.tr()),
        ),
        FilledButton(
          onPressed: () {
            if (name.text.trim().isEmpty || !_validHex(hex.text)) return;
            Navigator.pop(
              dialogContext,
              ProductColor(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: name.text.trim(),
                hex: hex.text.trim(),
                imageUrls: images,
              ),
            );
          },
          child: Text('add'.tr()),
        ),
      ],
    ),
  );
  name.dispose();
  hex.dispose();
  return result;
}

Future<ProductVariant?> showProductVariantDialog(
  BuildContext context,
  List<ProductColor> colors,
  List<String> sizes,
) async {
  final sku = TextEditingController();
  final stock = TextEditingController(text: '0');
  String? colorId;
  String? sizeId;
  final result = await showDialog<ProductVariant>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (_, setDialogState) => AlertDialog(
        scrollable: true,
        insetPadding: const EdgeInsets.all(AppTokens.s24),
        title: Text('add_variant'.tr()),
        content: SizedBox(
          width: _dialogContentWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDropdown<String>(
                label: 'color'.tr(),
                value: colorId,
                items: colors
                    .map(
                      (value) => DropdownMenuItem(
                        value: value.id,
                        child: Text(value.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setDialogState(() => colorId = value),
              ),
              const SizedBox(height: AppTokens.s16),
              AppDropdown<String>(
                label: 'size'.tr(),
                value: sizeId,
                items: sizes
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setDialogState(() => sizeId = value),
              ),
              const SizedBox(height: AppTokens.s16),
              AppTextField(label: 'sku'.tr(), controller: sku),
              const SizedBox(height: AppTokens.s16),
              AppTextField(
                label: 'stock'.tr(),
                controller: stock,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              ProductVariant(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                colorId: colorId,
                sizeId: sizeId,
                sku: sku.text.trim(),
                stock: int.tryParse(stock.text) ?? 0,
              ),
            ),
            child: Text('add'.tr()),
          ),
        ],
      ),
    ),
  );
  sku.dispose();
  stock.dispose();
  return result;
}

bool _validHex(String value) =>
    RegExp(r'^#?[0-9a-fA-F]{6}$').hasMatch(value.trim());
