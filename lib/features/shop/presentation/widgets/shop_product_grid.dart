import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/widgets/product_ui.dart';
import '../../../auth/presentation/widgets/social_sign_in_dialog.dart';
import '../../../catalog/data/models/product.dart';
import '../../../wishlist/cubit/wishlist_cubit.dart';
import '../../../wishlist/cubit/wishlist_state.dart';
import '../../../product_details/presentation/widgets/product_quick_view_dialog.dart';

class ShopProductGrid extends StatelessWidget {
  const ShopProductGrid({
    super.key,
    required this.products,
    required this.crossAxisCount,
  });

  final List<Product> products;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, wishlist) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppTokens.s32,
          crossAxisSpacing: AppTokens.s24,
          childAspectRatio: 0.65,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final originalPrice = _originalPrice(product);
          return ProductCard(
            imageUrl: product.images.first,
            name: product.name,
            price: product.finalPrice / 100,
            originalPrice: originalPrice == null ? null : originalPrice / 100,
            isFavorite: wishlist.contains(product.id),
            onTap: () => ProductQuickViewDialog.show(context, product),
            onFavoriteToggle: () => _toggle(context, product.id),
          );
        },
      ),
    );
  }

  Future<void> _toggle(BuildContext context, String productId) async {
    if (await requireSocialSignIn(context) && context.mounted) {
      await context.read<WishlistCubit>().toggle(productId);
    }
  }

  int? _originalPrice(Product product) {
    if (product.oldPrice != null && product.oldPrice! > product.finalPrice) {
      return product.oldPrice;
    }
    return product.basePrice > product.finalPrice ? product.basePrice : null;
  }
}
