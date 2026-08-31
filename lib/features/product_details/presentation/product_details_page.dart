import 'package:flutter/material.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/product_ui.dart';
import '../../../../core/widgets/pricing.dart';
import '../../shop/presentation/store_header.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Color _selectedColor = Colors.black;
  String _selectedSize = 'M';
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const StoreHeader(),
      body: SingleChildScrollView(
        child: ResponsiveContentWidth(
          child: ResponsiveLayout(
            mobile: _buildMobileLayout(context),
            desktop: _buildDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageGallery(),
        Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: _buildProductInfo(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppTokens.s48,
        horizontal: AppTokens.s16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: _buildImageGallery()),
          const SizedBox(width: AppTokens.s48),
          Expanded(flex: 4, child: _buildProductInfo()),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Text('Product Image', style: AppTypography.bodyLarge),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Premium Cotton T-Shirt', style: AppTypography.h2),
        const SizedBox(height: AppTokens.s16),
        const DiscountPrice(originalPrice: 399.00, discountedPrice: 299.00),
        const SizedBox(height: AppTokens.s32),
        Text(
          'Color',
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppTokens.s8),
        ColorSelector(
          colors: const [Colors.black, Colors.white, Colors.blueGrey],
          selectedColor: _selectedColor,
          onColorSelected: (c) => setState(() => _selectedColor = c),
        ),
        const SizedBox(height: AppTokens.s32),
        Text(
          'Size',
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppTokens.s8),
        SizeSelector(
          sizes: const ['S', 'M', 'L', 'XL'],
          selectedSize: _selectedSize,
          onSizeSelected: (s) => setState(() => _selectedSize = s),
        ),
        const SizedBox(height: AppTokens.s32),
        Text(
          'Quantity',
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppTokens.s8),
        QuantitySelector(
          quantity: _quantity,
          onQuantityChanged: (q) => setState(() => _quantity = q),
        ),
        const SizedBox(height: AppTokens.s48),
        SizedBox(
          width: double.infinity,
          child: AppButton(text: 'ADD TO CART', onPressed: () {}),
        ),
        const SizedBox(height: AppTokens.s16),
        Text(
          'Crafted from 100% premium organic cotton, this t-shirt offers a relaxed fit and ultimate comfort for everyday wear.',
          style: AppTypography.bodyMedium.copyWith(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
