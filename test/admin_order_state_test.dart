import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/admin/cubit/admin_order_state.dart';
import 'package:new_strucuture/features/orders/data/models/commerce_order.dart';
import 'package:new_strucuture/features/orders/data/models/order_status.dart';
import 'package:new_strucuture/features/orders/data/models/payment_status.dart';

void main() {
  CommerceOrder order({
    required String id,
    required String number,
    required String customer,
    required OrderStatus status,
  }) {
    return CommerceOrder(
      id: id,
      readableOrderNumber: number,
      ownerId: 'owner',
      customerId: 'customer-$id',
      customerName: customer,
      phone: '010$id',
      city: 'Cairo',
      address: 'Address',
      items: const [],
      subtotal: 100,
      discountAmount: 0,
      total: 100,
      paidAmount: 0,
      remainingAmount: 100,
      paymentStatus: PaymentStatus.unpaid,
      orderStatus: status,
    );
  }

  test('filters orders by status and normalized query', () {
    final state = AdminOrderState(
      status: AdminOrderStatus.success,
      orders: [
        order(
          id: '1',
          number: 'ORD-1001',
          customer: 'Ahmed',
          status: OrderStatus.pending,
        ),
        order(
          id: '2',
          number: 'ORD-1002',
          customer: 'Mona',
          status: OrderStatus.delivered,
        ),
      ],
      query: 'ahmed',
      statusFilter: OrderStatus.pending,
    );

    expect(state.visibleOrders.map((value) => value.id), ['1']);
  });

  test('copyWith can clear the status filter', () {
    const state = AdminOrderState(statusFilter: OrderStatus.pending);
    expect(state.copyWith(clearStatus: true).statusFilter, isNull);
  });
}
