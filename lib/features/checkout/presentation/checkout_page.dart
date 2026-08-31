import 'package:flutter/material.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../shop/presentation/store_header.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

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
                Text('Checkout', style: AppTypography.h2),
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
        _buildCheckoutForm(),
        const SizedBox(height: AppTokens.s48),
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _buildCheckoutForm()),
        const SizedBox(width: AppTokens.s64),
        Expanded(flex: 4, child: _buildOrderSummary()),
      ],
    );
  }

  Widget _buildCheckoutForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Details', style: AppTypography.h3),
        const SizedBox(height: AppTokens.s24),
        const AppTextField(label: 'Full Name'),
        const SizedBox(height: AppTokens.s16),
        const AppTextField(
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppTokens.s16),
        const AppDropdown<String>(
          label: 'Governorate / City',
          items: [
            DropdownMenuItem(value: 'cairo', child: Text('Cairo')),
            DropdownMenuItem(value: 'alex', child: Text('Alexandria')),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        const AppTextField(label: 'Detailed Address', maxLines: 3),
        const SizedBox(height: AppTokens.s16),
        const AppTextField(label: 'Order Notes (Optional)', maxLines: 2),
        const SizedBox(height: AppTokens.s48),
        Text('Payment Method', style: AppTypography.h3),
        const SizedBox(height: AppTokens.s24),
        Container(
          padding: const EdgeInsets.all(AppTokens.s16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF191B1A)),
            borderRadius: BorderRadius.circular(AppTokens.r4),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              const Icon(Icons.money, color: Color(0xFF191B1A)),
              const SizedBox(width: AppTokens.s16),
              Text(
                'Cash on Delivery',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.check_circle, color: Color(0xFF191B1A)),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        _buildPaymentProofUpload(),
      ],
    );
  }

  Widget _buildPaymentProofUpload() {
    return Container(
      padding: const EdgeInsets.all(AppTokens.s24),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(AppTokens.r4),
      ),
      child: Column(
        children: [
          Icon(Icons.upload_file, size: 32, color: Colors.grey.shade400),
          const SizedBox(height: AppTokens.s12),
          Text(
            'Upload Payment Proof (Optional)',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTokens.s8),
          Text(
            'If you paid via Instapay or Bank Transfer, upload the receipt here.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          AppButton(text: 'Select File', onPressed: () {}, isPrimary: false),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
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
            child: AppButton(text: 'CONFIRM ORDER', onPressed: () {}),
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
