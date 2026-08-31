import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/badges.dart';
import '../../shop/presentation/store_header.dart';
import '../cubit/customer_orders_cubit.dart';
import '../cubit/customer_orders_state.dart';
import '../data/models/commerce_order.dart';

class CustomerOrdersPage extends StatelessWidget {
  const CustomerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const StoreHeader(),
      body: BlocBuilder<CustomerOrdersCubit, CustomerOrdersState>(
        builder: (context, state) {
          if (state.status == CustomerOrdersStatus.loading ||
              state.status == CustomerOrdersStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CustomerOrdersStatus.failure) {
            return Center(
              child: Text(
                state.message ?? 'An error occurred loading your orders.',
                style: AppTypography.bodyLarge,
              ),
            );
          }

          if (state.orders.isEmpty || state.status == CustomerOrdersStatus.empty) {
            return Center(
              child: Text(
                'You have no orders yet.',
                style: AppTypography.bodyLarge.copyWith(color: Colors.grey.shade600),
              ),
            );
          }

          return SingleChildScrollView(
            child: ResponsiveContentWidth(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTokens.s24),
                    Text('My Orders', style: AppTypography.h2),
                    const SizedBox(height: AppTokens.s32),
                    ResponsiveLayout(
                      mobile: _buildOrderList(context, state.orders, 1),
                      tablet: _buildOrderList(context, state.orders, 2),
                      desktop: _buildOrderList(context, state.orders, 3),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<CommerceOrder> orders, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppTokens.s16,
        crossAxisSpacing: AppTokens.s16,
        childAspectRatio: 2.5,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, CommerceOrder order) {
    final statusBadge = order.orderStatus.name == 'delivered'
        ? StatusBadge.success('Delivered')
        : (order.orderStatus.name == 'cancelled' ? StatusBadge.error('Cancelled') : StatusBadge.warning('Processing'));

    return GestureDetector(
      onTap: () => context.push(Routes.orderRoute.replaceAll(':id', order.id)),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.s16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTokens.r8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.readableOrderNumber}',
                  style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700),
                ),
                statusBadge,
              ],
            ),
            const SizedBox(height: AppTokens.s8),
            Text(
              order.createdAt != null
                  ? DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt!)
                  : 'Unknown Date',
              style: AppTypography.bodySmall.copyWith(color: Colors.grey.shade500),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} items',
                  style: AppTypography.bodyMedium,
                ),
                Text(
                  '${(order.total / 100).toStringAsFixed(2)} EGP',
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
