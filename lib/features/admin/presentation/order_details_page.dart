import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../orders/cubit/order_tracking_cubit.dart';
import '../../orders/cubit/order_tracking_state.dart';
import '../../orders/data/models/commerce_order.dart';
import '../../orders/data/models/order_status.dart';
import '../cubit/admin_order_cubit.dart';
import '../cubit/admin_order_state.dart';
import 'widgets/admin_order_details_sections.dart';
import 'widgets/admin_payment_review.dart';
import 'widgets/admin_order_list.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminOrderCubit, AdminOrderState>(
      listenWhen: (before, current) =>
          current.status == AdminOrderStatus.failure &&
          before.message != current.message,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message ?? 'update_order_failed'.tr())),
      ),
      child: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
        builder: (context, state) {
          if (state.status == OrderTrackingStatus.loading) {
            return const LoadingState();
          }
          if (state.status == OrderTrackingStatus.failure) {
            return ErrorState(
              message: 'load_order_failed'.tr(),
              onRetry: () {},
            );
          }
          final order = state.order;
          if (order == null) {
            return EmptyState(
              icon: PhosphorIconsRegular.receipt,
              title: 'order_not_found'.tr(),
            );
          }
          return _OrderBody(order: order);
        },
      ),
    );
  }
}

class _OrderBody extends StatelessWidget {
  const _OrderBody({required this.order});

  final CommerceOrder order;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: AppTokens.s32),
              ResponsiveLayout(
                mobile: _mobile(context),
                desktop: _desktop(context),
              ),
            ],
          ),
        ),
        BlocSelector<AdminOrderCubit, AdminOrderState, bool>(
          selector: (state) => state.isUpdating,
          builder: (_, updating) => updating
              ? Positioned.fill(
                  child: ColoredBox(
                    color: Theme.of(
                      context,
                    ).colorScheme.scrim.withValues(alpha: 0.18),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Wrap(
      spacing: AppTokens.s16,
      runSpacing: AppTokens.s12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(order.readableOrderNumber, style: AppTypography.h2),
        orderStatusBadge(order.orderStatus),
        PopupMenuButton<OrderStatus>(
          tooltip: 'update_status'.tr(),
          onSelected: (status) =>
              context.read<AdminOrderCubit>().updateStatus(order.id, status),
          itemBuilder: (_) => OrderStatus.values
              .map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Text(orderStatusLabel(status)),
                ),
              )
              .toList(),
          child: Chip(label: Text('update_status'.tr())),
        ),
      ],
    );
  }

  Widget _mobile(BuildContext context) => Column(
    children: [
      AdminCustomerCard(order: order),
      const SizedBox(height: AppTokens.s24),
      AdminOrderItems(order: order),
      const SizedBox(height: AppTokens.s24),
      AdminFinancialCard(order: order),
      const SizedBox(height: AppTokens.s24),
      AdminPaymentReview(order: order),
    ],
  );

  Widget _desktop(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 6,
        child: Column(
          children: [
            AdminOrderItems(order: order),
            const SizedBox(height: AppTokens.s24),
            AdminPaymentReview(order: order),
          ],
        ),
      ),
      const SizedBox(width: AppTokens.s32),
      Expanded(
        flex: 4,
        child: Column(
          children: [
            AdminCustomerCard(order: order),
            const SizedBox(height: AppTokens.s24),
            AdminFinancialCard(order: order),
          ],
        ),
      ),
    ],
  );
}
