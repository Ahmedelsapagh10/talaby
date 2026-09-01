import '../../../../../core/config/app_config.dart';
import '../../../catalog/data/models/discount.dart';
import '../../../catalog/data/models/product.dart';
import '../../../catalog/data/models/product_color.dart';
import '../../../catalog/data/models/product_variant.dart';
import 'product_form_fields.dart';

List<String> parseProductSizes(String value) => value
    .split(',')
    .map((item) => item.trim())
    .where((item) => item.isNotEmpty)
    .toSet()
    .toList();

String? validateProductForm({
  required ProductFormFields fields,
  required String? categoryId,
  required DiscountType discountType,
  required List<String> images,
  required List<ProductColor> colors,
  required List<ProductVariant> variants,
}) {
  if (categoryId == null || images.isEmpty) return 'choose_category_image';
  final price = double.tryParse(fields.price.text.trim()) ?? 0;
  final oldPrice = double.tryParse(fields.oldPrice.text.trim());
  if (oldPrice != null && oldPrice <= price) return 'invalid_old_price';
  final discount = double.tryParse(fields.discount.text.trim()) ?? 0;
  if (discountType == DiscountType.percentage &&
      (discount <= 0 || discount > 100)) {
    return 'invalid_discount';
  }
  if (discountType == DiscountType.fixed &&
      (discount <= 0 || discount >= price)) {
    return 'invalid_discount';
  }
  if ((int.tryParse(fields.stock.text.trim()) ?? 0) < 0) {
    return 'invalid_stock';
  }
  final colorIds = colors.map((color) => color.id).toSet();
  final sizes = parseProductSizes(fields.sizes.text).toSet();
  final combinations = <String>{};
  for (final variant in variants) {
    final combination = '${variant.colorId ?? ''}|${variant.sizeId ?? ''}';
    final referencesUnknownOption =
        (variant.colorId != null && !colorIds.contains(variant.colorId)) ||
        (variant.sizeId != null && !sizes.contains(variant.sizeId));
    if (variant.sku.trim().isEmpty ||
        variant.stock < 0 ||
        (variant.colorId == null && variant.sizeId == null) ||
        referencesUnknownOption ||
        !combinations.add(combination)) {
      return 'invalid_variant';
    }
  }
  return null;
}

Product mapProductForm({
  required ProductFormFields fields,
  required Product? current,
  required String categoryId,
  required DiscountType discountType,
  required List<String> images,
  required List<ProductColor> colors,
  required List<ProductVariant> variants,
  required bool active,
  required bool featured,
  required bool stockControl,
}) {
  final basePrice = _minorUnits(fields.price.text);
  final oldPrice = fields.oldPrice.text.trim().isEmpty
      ? null
      : _minorUnits(fields.oldPrice.text);
  final discountValue = discountType == DiscountType.percentage
      ? ((double.tryParse(fields.discount.text) ?? 0) * 100).round()
      : _minorUnits(fields.discount.text);
  return Product(
    id: current?.id ?? '',
    ownerId: current?.ownerId ?? AppConfig.ownerId,
    name: fields.name.text.trim(),
    shortDescription: fields.shortDescription.text.trim(),
    description: fields.description.text.trim(),
    images: images,
    categoryId: categoryId,
    basePrice: basePrice,
    oldPrice: oldPrice,
    discount: ProductDiscount(type: discountType, value: discountValue),
    colors: colors,
    sizes: parseProductSizes(fields.sizes.text),
    variants: variants,
    stock: int.tryParse(fields.stock.text) ?? 0,
    sku: fields.sku.text.trim(),
    active: active,
    featured: featured,
    stockControlEnabled: stockControl,
    averageRating: current?.averageRating ?? 0,
    reviewsCount: current?.reviewsCount ?? 0,
    createdAt: current?.createdAt,
    updatedAt: current?.updatedAt,
  );
}

int _minorUnits(String value) =>
    ((double.tryParse(value.trim()) ?? 0) * 100).round();
