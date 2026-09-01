import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../catalog/data/models/product_color.dart';
import '../../../catalog/data/models/product_variant.dart';

Future<ProductColor?> showProductColorDialog(
  BuildContext context,
  List<String> images,
) async {
  final name = TextEditingController();
  final hex = TextEditingController(text: '#000000');
  final result = await showDialog<ProductColor>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('add_color'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            decoration: InputDecoration(labelText: 'name'.tr()),
          ),
          TextField(
            controller: hex,
            decoration: InputDecoration(labelText: 'hex_color'.tr()),
          ),
          Text(
            'uploaded_images_count'.tr(
              namedArgs: {'count': '${images.length}'},
            ),
          ),
        ],
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
        title: Text('add_variant'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'color'.tr()),
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
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'size'.tr()),
              items: sizes
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setDialogState(() => sizeId = value),
            ),
            TextField(
              controller: sku,
              decoration: InputDecoration(labelText: 'sku'.tr()),
            ),
            TextField(
              controller: stock,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'stock'.tr()),
            ),
          ],
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
