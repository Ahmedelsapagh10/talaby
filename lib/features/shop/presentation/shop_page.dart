import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../catalog/cubit/products_cubit.dart';
import '../../catalog/cubit/products_state.dart';
import '../../catalog/data/models/product.dart';
import 'store_header.dart';
import 'widgets/shop_hero_banner.dart';
import 'widgets/shop_product_grid.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const StoreHeader(),
      body: SingleChildScrollView(
        child: ResponsiveContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s16,
              AppTokens.s24,
              AppTokens.s16,
              AppTokens.s64,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShopHeroBanner(),
                Text('products'.tr(), style: AppTypography.h3),
                const SizedBox(height: AppTokens.s24),
                const _ProductsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.status == ProductsStatus.loading ||
            state.status == ProductsStatus.initial) {
          return const SizedBox(height: 300, child: LoadingState());
        }
        if (state.status == ProductsStatus.failure) {
          return SizedBox(
            height: 300,
            child: ErrorState(
              message: 'products_load_failed'.tr(),
              onRetry: context.read<ProductsCubit>().load,
            ),
          );
        }
        final products = state.products.where(_hasVisibleData).toList();
        if (products.isEmpty) {
          return SizedBox(
            height: 300,
            child: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'no_products_found'.tr(),
            ),
          );
        }
        return ResponsiveLayout(
          mobile: ShopProductGrid(products: products, crossAxisCount: 2),
          tablet: ShopProductGrid(products: products, crossAxisCount: 3),
          desktop: ShopProductGrid(products: products, crossAxisCount: 4),
        );
      },
    );
  }

  bool _hasVisibleData(Product product) =>
      product.id.isNotEmpty &&
      product.name.trim().isNotEmpty &&
      product.finalPrice > 0 &&
      product.images.any((image) => image.trim().isNotEmpty);
}
