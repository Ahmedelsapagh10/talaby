import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../orders/data/models/order_status.dart';
import '../cubit/admin_order_cubit.dart';
import '../cubit/admin_order_state.dart';
import 'widgets/admin_order_list.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminOrderCubit, AdminOrderState>(
      builder: (context, state) {
        return ResponsiveContentWidth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'orders'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTokens.s24),
                _OrderFilters(state: state),
                const SizedBox(height: AppTokens.s24),
                _content(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, AdminOrderState state) {
    if (state.status == AdminOrderStatus.loading && state.orders.isEmpty) {
      return const SizedBox(height: 360, child: LoadingState());
    }
    if (state.status == AdminOrderStatus.failure && state.orders.isEmpty) {
      return SizedBox(
        height: 360,
        child: ErrorState(
          message: 'load_orders_failed'.tr(),
          onRetry: context.read<AdminOrderCubit>().load,
        ),
      );
    }
    if (state.visibleOrders.isEmpty) {
      return SizedBox(
        height: 320,
        child: EmptyState(
          icon: PhosphorIconsRegular.shoppingBag,
          title: 'no_orders_found'.tr(),
        ),
      );
    }
    return Column(
      children: [
        ResponsiveLayout(
          mobile: AdminOrderCards(
            orders: state.visibleOrders,
            onOpen: (id) => context.push('/admin/orders/$id'),
          ),
          desktop: AdminOrdersTable(
            orders: state.visibleOrders,
            onOpen: (id) => context.push('/admin/orders/$id'),
          ),
        ),
        if (state.hasMore) ...[
          const SizedBox(height: AppTokens.s24),
          AppButton(
            text: 'load_more'.tr(),
            variant: AppButtonVariant.secondary,
            onPressed: context.read<AdminOrderCubit>().loadMore,
          ),
        ],
      ],
    );
  }
}

class _OrderFilters extends StatelessWidget {
  const _OrderFilters({required this.state});

  final AdminOrderState state;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Column(
        children: [
          _search(context),
          const SizedBox(height: AppTokens.s12),
          _status(context),
        ],
      ),
      desktop: Row(
        children: [
          Expanded(flex: 2, child: _search(context)),
          const SizedBox(width: AppTokens.s16),
          Expanded(child: _status(context)),
        ],
      ),
    );
  }

  Widget _search(BuildContext context) => AppTextField(
    label: '',
    hint: 'search_orders'.tr(),
    onChanged: context.read<AdminOrderCubit>().setQuery,
  );

  Widget _status(BuildContext context) => AppDropdown<OrderStatus?>(
    label: '',
    value: state.statusFilter,
    onChanged: context.read<AdminOrderCubit>().setStatusFilter,
    items: [
      DropdownMenuItem(value: null, child: Text('all_statuses'.tr())),
      ...OrderStatus.values.map(
        (status) => DropdownMenuItem(
          value: status,
          child: Text(orderStatusLabel(status)),
        ),
      ),
    ],
  );
}
