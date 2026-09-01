import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../orders/data/models/order_status.dart';
import '../../orders/data/models/payment_status.dart';
import '../cubit/admin_order_cubit.dart';
import '../cubit/admin_order_state.dart';
import 'widgets/admin_order_list.dart';

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminOrderCubit, AdminOrderState>(
      builder: (context, state) {
        if (state.status == AdminOrderStatus.loading && state.orders.isEmpty) {
          return const LoadingState();
        }
        if (state.status == AdminOrderStatus.failure && state.orders.isEmpty) {
          return ErrorState(
            message: state.message ?? 'load_failed'.tr(),
            onRetry: context.read<AdminOrderCubit>().load,
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('overview'.tr(), style: AppTypography.h2),
              const SizedBox(height: AppTokens.s8),
              Text(
                'overview_subtitle'.tr(),
                style: AppTypography.bodySmall.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: AppTokens.s24),
              _Metrics(state: state),
              const SizedBox(height: AppTokens.s32),
              Text('orders'.tr(), style: AppTypography.h3),
              const SizedBox(height: AppTokens.s16),
              if (state.orders.isEmpty)
                SizedBox(
                  height: 220,
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'no_orders'.tr(),
                  ),
                )
              else
                AdminOrdersTable(
                  orders: state.orders.take(5).toList(),
                  onOpen: (id) => context.push('/admin/orders/$id'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.state});

  final AdminOrderState state;

  @override
  Widget build(BuildContext context) {
    int count(OrderStatus status) =>
        state.orders.where((order) => order.orderStatus == status).length;
    final awaitingPayment = state.orders
        .where((order) => order.paymentStatus == PaymentStatus.proofSubmitted)
        .length;
    return Wrap(
      spacing: AppTokens.s16,
      runSpacing: AppTokens.s16,
      children: [
        _Metric(label: 'pending'.tr(), value: count(OrderStatus.pending)),
        _Metric(label: 'preparing'.tr(), value: count(OrderStatus.preparing)),
        _Metric(
          label: 'out_for_delivery'.tr(),
          value: count(OrderStatus.outForDelivery),
        ),
        _Metric(label: 'delivered'.tr(), value: count(OrderStatus.delivered)),
        _Metric(
          label: 'payment_proofs'.tr(),
          value: awaitingPayment,
          alert: true,
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.alert = false});

  final String label;
  final int value;
  final bool alert;

  @override
  Widget build(BuildContext context) => Container(
    width: 180,
    padding: const EdgeInsets.all(AppTokens.s20),
    decoration: BoxDecoration(
      color: alert ? Colors.orange.shade50 : Colors.white,
      border: Border.all(
        color: alert ? Colors.orange.shade200 : Colors.grey.shade200,
      ),
      borderRadius: BorderRadius.circular(AppTokens.r8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: AppTypography.h3),
        const SizedBox(height: AppTokens.s4),
        Text(label, style: AppTypography.bodySmall),
      ],
    ),
  );
}
