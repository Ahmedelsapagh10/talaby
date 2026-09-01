import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/pricing.dart';
import '../../../../core/widgets/product_ui.dart';
import '../../auth/presentation/widgets/social_sign_in_dialog.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../data/models/cart_item.dart';
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
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    return ResponsiveLayout(
                      mobile: _buildMobileLayout(context, state),
                      desktop: _buildDesktopLayout(context, state),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, CartState state) {
    return Column(
      children: [
        _buildCartItems(state.items),
        const SizedBox(height: AppTokens.s48),
        _buildSummary(context, state),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, CartState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _buildCartItems(state.items)),
        const SizedBox(width: AppTokens.s48),
        Expanded(flex: 4, child: _buildSummary(context, state)),
      ],
    );
  }

  Widget _buildCartItems(List<CartItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Text('Your cart is empty', style: AppTypography.bodyLarge),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          Divider(height: AppTokens.s48, color: Colors.grey.shade200),
      itemBuilder: (context, index) {
        final item = items[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 120,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppTokens.r8),
              ),
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
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
                          item.productName,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconActionButton(
                        icon: Icons.close,
                        onPressed: () =>
                            context.read<CartCubit>().remove(item.key),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s4),
                  if (item.colorName != null)
                    Text(
                      'Color: ${item.colorName}',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (item.sizeId != null)
                    Text(
                      'Size: ${item.sizeId}',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: AppTokens.s12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuantitySelector(
                        quantity: item.quantity,
                        onQuantityChanged: (q) => context
                            .read<CartCubit>()
                            .updateQuantity(item.key, q),
                      ),
                      PriceText(price: item.lineTotal / 100),
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

  Widget _buildSummary(BuildContext context, CartState state) {
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
          _buildSummaryRow(
            'Subtotal',
            '${(state.subtotal / 100).toStringAsFixed(2)} EGP',
          ),
          const SizedBox(height: AppTokens.s12),
          _buildSummaryRow('Delivery', 'To be confirmed', isMuted: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTokens.s16),
            child: Divider(),
          ),
          _buildSummaryRow(
            'Total',
            '${(state.subtotal / 100).toStringAsFixed(2)} EGP',
            isBold: true,
          ),
          const SizedBox(height: AppTokens.s32),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'PROCEED TO CHECKOUT',
              onPressed: state.isEmpty
                  ? null
                  : () async {
                      final signedIn = await requireSocialSignIn(context);
                      if (signedIn && context.mounted) {
                        context.push(Routes.checkoutRoute);
                      }
                    },
            ),
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
