import 'package:flutter/material.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/product_ui.dart';
import 'store_header.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const StoreHeader(),
      body: SingleChildScrollView(
        child: ResponsiveContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                height: 400,
                color: Colors.grey.shade100,
                child: Center(
                  child: Text('Minimal Hero Area', style: AppTypography.h2),
                ),
              ),
              const SizedBox(height: AppTokens.s48),

              // Featured Products
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
                child: Text('Featured Products', style: AppTypography.h3),
              ),
              const SizedBox(height: AppTokens.s24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
                child: ResponsiveLayout(
                  mobile: _buildProductGrid(context, 2),
                  tablet: _buildProductGrid(context, 3),
                  desktop: _buildProductGrid(context, 4),
                ),
              ),
              const SizedBox(height: AppTokens.s64),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppTokens.s32,
        crossAxisSpacing: AppTokens.s24,
        childAspectRatio: 0.65, // Adjust based on product card height
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return ProductCard(
          imageUrl: 'https://via.placeholder.com/300x400',
          name: 'Premium Cotton T-Shirt ${index + 1}',
          price: 299.00,
          originalPrice: index % 3 == 0 ? 399.00 : null,
          onTap: () {},
          onFavoriteToggle: () {},
        );
      },
    );
  }
}
