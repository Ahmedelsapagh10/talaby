import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/widgets/app_buttons.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #ORD-10452', style: AppTypography.h2),
              AppButton(text: 'Update Status', onPressed: () {}),
            ],
          ),
          const SizedBox(height: AppTokens.s32),
          ResponsiveLayout(
            mobile: _buildMobileLayout(),
            desktop: _buildDesktopLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCustomerInfo(),
        const SizedBox(height: AppTokens.s24),
        _buildOrderItems(),
        const SizedBox(height: AppTokens.s24),
        _buildFinancialSummary(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderItems(),
              const SizedBox(height: AppTokens.s24),
              _buildFinancialSummary(),
            ],
          ),
        ),
        const SizedBox(width: AppTokens.s48),
        Expanded(flex: 4, child: _buildCustomerInfo()),
      ],
    );
  }

  Widget _buildCustomerInfo() {
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
          Text('Customer', style: AppTypography.h4),
          const SizedBox(height: AppTokens.s16),
          Text(
            'Ahmed Elsapagh',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTokens.s4),
          Text('+20 101 234 5678', style: AppTypography.bodyMedium),
          const SizedBox(height: AppTokens.s16),
          AppButton(
            text: 'Contact via WhatsApp',
            onPressed: () {},
            isPrimary: false,
            icon: Icons.chat_outlined,
          ),
          const SizedBox(height: AppTokens.s24),
          Text('Delivery Address', style: AppTypography.h4),
          const SizedBox(height: AppTokens.s8),
          Text(
            '123 Main Street\nCairo, Egypt',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(AppTokens.r8),
      ),
      padding: const EdgeInsets.all(AppTokens.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items', style: AppTypography.h4),
          const SizedBox(height: AppTokens.s16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            separatorBuilder: (context, index) =>
                const Divider(height: AppTokens.s32),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppTokens.r4),
                    ),
                  ),
                  const SizedBox(width: AppTokens.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium Cotton T-Shirt',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Color: Black | Size: M',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('299.00 EGP x 1', style: AppTypography.bodyMedium),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(AppTokens.s24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.r8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial Summary', style: AppTypography.h4),
          const SizedBox(height: AppTokens.s24),
          _buildSummaryRow('Subtotal', '598.00 EGP'),
          const SizedBox(height: AppTokens.s12),
          _buildSummaryRow('Delivery', '0.00 EGP'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTokens.s16),
            child: Divider(),
          ),
          _buildSummaryRow('Total', '598.00 EGP', isBold: true),
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
