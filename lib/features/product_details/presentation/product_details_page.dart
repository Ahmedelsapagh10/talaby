import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/product_ui.dart';
import '../../../../core/widgets/pricing.dart';
import '../../catalog/cubit/product_details_cubit.dart';
import '../../catalog/cubit/product_details_state.dart';
import '../../catalog/data/models/product.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/data/models/cart_item.dart';
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
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          if (state.status == ProductDetailsStatus.loading ||
              state.status == ProductDetailsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProductDetailsStatus.failure) {
            return Center(
              child: Text(
                state.message ?? 'Error loading product',
                style: AppTypography.bodyLarge,
              ),
            );
          }
          final product = state.product;
          if (product == null) {
            return Center(
              child: Text('Product not found', style: AppTypography.bodyLarge),
            );
          }

          return SingleChildScrollView(
            child: ResponsiveContentWidth(
              child: ResponsiveLayout(
                mobile: _buildMobileLayout(context, product),
                desktop: _buildDesktopLayout(context, product),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageGallery(product),
        Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: _buildProductInfo(product),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppTokens.s48,
        horizontal: AppTokens.s16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: _buildImageGallery(product)),
          const SizedBox(width: AppTokens.s48),
          Expanded(flex: 4, child: _buildProductInfo(product)),
        ],
      ),
    );
  }

  Widget _buildImageGallery(Product product) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Colors.grey.shade100,
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              )
            : Center(child: Text('No Image', style: AppTypography.bodyLarge)),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    final originalPrice =
        product.oldPrice != null && product.oldPrice! > product.finalPrice
        ? product.oldPrice!
        : (product.basePrice > product.finalPrice ? product.basePrice : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name, style: AppTypography.h2),
        const SizedBox(height: AppTokens.s16),
        if (originalPrice != null)
          DiscountPrice(
            originalPrice: originalPrice / 100,
            discountedPrice: product.finalPrice / 100,
          )
        else
          PriceText(price: product.finalPrice / 100, isLarge: true),
        const SizedBox(height: AppTokens.s32),

        if (product.colors.isNotEmpty) ...[
          Text(
            'Color',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTokens.s8),
          ColorSelector(
            colors: product.colors
                .map(
                  (c) => Color(int.parse('0xff${c.hex.replaceAll('#', '')}')),
                )
                .toList(),
            selectedColor: _selectedColor,
            onColorSelected: (c) => setState(() => _selectedColor = c),
          ),
          const SizedBox(height: AppTokens.s32),
        ],

        if (product.sizes.isNotEmpty) ...[
          Text(
            'Size',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTokens.s8),
          SizeSelector(
            sizes: product.sizes,
            selectedSize: _selectedSize,
            onSizeSelected: (s) => setState(() => _selectedSize = s),
          ),
          const SizedBox(height: AppTokens.s32),
        ],

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
          child: AppButton(
            text: 'ADD TO CART',
            onPressed: () {
              final cartItem = CartItem(
                productId: product.id,
                productName: product.name,
                quantity: _quantity,
                unitPrice: product.basePrice,
                discountPerUnit: product.oldPrice != null && product.oldPrice! > product.finalPrice 
                  ? product.oldPrice! - product.finalPrice 
                  : product.basePrice - product.finalPrice,
                colorId: product.colors.isNotEmpty ? _selectedColor.toARGB32().toString() : null,
                colorName: product.colors.isNotEmpty 
                  ? product.colors.firstWhere((c) => 
                      Color(int.parse('0xff${c.hex.replaceAll('#', '')}')) == _selectedColor, 
                      orElse: () => product.colors.first
                    ).name
                  : null,
                sizeId: product.sizes.isNotEmpty ? _selectedSize : null,
                imageUrl: product.images.isNotEmpty ? product.images.first : null,
              );
              context.read<CartCubit>().add(cartItem);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} added to cart!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        if (product.description.isNotEmpty)
          Text(
            product.description,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
      ],
    );
  }
}
