import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/product_ui.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../catalog/data/models/product.dart';
import '../../shop/presentation/store_header.dart';
import '../cubit/wishlist_cubit.dart';
import '../cubit/wishlist_state.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StoreHeader(),
      body: BlocBuilder<WishlistCubit, WishlistState>(
        builder: (context, state) {
          if (state.status == WishlistStatus.loading) {
            return const LoadingState();
          }
          if (state.status == WishlistStatus.failure &&
              state.products.isEmpty) {
            return ErrorState(
              message: state.message ?? 'wishlist_load_failed'.tr(),
              onRetry: () {},
            );
          }
          if (state.products.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'wishlist_empty'.tr(),
              subtitle: 'wishlist_empty_hint'.tr(),
            );
          }
          return SingleChildScrollView(
            child: ResponsiveContentWidth(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('wishlist'.tr(), style: AppTypography.h2),
                    const SizedBox(height: AppTokens.s24),
                    ResponsiveLayout(
                      mobile: _grid(context, state.products, 2),
                      tablet: _grid(context, state.products, 3),
                      desktop: _grid(context, state.products, 4),
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

  Widget _grid(BuildContext context, List<Product> products, int count) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        mainAxisSpacing: AppTokens.s24,
        crossAxisSpacing: AppTokens.s16,
        childAspectRatio: 0.65,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];
        return ProductCard(
          imageUrl: product.images.first,
          name: product.name,
          price: product.finalPrice / 100,
          isFavorite: true,
          onTap: () => context.push('/product/${product.id}'),
          onFavoriteToggle: () =>
              context.read<WishlistCubit>().toggle(product.id),
        );
      },
    );
  }
}
