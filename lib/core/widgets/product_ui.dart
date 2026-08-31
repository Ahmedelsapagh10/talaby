import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../design_system/tokens.dart';
import '../design_system/typography.dart';
import 'pricing.dart';

class ProductCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final double price;
  final double? originalPrice;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.onTap,
    required this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Box
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(AppTokens.r8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AnimatedScale(
                        scale: _isHovered ? 1.05 : 1.0,
                        duration: AppTokens.animNormal,
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppTokens.s8,
                    right: AppTokens.s8,
                    child: IconButton(
                      icon: Icon(
                        widget.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.isFavorite
                            ? Colors.red
                            : const Color(0xFF191B1A),
                      ),
                      onPressed: widget.onFavoriteToggle,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s12),
            Text(
              widget.name,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTokens.s4),
            if (widget.originalPrice != null &&
                widget.originalPrice! > widget.price)
              DiscountPrice(
                originalPrice: widget.originalPrice!,
                discountedPrice: widget.price,
              )
            else
              PriceText(price: widget.price),
          ],
        ),
      ),
    );
  }
}

class ColorSelector extends StatelessWidget {
  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorSelector({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTokens.s8,
      runSpacing: AppTokens.s8,
      children: colors.map((color) {
        final isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF191B1A)
                    : Colors.grey.shade300,
                width: isSelected ? AppTokens.bThick : AppTokens.bThin,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SizeSelector extends StatelessWidget {
  final List<String> sizes;
  final String? selectedSize;
  final ValueChanged<String> onSizeSelected;

  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTokens.s8,
      runSpacing: AppTokens.s8,
      children: sizes.map((size) {
        final isSelected = size == selectedSize;
        return GestureDetector(
          onTap: () => onSizeSelected(size),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s16,
              vertical: AppTokens.s8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF191B1A) : Colors.white,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF191B1A)
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(AppTokens.r4),
            ),
            child: Text(
              size,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? Colors.white : const Color(0xFF191B1A),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: quantity > 1
              ? () => onQuantityChanged(quantity - 1)
              : null,
          color: const Color(0xFF191B1A),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.s16,
            vertical: AppTokens.s8,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(AppTokens.r4),
          ),
          child: Text(
            quantity.toString(),
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onQuantityChanged(quantity + 1),
          color: const Color(0xFF191B1A),
        ),
      ],
    );
  }
}
