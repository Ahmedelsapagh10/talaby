import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
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
            message: 'load_failed'.tr(),
            onRetry: context.read<AdminOrderCubit>().load,
          );
        }
        return ResponsiveContentWidth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'overview'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTokens.s8),
                Text(
                  'overview_subtitle'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppTokens.s24),
                _Metrics(state: state),
                const SizedBox(height: AppTokens.s32),
                Text(
                  'orders'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTokens.s16),
                if (state.orders.isEmpty)
                  SizedBox(
                    height: 220,
                    child: EmptyState(
                      icon: PhosphorIconsRegular.receipt,
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
    final metrics = [
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
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 5
            : constraints.maxWidth >= 700
            ? 3
            : constraints.maxWidth >= 380
            ? 2
            : 1;
        final width =
            (constraints.maxWidth - AppTokens.s16 * (columns - 1)) / columns;
        return Wrap(
          spacing: AppTokens.s16,
          runSpacing: AppTokens.s16,
          children: metrics
              .map((metric) => SizedBox(width: width, child: metric))
              .toList(),
        );
      },
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
    padding: const EdgeInsets.all(AppTokens.s20),
    decoration: BoxDecoration(
      color: alert
          ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
          : Theme.of(context).colorScheme.tertiary.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.12
                  : 0.45,
            ),
      border: Border.all(
        color: alert
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).dividerColor,
      ),
      borderRadius: BorderRadius.circular(AppTokens.r16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTokens.s4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
