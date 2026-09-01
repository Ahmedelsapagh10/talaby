import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/pricing.dart';
import '../../../../core/widgets/product_ui.dart';
import '../../../catalog/data/models/product.dart';
import '../../../cart/cubit/cart_cubit.dart';
import '../../../cart/data/models/cart_item.dart';

class ProductQuickViewDialog extends StatefulWidget {
  const ProductQuickViewDialog({super.key, required this.product});

  final Product product;

  static Future<void> show(BuildContext context, Product product) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r16),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ProductQuickViewDialog(product: product),
        ),
      ),
    );
  }

  @override
  State<ProductQuickViewDialog> createState() => _ProductQuickViewDialogState();
}

class _ProductQuickViewDialogState extends State<ProductQuickViewDialog> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.product.images.isNotEmpty;
    
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          if (hasImages)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: widget.product.images.first,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
              ),
            )
          else
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: Colors.black12,
                child: Icon(Icons.image, size: 48, color: Colors.black26),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppTokens.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: AppTypography.h3,
                ),
                const SizedBox(height: AppTokens.s8),
                if (widget.product.oldPrice != null && widget.product.oldPrice! > widget.product.finalPrice)
                  DiscountPrice(
                    originalPrice: widget.product.oldPrice! / 100,
                    discountedPrice: widget.product.finalPrice / 100,
                  )
                else
                  PriceText(
                    price: widget.product.finalPrice / 100,
                  ),
                const SizedBox(height: AppTokens.s24),
                
                // Quantity
                Row(
                  children: [
                    Text('quantity'.tr(), style: AppTypography.bodyMedium),
                    const Spacer(),
                    QuantitySelector(
                      quantity: _quantity,
                      onQuantityChanged: (val) {
                        setState(() {
                          _quantity = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'close'.tr(),
                        isPrimary: false,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppTokens.s16),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: 'add_to_cart'.tr(),
                        onPressed: () {
                          _addToCart(context);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final item = CartItem(
      productId: widget.product.id,
      productName: widget.product.name,
      quantity: _quantity,
      unitPrice: widget.product.basePrice,
      discountPerUnit: widget.product.basePrice - widget.product.finalPrice,
      imageUrl: widget.product.images.isNotEmpty ? widget.product.images.first : null,
    );
    context.read<CartCubit>().add(item);
  }
}
