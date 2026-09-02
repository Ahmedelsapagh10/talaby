import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../../../core/widgets/app_buttons.dart';
import '../../../catalog/data/models/product_color.dart';
import '../../../catalog/data/models/product_variant.dart';

class ProductOptionsEditor extends StatelessWidget {
  const ProductOptionsEditor({
    super.key,
    required this.images,
    required this.colors,
    required this.variants,
    required this.sizes,
    required this.onUploadImages,
    required this.onRemoveImage,
    required this.onMoveImage,
    required this.onAddColor,
    required this.onRemoveColor,
    required this.onAddVariant,
    required this.onRemoveVariant,
  });

  final List<String> images;
  final List<ProductColor> colors;
  final List<ProductVariant> variants;
  final List<String> sizes;
  final VoidCallback onUploadImages;
  final ValueChanged<String> onRemoveImage;
  final void Function(int index, int offset) onMoveImage;
  final VoidCallback onAddColor;
  final ValueChanged<ProductColor> onRemoveColor;
  final VoidCallback onAddVariant;
  final ValueChanged<ProductVariant> onRemoveVariant;

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
        Text('images_options'.tr(), style: AppTypography.h4),
        const SizedBox(height: AppTokens.s16),
        AppButton(
          text: 'upload_product_images'.tr(),
          isPrimary: false,
          onPressed: onUploadImages,
        ),
        const SizedBox(height: AppTokens.s12),
        ...images.indexed.map(
          (entry) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Image.network(
              entry.$2,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
            title: Text(entry.$2, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Wrap(
              children: [
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.arrowUp),
                  onPressed: () => onMoveImage(entry.$1, -1),
                ),
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.arrowDown),
                  onPressed: () => onMoveImage(entry.$1, 1),
                ),
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.trash),
                  onPressed: () => onRemoveImage(entry.$2),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: AppTokens.s32),
        _Header(title: 'colors'.tr(), onAdd: onAddColor),
        ...colors.map(
          (color) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(backgroundColor: _parseColor(color.hex)),
            title: Text(color.name),
            subtitle: Text(
              '${color.hex} · ${'images_count'.tr(namedArgs: {'count': '${color.imageUrls.length}'})}',
            ),
            trailing: IconButton(
              icon: const Icon(PhosphorIconsRegular.trash),
              onPressed: () => onRemoveColor(color),
            ),
          ),
        ),
        const Divider(height: AppTokens.s32),
        _Header(title: 'variants'.tr(), onAdd: onAddVariant),
        ...variants.map(
          (variant) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(variant.sku.isEmpty ? variant.id : variant.sku),
            subtitle: Text(
              'variant_summary'.tr(
                namedArgs: {
                  'stock': '${variant.stock}',
                  'color': variant.colorId ?? 'no_color'.tr(),
                  'size': variant.sizeId ?? 'no_size'.tr(),
                },
              ),
            ),
            trailing: IconButton(
              icon: const Icon(PhosphorIconsRegular.trash),
              onPressed: () => onRemoveVariant(variant),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onAdd});

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: AppTypography.bodyLarge),
      TextButton.icon(
        onPressed: onAdd,
        icon: const Icon(PhosphorIconsRegular.plus),
        label: Text('add'.tr()),
      ),
    ],
  );
}

Color _parseColor(String value) {
  final normalized = value.replaceAll('#', '');
  return Color(int.tryParse('ff$normalized', radix: 16) ?? 0xff000000);
}
