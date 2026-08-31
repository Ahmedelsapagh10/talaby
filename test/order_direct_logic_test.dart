import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/cart/data/models/cart_item.dart';
import 'package:new_strucuture/features/orders/data/order_item_resolver.dart';
import 'package:new_strucuture/features/orders/data/order_record_utils.dart';

void main() {
  const resolver = OrderItemResolver();

  test('resolves stored price and decrements stock cumulatively', () {
    final product = <String, dynamic>{
      'active': true,
      'name': 'Stored product',
      'basePrice': 10000,
      'discountType': 'percentage',
      'discountValue': 1000,
      'stock': 5,
      'stockControlEnabled': true,
      'variants': const [],
      'images': const ['https://example.com/product.jpg'],
    };
    const item = CartItem(
      productId: 'p1',
      productName: 'Client name',
      quantity: 2,
      unitPrice: 1,
      discountPerUnit: 0,
    );

    final first = resolver.resolve(item, product);
    final second = resolver.resolve(item, product);

    expect(first.item['unitPrice'], 10000);
    expect(first.item['discountAmount'], 2000);
    expect(first.item['lineTotal'], 18000);
    expect(first.stockUpdate?['stock'], 3);
    expect(second.stockUpdate?['stock'], 1);
  });

  test('rejects a quantity larger than available variant stock', () {
    final product = <String, dynamic>{
      'active': true,
      'name': 'Product',
      'basePrice': 10000,
      'stockControlEnabled': true,
      'variants': [
        {'id': 'v1', 'active': true, 'stock': 1, 'sku': 'SKU-1'},
      ],
    };
    const item = CartItem(
      productId: 'p1',
      productName: 'Product',
      variantId: 'v1',
      quantity: 2,
      unitPrice: 10000,
      discountPerUnit: 0,
    );

    expect(() => resolver.resolve(item, product), throwsStateError);
  });

  test('payment summary preserves partial and pending states', () {
    final summary = calculateOrderPaymentSummary([
      {'status': 'approved', 'confirmedAmount': 500},
      {'status': 'proofSubmitted', 'confirmedAmount': null},
      {'status': 'rejected', 'confirmedAmount': 900},
    ], 1000);

    expect(summary.paid, 500);
    expect(summary.status, 'partiallyPaid');
  });
}
