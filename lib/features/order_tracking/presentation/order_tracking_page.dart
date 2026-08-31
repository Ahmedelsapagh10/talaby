import 'package:flutter/material.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/badges.dart';

import '../../shop/presentation/store_header.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                Text('Order #ORD-10452', style: AppTypography.h2),
                const SizedBox(height: AppTokens.s8),
                Text(
                  'Placed on Oct 24, 2026',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: AppTokens.s32),
                ResponsiveLayout(
                  mobile: _buildMobileLayout(context),
                  desktop: _buildDesktopLayout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildTimeline(),
        const SizedBox(height: AppTokens.s48),
        _buildPaymentSummary(),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _buildTimeline()),
        const SizedBox(width: AppTokens.s64),
        Expanded(flex: 4, child: _buildPaymentSummary()),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Status', style: AppTypography.h3),
        const SizedBox(height: AppTokens.s24),
        _buildTimelineStep('Confirmed', 'Oct 24, 10:00 AM', isCompleted: true),
        _buildTimelineStep('Preparing', 'Oct 24, 11:30 AM', isCompleted: true),
        _buildTimelineStep(
          'Ready',
          'Oct 25, 09:00 AM',
          isCompleted: true,
          isCurrent: true,
        ),
        _buildTimelineStep('Out for Delivery', '', isCompleted: false),
        _buildTimelineStep('Delivered', '', isCompleted: false, isLast: true),
      ],
    );
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

  Widget _buildPaymentSummary() {
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
              StatusBadge.warning('Pending'),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          _buildSummaryRow('Total', '598.00 EGP'),
          const SizedBox(height: AppTokens.s12),
          _buildSummaryRow('Paid', '0.00 EGP'),
          const SizedBox(height: AppTokens.s12),
          _buildSummaryRow('Remaining', '598.00 EGP', isBold: true),
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
