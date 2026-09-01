import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/badges.dart';
import '../../orders/cubit/order_tracking_cubit.dart';
import '../../orders/cubit/order_tracking_state.dart';
import '../../orders/data/models/commerce_order.dart';
import '../../orders/data/models/order_event.dart';
import '../../shop/presentation/store_header.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
      builder: (context, state) {
        if (state.status == OrderTrackingStatus.loading ||
            state.status == OrderTrackingStatus.initial) {
          return const Scaffold(
            backgroundColor: Colors.white,
            appBar: StoreHeader(),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final order = state.order;
        if (order == null ||
            state.status == OrderTrackingStatus.empty ||
            state.status == OrderTrackingStatus.failure) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const StoreHeader(),
            body: Center(
              child: Text(
                state.message ?? 'Order not found',
                style: AppTypography.bodyLarge,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const StoreHeader(),
          body: SingleChildScrollView(
            child: ResponsiveContentWidth(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTokens.s24),
                    Text(
                      'Order #${order.readableOrderNumber}',
                      style: AppTypography.h2,
                    ),
                    const SizedBox(height: AppTokens.s8),
                    Text(
                      order.createdAt != null
                          ? 'Placed on ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt!)}'
                          : 'Unknown Date',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: AppTokens.s32),
                    ResponsiveLayout(
                      mobile: _buildMobileLayout(context, order),
                      desktop: _buildDesktopLayout(context, order),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, CommerceOrder order) {
    return Column(
      children: [
        _buildTimeline(order),
        const SizedBox(height: AppTokens.s48),
        _buildPaymentSummary(order),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, CommerceOrder order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _buildTimeline(order)),
        const SizedBox(width: AppTokens.s64),
        Expanded(flex: 4, child: _buildPaymentSummary(order)),
      ],
    );
  }

  Widget _buildTimeline(CommerceOrder order) {
    // Generate the timeline based on events
    final events = order.customerTimeline.isNotEmpty
        ? order.customerTimeline
        : [
            OrderEvent(
              type: OrderEventType.orderCreated,
              customerVisible: true,
              timestamp: order.createdAt,
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Status', style: AppTypography.h3),
        const SizedBox(height: AppTokens.s24),
        ...events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == events.length - 1;

          return _buildTimelineStep(
            _formatEventName(event.type),
            event.timestamp != null
                ? DateFormat('MMM dd, hh:mm a').format(event.timestamp!)
                : '',
            isCompleted: !isLast || order.orderStatus.name == 'delivered',
            isCurrent: isLast && order.orderStatus.name != 'delivered',
            isLast: isLast,
          );
        }),
      ],
    );
  }

  String _formatEventName(OrderEventType type) {
    switch (type) {
      case OrderEventType.orderCreated:
        return 'Order Created';
      case OrderEventType.orderConfirmed:
        return 'Order Confirmed';
      case OrderEventType.preparing:
        return 'Preparing';
      case OrderEventType.ready:
        return 'Ready for Pickup / Shipping';
      case OrderEventType.outForDelivery:
        return 'Out for Delivery';
      case OrderEventType.delivered:
        return 'Delivered';
      case OrderEventType.cancelled:
        return 'Cancelled';
      default:
        return type.name;
    }
  }

  Widget _buildTimelineStep(
    String title,
    String subtitle, {
    bool isCompleted = false,
    bool isCurrent = false,
    bool isLast = false,
  }) {
    final color = isCompleted || isCurrent
        ? const Color(0xFF191B1A)
        : Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(top: AppTokens.s4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? Colors.white : color,
                  border: Border.all(color: color, width: isCurrent ? 4 : 0),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color,
                    margin: const EdgeInsets.symmetric(vertical: AppTokens.s4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppTokens.s16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.s32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                      color: isCompleted || isCurrent
                          ? const Color(0xFF191B1A)
                          : Colors.grey.shade400,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: AppTokens.s4),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(CommerceOrder order) {
    final statusBadge = order.paymentStatus.name == 'paid'
        ? StatusBadge.success('Paid')
        : (order.paymentStatus.name == 'partiallyPaid'
              ? StatusBadge.warning('Partially Paid')
              : StatusBadge.error('Pending'));

    return Container(
      padding: const EdgeInsets.all(AppTokens.s24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppTokens.r8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment Status', style: AppTypography.h4),
              statusBadge,
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          _buildSummaryRow(
            'Total',
            '${(order.total / 100).toStringAsFixed(2)} EGP',
          ),
          const SizedBox(height: AppTokens.s12),
          _buildSummaryRow(
            'Paid',
            '${(order.paidAmount / 100).toStringAsFixed(2)} EGP',
          ),
          const SizedBox(height: AppTokens.s12),
          _buildSummaryRow(
            'Remaining',
            '${(order.remainingAmount / 100).toStringAsFixed(2)} EGP',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
