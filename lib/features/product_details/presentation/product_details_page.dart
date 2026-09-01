import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/widgets/ux_states.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/data/models/cart_item.dart';
import '../../catalog/cubit/product_details_cubit.dart';
import '../../catalog/cubit/product_details_state.dart';
import '../../catalog/data/models/product.dart';
import '../../catalog/data/models/product_color.dart';
import '../../catalog/data/models/product_variant.dart';
import '../../shop/presentation/store_header.dart';
import 'widgets/product_details_content.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String? _colorId;
  String? _size;
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
            return const LoadingState();
          }
          if (state.status == ProductDetailsStatus.failure) {
            return ErrorState(
              message: 'load_product_failed'.tr(),
              onRetry: () {},
            );
          }
          final product = state.product;
          if (product == null) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'product_not_found'.tr(),
            );
          }
          final colorId =
              _colorId ??
              (product.colors.isEmpty ? null : product.colors.first.id);
          final size =
              _size ?? (product.sizes.isEmpty ? null : product.sizes.first);
          return ProductDetailsContent(
            product: product,
            selectedColorId: colorId,
            selectedSize: size,
            quantity: _quantity,
            onColorChanged: (value) => setState(() => _colorId = value),
            onSizeChanged: (value) => setState(() => _size = value),
            onQuantityChanged: (value) => setState(() => _quantity = value),
            onAddToCart: () => _addToCart(product, colorId, size),
          );
        },
      ),
    );
  }

  void _addToCart(Product product, String? colorId, String? size) {
    ProductColor? color;
    for (final value in product.colors) {
      if (value.id == colorId) color = value;
    }
    ProductVariant? variant;
    for (final value in product.variants) {
      if (value.colorId == colorId && value.sizeId == size) variant = value;
    }
    final colorImages = color?.imageUrls ?? const <String>[];
    context.read<CartCubit>().add(
      CartItem(
        productId: product.id,
        productName: product.name,
        variantId: variant?.id,
        quantity: _quantity,
        unitPrice: product.basePrice,
        discountPerUnit: product.basePrice - product.finalPrice,
        colorId: colorId,
        colorName: color?.name,
        sizeId: size,
        imageUrl: colorImages.isNotEmpty
            ? colorImages.first
            : (product.images.isEmpty ? null : product.images.first),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'add_to_cart_success'.tr(namedArgs: {'name': product.name}),
        ),
      ),
    );
  }
}
