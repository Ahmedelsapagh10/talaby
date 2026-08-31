import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/badges.dart';

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: AppTypography.h2),
          const SizedBox(height: AppTokens.s32),
          Wrap(
            spacing: AppTokens.s16,
            runSpacing: AppTokens.s16,
            children: [
              _buildMetricCard('New Orders', '12', Icons.fiber_new_outlined),
              _buildMetricCard('Preparing', '5', Icons.kitchen_outlined),
              _buildMetricCard(
                'Out for Delivery',
                '8',
                Icons.local_shipping_outlined,
              ),
              _buildMetricCard(
                'Delivered Today',
                '24',
                Icons.check_circle_outline,
              ),
              _buildMetricCard(
                'Payment Proofs Waiting',
                '3',
                Icons.receipt_long_outlined,
                isAlert: true,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s48),
          Text('Recent Orders', style: AppTypography.h3),
          const SizedBox(height: AppTokens.s24),
          _buildRecentOrdersTable(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon, {
    bool isAlert = false,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppTokens.s24),
      decoration: BoxDecoration(
        color: isAlert ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.r8),
        border: Border.all(
          color: isAlert ? Colors.orange.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isAlert ? Colors.orange.shade800 : Colors.grey.shade600,
          ),
          const SizedBox(height: AppTokens.s16),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: isAlert ? Colors.orange.shade900 : const Color(0xFF191B1A),
            ),
          ),
          const SizedBox(height: AppTokens.s4),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: isAlert ? Colors.orange.shade800 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(AppTokens.r8),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.all(AppTokens.s16),
            title: Text(
              '#ORD-1045$index',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Ahmed Elsapagh',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusBadge.warning('Pending'),
                const SizedBox(width: AppTokens.s16),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          );
        },
      ),
    );
  }
}
