import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/ux_states.dart';
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
          return const Scaffold(appBar: StoreHeader(), body: LoadingState());
        }

        final order = state.order;
        if (order == null ||
            state.status == OrderTrackingStatus.empty ||
            state.status == OrderTrackingStatus.failure) {
          return Scaffold(
            appBar: const StoreHeader(),
            body: EmptyState(
              icon: PhosphorIconsRegular.receipt,
              title: state.message ?? 'Order not found',
            ),
          );
        }

        return Scaffold(
          appBar: const StoreHeader(),
          body: SingleChildScrollView(
            child: ResponsiveContentWidth(
              child: ResponsiveGutter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTokens.s24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTokens.s24),
                      Text(
                        'order_number'.tr(namedArgs: {'number': order.readableOrderNumber}),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppTokens.s8),
                      Text(
                        order.createdAt != null
                            ? 'placed_on'.tr(args: [DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt!)])
                            : 'unknown_date'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, CommerceOrder order) {
    return Column(
      children: [
        _buildTimeline(context, order),
        const SizedBox(height: AppTokens.s48),
        _buildPaymentSummary(context, order),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, CommerceOrder order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _buildTimeline(context, order)),
        const SizedBox(width: AppTokens.s64),
        Expanded(flex: 4, child: _buildPaymentSummary(context, order)),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context, CommerceOrder order) {
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
        Text('order_status_timeline'.tr(), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTokens.s24),
        ...events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == events.length - 1;

          return _buildTimelineStep(
            context,
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
        return 'order_created'.tr();
      case OrderEventType.orderConfirmed:
        return 'order_confirmed'.tr();
      case OrderEventType.preparing:
        return 'preparing'.tr();
      case OrderEventType.ready:
        return 'ready_for_pickup'.tr();
      case OrderEventType.outForDelivery:
        return 'out_for_delivery'.tr();
      case OrderEventType.delivered:
        return 'delivered'.tr();
      case OrderEventType.cancelled:
        return 'cancelled'.tr();
      default:
        return type.name;
    }
  }

  Widget _buildTimelineStep(
    BuildContext context,
    String title,
    String subtitle, {
    bool isCompleted = false,
    bool isCurrent = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final color = isCompleted || isCurrent
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

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
                  color: isCurrent ? theme.colorScheme.surface : color,
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                      color: isCompleted || isCurrent
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: AppTokens.s4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

  Widget _buildPaymentSummary(BuildContext context, CommerceOrder order) {
    final statusBadge = order.paymentStatus.name == 'paid'
        ? StatusBadge.success('paid'.tr())
        : (order.paymentStatus.name == 'partiallyPaid'
              ? StatusBadge.warning('partially_paid'.tr())
              : StatusBadge.error('pending_payment'.tr()));

    return Container(
      padding: const EdgeInsets.all(AppTokens.s24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTokens.r16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'payment_status'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              statusBadge,
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          _buildSummaryRow(
            context,
            'total'.tr(),
            '${(order.total / 100).toStringAsFixed(2)} EGP',
          ),
          const SizedBox(height: AppTokens.s12),
          _buildSummaryRow(
            context,
            'paid'.tr(),
            '${(order.paidAmount / 100).toStringAsFixed(2)} EGP',
          ),
          const SizedBox(height: AppTokens.s12),
          _buildSummaryRow(
            context,
            'remaining'.tr(),
            '${(order.remainingAmount / 100).toStringAsFixed(2)} EGP',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
