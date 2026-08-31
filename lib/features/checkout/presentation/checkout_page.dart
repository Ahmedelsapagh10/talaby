import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/cubit/cart_state.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import '../data/models/checkout_details.dart';
import '../../shop/presentation/store_header.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCity = 'Cairo';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    if (_formKey.currentState?.validate() ?? false) {
      final details = CheckoutDetails(
        name: _nameController.text,
        mobile: _phoneController.text,
        city: _selectedCity,
        address: _addressController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      context.read<CheckoutCubit>().submit(details);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state.status == CheckoutStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'An error occurred'), backgroundColor: Colors.red),
          );
        } else if (state.status == CheckoutStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully!'), backgroundColor: Colors.green),
          );
          if (state.orderId != null) {
            context.go(Routes.orderRoute.replaceAll(':id', state.orderId!));
          } else {
            context.go(Routes.initialRoute);
          }
        }
      },
      builder: (context, checkoutState) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const StoreHeader(),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: ResponsiveContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTokens.s16),
                    child: Form(
                      key: _formKey,
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
              ),
              if (checkoutState.status == CheckoutStatus.loading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
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
        AppTextField(
          label: 'Full Name',
          controller: _nameController,
          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your full name' : null,
        ),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          label: 'Phone Number',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your phone number' : null,
        ),
        const SizedBox(height: AppTokens.s16),
        AppDropdown<String>(
          label: 'Governorate / City',
          value: _selectedCity,
          onChanged: (v) {
            if (v != null) setState(() => _selectedCity = v);
          },
          items: const [
            DropdownMenuItem(value: 'Cairo', child: Text('Cairo')),
            DropdownMenuItem(value: 'Alexandria', child: Text('Alexandria')),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          label: 'Detailed Address', 
          maxLines: 3,
          controller: _addressController,
          validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your detailed address' : null,
        ),
        const SizedBox(height: AppTokens.s16),
        AppTextField(
          label: 'Order Notes (Optional)', 
          maxLines: 2,
          controller: _notesController,
        ),
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
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
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
              _buildSummaryRow('Subtotal', '${(state.subtotal / 100).toStringAsFixed(2)} EGP'),
              const SizedBox(height: AppTokens.s12),
              _buildSummaryRow('Delivery', 'To be confirmed', isMuted: true),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppTokens.s16),
                child: Divider(),
              ),
              _buildSummaryRow('Total', '${(state.subtotal / 100).toStringAsFixed(2)} EGP', isBold: true),
              const SizedBox(height: AppTokens.s32),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'CONFIRM ORDER', 
                  onPressed: state.isEmpty ? null : _submitOrder,
                ),
              ),
            ],
          ),
        );
      },
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
