import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../../../core/widgets/pricing.dart';
import '../../../../core/widgets/product_ui.dart';
import '../../../checkout/cubit/checkout_cubit.dart';
import '../../../checkout/cubit/checkout_state.dart';
import '../../../checkout/data/models/checkout_details.dart';
import '../../cubit/cart_cubit.dart';
import '../../cubit/cart_state.dart';
import '../../data/models/cart_item.dart';
import '../../../../injector.dart';

class CartCheckoutDialog extends StatefulWidget {
  const CartCheckoutDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r16),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
          child: BlocProvider(
            create: (_) => serviceLocator<CheckoutCubit>(),
            child: const CartCheckoutDialog(),
          ),
        ),
      ),
    );
  }

  @override
  State<CartCheckoutDialog> createState() => _CartCheckoutDialogState();
}

class _CartCheckoutDialogState extends State<CartCheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill from profile if available
    final profile = context.read<CheckoutCubit>().state.profile;
    if (profile != null) {
      _name.text = profile.name;
      _phone.text = profile.phone;
      _address.text = profile.defaultAddress;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listener: (context, checkoutState) {
        if (checkoutState.status == CheckoutStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text((checkoutState.message ?? 'checkout_failed').tr())),
          );
        }
        if (checkoutState.status == CheckoutStatus.success) {
          context.read<CartCubit>().clear();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('order_placed_successfully'.tr())),
          );
        }
      },
      builder: (context, checkoutState) {
        return Stack(
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(AppTokens.s24),
                    color: Colors.grey.shade50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart_outlined),
                            const SizedBox(width: AppTokens.s8),
                            Text('shopping_cart'.tr(), style: AppTypography.h4),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppTokens.s24),
                      child: BlocBuilder<CartCubit, CartState>(
                        builder: (context, cartState) {
                          if (cartState.items.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 48),
                                child: Text('cart_empty_hint'.tr(), style: AppTypography.bodyLarge),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Cart Items
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cartState.items.length,
                                separatorBuilder: (_, __) => const Divider(height: AppTokens.s32),
                                itemBuilder: (context, index) {
                                  return _buildCartItem(context, cartState.items[index]);
                                },
                              ),
                              const SizedBox(height: AppTokens.s24),
                              
                              // Total
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('total'.tr(), style: AppTypography.h4),
                                  Text(
                                    '${(cartState.subtotal / 100).toStringAsFixed(2)} EGP',
                                    style: AppTypography.h4.copyWith(color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                              
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: AppTokens.s24),
                                child: Divider(),
                              ),

                              // Checkout Form
                              Text('checkout_details'.tr(), style: AppTypography.h4),
                              const SizedBox(height: AppTokens.s16),
                              
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    AppTextField(
                                      controller: _name,
                                      label: 'name'.tr(),
                                      validator: (v) => v?.trim().isEmpty == true ? 'required_field'.tr() : null,
                                    ),
                                    const SizedBox(height: AppTokens.s16),
                                    AppTextField(
                                      controller: _phone,
                                      label: 'phone'.tr(),
                                      keyboardType: TextInputType.phone,
                                      validator: (v) => v?.trim().isEmpty == true ? 'required_field'.tr() : null,
                                    ),
                                    const SizedBox(height: AppTokens.s16),
                                    AppTextField(
                                      controller: _address,
                                      label: 'address'.tr(),
                                      validator: (v) => v?.trim().isEmpty == true ? 'required_field'.tr() : null,
                                    ),
                                    const SizedBox(height: AppTokens.s16),
                                    AppTextField(
                                      controller: _notes,
                                      label: 'notes'.tr(),
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: AppTokens.s32),
                              
                              // Submit Button
                              AppButton(
                                text: 'complete_order'.tr(), // "إتمام الطلب"
                                isLoading: checkoutState.status == CheckoutStatus.loading,
                                onPressed: () {
                                  if (!(_formKey.currentState?.validate() ?? false)) return;
                                  
                                  context.read<CheckoutCubit>().submit(
                                    CheckoutDetails(
                                      name: _name.text,
                                      mobile: _phone.text,
                                      city: 'N/A', // Bypassing city requirement
                                      address: _address.text,
                                      notes: _notes.text.trim().isEmpty ? null : _notes.text,
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Loading Overlay
            if (checkoutState.status == CheckoutStatus.loading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black26,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppTokens.r8),
          ),
          child: item.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                )
              : const Icon(Icons.image, color: Colors.grey),
        ),
        const SizedBox(width: AppTokens.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTokens.s8),
              PriceText(price: item.lineTotal / 100),
              const SizedBox(height: AppTokens.s8),
              Row(
                children: [
                  QuantitySelector(
                    quantity: item.quantity,
                    onQuantityChanged: (q) => context.read<CartCubit>().updateQuantity(item.key, q),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => context.read<CartCubit>().remove(item.key),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
