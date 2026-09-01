import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/design_system/responsive.dart';
import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../../../core/widgets/app_buttons.dart';
import '../../../../../core/widgets/app_text_fields.dart';
import '../../../cart/cubit/cart_cubit.dart';
import '../../../cart/cubit/cart_state.dart';

class CheckoutSections extends StatelessWidget {
  const CheckoutSections({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.cityController,
    required this.addressController,
    required this.notesController,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final TextEditingController addressController;
  final TextEditingController notesController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: AppTokens.s24),
      Text('checkout'.tr(), style: AppTypography.h2),
      const SizedBox(height: AppTokens.s32),
      ResponsiveLayout(
        mobile: Column(
          children: [
            _form(),
            const SizedBox(height: AppTokens.s32),
            CheckoutOrderSummary(onSubmit: onSubmit),
          ],
        ),
        desktop: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _form()),
            const SizedBox(width: AppTokens.s48),
            Expanded(flex: 4, child: CheckoutOrderSummary(onSubmit: onSubmit)),
          ],
        ),
      ),
    ],
  );

  Widget _form() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('delivery_details'.tr(), style: AppTypography.h3),
      const SizedBox(height: AppTokens.s20),
      AppTextField(
        label: 'full_name'.tr(),
        controller: nameController,
        validator: _required,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        label: 'phone_number'.tr(),
        controller: phoneController,
        keyboardType: TextInputType.phone,
        validator: _required,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        label: 'governorate_city'.tr(),
        controller: cityController,
        validator: _required,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        label: 'detailed_address'.tr(),
        controller: addressController,
        maxLines: 3,
        validator: _required,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(
        label: 'order_notes_optional'.tr(),
        controller: notesController,
        maxLines: 2,
      ),
      const SizedBox(height: AppTokens.s32),
      Text('payment_method'.tr(), style: AppTypography.h3),
      const SizedBox(height: AppTokens.s16),
      ListTile(
        leading: const Icon(Icons.money),
        title: Text('cash_on_delivery'.tr()),
        trailing: const Icon(Icons.check_circle),
      ),
      ListTile(
        leading: const Icon(Icons.upload_file),
        title: Text('payment_after_order'.tr()),
      ),
    ],
  );
}

class CheckoutOrderSummary extends StatelessWidget {
  const CheckoutOrderSummary({super.key, required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) => Container(
        padding: const EdgeInsets.all(AppTokens.s24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppTokens.r8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('order_summary'.tr(), style: AppTypography.h4),
            const SizedBox(height: AppTokens.s20),
            _row('subtotal'.tr(), state.subtotal),
            const SizedBox(height: AppTokens.s12),
            Text('delivery_fee_later'.tr()),
            const Divider(height: AppTokens.s32),
            _row('total_before_delivery'.tr(), state.subtotal, bold: true),
            const SizedBox(height: AppTokens.s24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'confirm_order'.tr(),
                onPressed: state.isEmpty ? null : onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, int amount, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: bold ? AppTypography.h4 : AppTypography.bodyMedium),
      Text('${(amount / 100).toStringAsFixed(2)} EGP'),
    ],
  );
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'required_field'.tr() : null;
