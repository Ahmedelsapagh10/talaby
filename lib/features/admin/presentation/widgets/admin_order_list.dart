import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../../../core/widgets/badges.dart';
import '../../../../../core/widgets/pricing.dart';
import '../../../orders/data/models/commerce_order.dart';
import '../../../orders/data/models/order_status.dart';
import '../../../orders/data/models/payment_status.dart';

class AdminOrdersTable extends StatelessWidget {
  const AdminOrdersTable({
    super.key,
    required this.orders,
    required this.onOpen,
  });

  final List<CommerceOrder> orders;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(AppTokens.r8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('order'.tr())),
            DataColumn(label: Text('customer'.tr())),
            DataColumn(label: Text('total'.tr())),
            DataColumn(label: Text('status'.tr())),
            DataColumn(label: Text('payment'.tr())),
            DataColumn(label: Text('date'.tr())),
          ],
          rows: orders.map((order) {
            return DataRow(
              onSelectChanged: (_) => onOpen(order.id),
              cells: [
                DataCell(Text(order.readableOrderNumber)),
                DataCell(Text('${order.customerName}\n${order.phone}')),
                DataCell(PriceText(price: order.total / 100)),
                DataCell(orderStatusBadge(order.orderStatus)),
                DataCell(paymentStatusBadge(order.paymentStatus)),
                DataCell(Text(_date(order.createdAt))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class AdminOrderCards extends StatelessWidget {
  const AdminOrderCards({
    super.key,
    required this.orders,
    required this.onOpen,
  });

  final List<CommerceOrder> orders;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
      itemBuilder: (_, index) {
        final order = orders[index];
        return Card(
          child: ListTile(
            onTap: () => onOpen(order.id),
            title: Text(order.readableOrderNumber, style: AppTypography.h4),
            subtitle: Text('${order.customerName}\n${_date(order.createdAt)}'),
            trailing: orderStatusBadge(order.orderStatus),
          ),
        );
      },
    );
  }
}

String orderStatusLabel(OrderStatus status) => switch (status) {
  OrderStatus.pending => 'pending'.tr(),
  OrderStatus.confirmed => 'confirmed'.tr(),
  OrderStatus.preparing => 'preparing'.tr(),
  OrderStatus.ready => 'ready'.tr(),
  OrderStatus.outForDelivery => 'out_for_delivery'.tr(),
  OrderStatus.delivered => 'delivered'.tr(),
  OrderStatus.cancelled => 'cancelled'.tr(),
  OrderStatus.returned => 'returned'.tr(),
};

Widget orderStatusBadge(OrderStatus status) => switch (status) {
  OrderStatus.delivered => StatusBadge.success(orderStatusLabel(status)),
  OrderStatus.cancelled ||
  OrderStatus.returned => StatusBadge.error(orderStatusLabel(status)),
  OrderStatus.pending => StatusBadge.warning(orderStatusLabel(status)),
  _ => StatusBadge.info(orderStatusLabel(status)),
};

Widget paymentStatusBadge(PaymentStatus status) => switch (status) {
  PaymentStatus.paid => StatusBadge.success('paid'.tr()),
  PaymentStatus.unpaid => StatusBadge.error('unpaid'.tr()),
  PaymentStatus.rejected => StatusBadge.error('rejected'.tr()),
  PaymentStatus.proofSubmitted => StatusBadge.warning('proof_submitted'.tr()),
  PaymentStatus.partiallyPaid => StatusBadge.info('partially_paid'.tr()),
};

String _date(DateTime? value) {
  return value == null ? '—' : DateFormat.yMMMd().format(value);
}
