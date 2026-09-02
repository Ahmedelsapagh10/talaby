import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/design_system/responsive.dart';
import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../../../core/widgets/app_buttons.dart';
import '../../../../../core/widgets/pricing.dart';
import '../../../../../core/widgets/product_ui.dart';
import '../../../auth/presentation/widgets/social_sign_in_dialog.dart';
import '../../../catalog/data/models/product.dart';
import '../../../wishlist/cubit/wishlist_cubit.dart';
import '../../../wishlist/cubit/wishlist_state.dart';
import 'product_reviews_section.dart';

class ProductDetailsContent extends StatelessWidget {
  const ProductDetailsContent({
    super.key,
    required this.product,
    required this.selectedColorId,
    required this.selectedSize,
    required this.quantity,
    required this.onColorChanged,
    required this.onSizeChanged,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  final Product product;
  final String? selectedColorId;
  final String? selectedSize;
  final int quantity;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<String> onSizeChanged;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ResponsiveContentWidth(
        child: ResponsiveGutter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTokens.s32),
            child: Column(
              children: [
                ResponsiveLayout(
                  mobile: Column(
                    children: [
                      _gallery(),
                      const SizedBox(height: AppTokens.s24),
                      _info(context),
                    ],
                  ),
                  desktop: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _gallery()),
                      const SizedBox(width: AppTokens.s48),
                      Expanded(flex: 4, child: _info(context)),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.s48),
                ProductReviewsSection(product: product),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gallery() {
    final imageUrl = product.images.isEmpty ? '' : product.images.first;
    return AspectRatio(
      aspectRatio: 1,
      child: Builder(
        builder: (context) => ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: imageUrl.isEmpty
              ? const Icon(PhosphorIconsRegular.imageBroken)
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) =>
                      const Icon(PhosphorIconsRegular.imageBroken),
                ),
        ),
      ),
    );
  }

  Widget _info(BuildContext context) {
    final originalPrice =
        product.oldPrice != null && product.oldPrice! > product.finalPrice
        ? product.oldPrice
        : (product.basePrice > product.finalPrice ? product.basePrice : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            BlocBuilder<WishlistCubit, WishlistState>(
              builder: (context, state) => IconButton(
                icon: Icon(
                  state.contains(product.id)
                      ? PhosphorIconsFill.heart
                      : PhosphorIconsRegular.heart,
                  color: state.contains(product.id)
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
                onPressed: () => _toggleFavorite(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s12),
        if (originalPrice != null)
          DiscountPrice(
            originalPrice: originalPrice / 100,
            discountedPrice: product.finalPrice / 100,
          )
        else
          PriceText(price: product.finalPrice / 100, isLarge: true),
        const SizedBox(height: AppTokens.s24),
        if (product.colors.isNotEmpty) ...[
          Text('color'.tr(), style: AppTypography.bodyLarge),
          const SizedBox(height: AppTokens.s8),
          Wrap(
            spacing: AppTokens.s8,
            children: product.colors.map((color) {
              final selected = color.id == selectedColorId;
              return ChoiceChip(
                label: Text(color.name),
                selected: selected,
                onSelected: (_) => onColorChanged(color.id),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTokens.s24),
        ],
        if (product.sizes.isNotEmpty) ...[
          Text('size'.tr(), style: AppTypography.bodyLarge),
          const SizedBox(height: AppTokens.s8),
          SizeSelector(
            sizes: product.sizes,
            selectedSize: selectedSize,
            onSizeSelected: onSizeChanged,
          ),
          const SizedBox(height: AppTokens.s24),
        ],
        QuantitySelector(
          quantity: quantity,
          onQuantityChanged: onQuantityChanged,
        ),
        const SizedBox(height: AppTokens.s24),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            text: 'add_to_cart'.tr(),
            icon: PhosphorIconsRegular.bag,
            variant: AppButtonVariant.accent,
            onPressed: onAddToCart,
          ),
        ),
        if (product.description.isNotEmpty) ...[
          const SizedBox(height: AppTokens.s24),
          Text(product.description, style: AppTypography.bodyMedium),
        ],
      ],
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    if (await requireSocialSignIn(context) && context.mounted) {
      await context.read<WishlistCubit>().toggle(product.id);
    }
  }
}
