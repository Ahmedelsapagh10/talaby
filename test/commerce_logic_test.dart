import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/utils/money_calculator.dart';
import 'package:new_strucuture/features/catalog/data/models/discount.dart';
import 'package:new_strucuture/features/catalog/data/models/product.dart';
import 'package:new_strucuture/features/catalog/data/models/product_variant.dart';
import 'package:new_strucuture/features/orders/data/models/order_status.dart';
import 'package:new_strucuture/features/orders/data/models/payment_record.dart';
import 'package:new_strucuture/features/orders/data/models/payment_status.dart';

void main() {
  group('money calculations use integer minor units', () {
    test('percentage discount uses basis points', () {
      expect(MoneyCalculator.percentageDiscount(150000, 2500), 37500);
    });

    test('fixed discount cannot exceed the amount', () {
      expect(MoneyCalculator.fixedDiscount(1000, 1200), 1000);
    });

    test('subtotal and delivery fee are calculated safely', () {
      final result = MoneyCalculator.calculate(
        lineTotals: const [100000, 50000],
        discount: 10000,
        deliveryFee: 15000,
        paid: 50000,
      );
      expect(result.subtotal, 150000);
      expect(result.total, 155000);
      expect(result.remaining, 105000);
    });

    test('delivery fee recalculates the remaining amount', () {
      final before = MoneyCalculator.calculate(
        lineTotals: const [1000],
        paid: 500,
      );
      final after = MoneyCalculator.calculate(
        lineTotals: const [1000],
        deliveryFee: 100,
        paid: 500,
      );
      expect(before.remaining, 500);
      expect(after.remaining, 600);
    });

    test('remaining can never be negative', () {
      final result = MoneyCalculator.calculate(
        lineTotals: const [1000],
        paid: 1500,
      );
      expect(result.remaining, 0);
    });
  });

  group('product pricing and stock', () {
    test('product applies percentage discount', () {
      const product = Product(
        id: 'p1',
        ownerId: 'owner',
        name: 'Product',
        basePrice: 10000,
        discount: ProductDiscount(type: DiscountType.percentage, value: 1250),
      );
      expect(product.finalPrice, 8750);
    });

    test('product applies fixed discount', () {
      const product = Product(
        id: 'p1',
        ownerId: 'owner',
        name: 'Product',
        basePrice: 10000,
        discount: ProductDiscount(type: DiscountType.fixed, value: 1500),
      );
      expect(product.finalPrice, 8500);
    });

    test('variant validates active stock', () {
      const variant = ProductVariant(id: 'v1', sku: 'SKU-1', stock: 2);
      expect(variant.canFulfill(2), isTrue);
      expect(variant.canFulfill(3), isFalse);
    });
  });

  group('payment history', () {
    PaymentRecord payment(
      String id,
      PaymentRecordStatus status, {
      int? confirmed,
    }) => PaymentRecord(
      id: id,
      proofUrl: 'https://example.com/$id.jpg',
      claimedAmount: 50000,
      confirmedAmount: confirmed,
      status: status,
    );

    test('partial payment sums approved confirmed amounts only', () {
      final total = PaymentCalculator.approvedTotal([
        payment('1', PaymentRecordStatus.approved, confirmed: 50000),
      ]);
      expect(total, 50000);
      expect(
        MoneyCalculator.calculate(
          lineTotals: const [150000],
          paid: total,
        ).remaining,
        100000,
      );
    });

    test('full payment has zero remaining', () {
      final total = PaymentCalculator.approvedTotal([
        payment('1', PaymentRecordStatus.approved, confirmed: 150000),
      ]);
      expect(
        MoneyCalculator.calculate(
          lineTotals: const [150000],
          paid: total,
        ).remaining,
        0,
      );
    });

    test('multiple approved payments are accumulated', () {
      final total = PaymentCalculator.approvedTotal([
        payment('1', PaymentRecordStatus.approved, confirmed: 50000),
        payment('2', PaymentRecordStatus.approved, confirmed: 25000),
        payment('3', PaymentRecordStatus.approved, confirmed: 75000),
      ]);
      expect(total, 150000);
    });

    test('rejected and pending payments are ignored', () {
      final total = PaymentCalculator.approvedTotal([
        payment('1', PaymentRecordStatus.rejected, confirmed: 90000),
        payment('2', PaymentRecordStatus.proofSubmitted),
      ]);
      expect(total, 0);
    });
  });

  test('status enums serialize and deserialize without magic strings', () {
    expect(OrderStatus.outForDelivery.value, 'outForDelivery');
    expect(
      OrderStatusCodec.fromValue('outForDelivery'),
      OrderStatus.outForDelivery,
    );
    expect(
      PaymentStatusCodec.fromValue('partiallyPaid'),
      PaymentStatus.partiallyPaid,
    );
  });
}
