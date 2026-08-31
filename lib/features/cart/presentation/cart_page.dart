import 'package:flutter/material.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/pricing.dart';
import '../../../../core/widgets/product_ui.dart';
import '../../shop/presentation/store_header.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

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
                Text('Shopping Cart', style: AppTypography.h2),
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
        _buildCartItems(),
        const SizedBox(height: AppTokens.s48),
        _buildSummary(),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _buildCartItems()),
        const SizedBox(width: AppTokens.s48),
        Expanded(flex: 4, child: _buildSummary()),
      ],
    );
  }

  Widget _buildCartItems() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      separatorBuilder: (context, index) =>
          Divider(height: AppTokens.s48, color: Colors.grey.shade200),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppTokens.r8),
              ),
            ),
            const SizedBox(width: AppTokens.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Premium Cotton T-Shirt',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconActionButton(icon: Icons.close, onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s4),
                  Text(
                    'Color: Black',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Size: M',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: AppTokens.s12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuantitySelector(quantity: 1, onQuantityChanged: (_) {}),
                      const PriceText(price: 299.00),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummary() {
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
          Text('Order Summary', style: AppTypography.h4),
          const SizedBox(height: AppTokens.s24),
          _buildSummaryRow('Subtotal', '598.00 EGP'),
          const SizedBox(height: AppTokens.s12),
          _buildSummaryRow('Delivery', 'To be confirmed', isMuted: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTokens.s16),
            child: Divider(),
          ),
          _buildSummaryRow('Total', '598.00 EGP', isBold: true),
          const SizedBox(height: AppTokens.s32),
          SizedBox(
            width: double.infinity,
            child: AppButton(text: 'PROCEED TO CHECKOUT', onPressed: () {}),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isMuted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isMuted ? Colors.grey.shade500 : const Color(0xFF191B1A),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isMuted ? Colors.grey.shade500 : const Color(0xFF191B1A),
          ),
        ),
      ],
    );
  }
}
