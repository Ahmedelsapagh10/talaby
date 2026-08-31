import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/product_ui.dart';
import '../../auth/presentation/widgets/social_sign_in_dialog.dart';
import '../../catalog/cubit/products_cubit.dart';
import '../../catalog/cubit/products_state.dart';
import '../../catalog/data/models/product.dart';
import 'store_header.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const StoreHeader(),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state.status == ProductsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = state.products.where(_hasVisibleData).toList();
          if (products.isEmpty) return const SizedBox.shrink();
          return SingleChildScrollView(
            child: ResponsiveContentWidth(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.s16,
                  AppTokens.s48,
                  AppTokens.s16,
                  AppTokens.s64,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Featured Products', style: AppTypography.h3),
                    const SizedBox(height: AppTokens.s24),
                    ResponsiveLayout(
                      mobile: _buildProductGrid(context, products, 2),
                      tablet: _buildProductGrid(context, products, 3),
                      desktop: _buildProductGrid(context, products, 4),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _hasVisibleData(Product product) {
    return product.id.isNotEmpty &&
        product.name.trim().isNotEmpty &&
        product.finalPrice > 0 &&
        product.images.any((image) => image.trim().isNotEmpty);
  }

  Widget _buildProductGrid(
    BuildContext context,
    List<Product> products,
    int crossAxisCount,
  ) {
    return GridView.builder(
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
          imageUrl: product.images.firstWhere(
            (image) => image.trim().isNotEmpty,
          ),
          name: product.name,
          price: product.finalPrice / 100,
          originalPrice: originalPrice == null ? null : originalPrice / 100,
          onTap: () => context.push('/product/${product.id}'),
          onFavoriteToggle: () async {
            await requireSocialSignIn(context);
          },
        );
      },
    );
  }

  int? _originalPrice(Product product) {
    if (product.oldPrice != null && product.oldPrice! > product.finalPrice) {
      return product.oldPrice;
    }
    return product.basePrice > product.finalPrice ? product.basePrice : null;
  }
}
