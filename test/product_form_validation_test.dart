import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/admin/presentation/widgets/product_editor_mapper.dart';
import 'package:new_strucuture/features/admin/presentation/widgets/product_form_fields.dart';
import 'package:new_strucuture/features/catalog/data/models/discount.dart';
import 'package:new_strucuture/features/catalog/data/models/product_color.dart';
import 'package:new_strucuture/features/catalog/data/models/product_variant.dart';

void main() {
  late ProductFormFields fields;

  setUp(() {
    fields = ProductFormFields();
    fields.price.text = '100';
    fields.stock.text = '5';
  });

  tearDown(() => fields.dispose());

  String? validate({
    DiscountType discountType = DiscountType.none,
    List<ProductColor> colors = const [],
    List<ProductVariant> variants = const [],
  }) {
    return validateProductForm(
      fields: fields,
      categoryId: 'category-1',
      discountType: discountType,
      images: const ['https://example.com/product.jpg'],
      colors: colors,
      variants: variants,
    );
  }

  test('rejects an old price lower than the current price', () {
    fields.oldPrice.text = '90';
    expect(validate(), 'invalid_old_price');
  });

  test('rejects percentage discounts greater than 100', () {
    fields.discount.text = '101';
    expect(validate(discountType: DiscountType.percentage), 'invalid_discount');
  });

  test('rejects duplicate variant combinations', () {
    const colors = [ProductColor(id: 'red', name: 'Red', hex: '#ff0000')];
    const variants = [
      ProductVariant(id: '1', sku: 'RED-1', stock: 2, colorId: 'red'),
      ProductVariant(id: '2', sku: 'RED-2', stock: 2, colorId: 'red'),
    ];
    expect(validate(colors: colors, variants: variants), 'invalid_variant');
  });

  test('accepts a valid product form', () {
    expect(validate(), isNull);
  });
}
