import re

with open('lib/core/widgets/product_ui.dart', 'r') as f:
    content = f.read()

replacement = """import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../design_system/tokens.dart';
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
    final theme = Theme.of(context);
    
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
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppTokens.r16),
                        border: Border.all(color: theme.dividerColor, width: AppTokens.bThin),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AnimatedScale(
                        scale: _isHovered ? 1.05 : 1.0,
                        duration: AppTokens.animNormal,
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Icon(
                            PhosphorIconsRegular.imageBroken,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
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
                            ? PhosphorIconsFill.heart
                            : PhosphorIconsRegular.heart,
                        color: widget.isFavorite
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface,
                        size: 20,
                      ),
                      onPressed: widget.onFavoriteToggle,
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
                        padding: const EdgeInsets.all(AppTokens.s8),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.s12),
            Text(
              widget.name,
              style: theme.textTheme.titleSmall,
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
    final theme = Theme.of(context);
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
                    ? theme.colorScheme.onSurface
                    : theme.dividerColor,
                width: isSelected ? AppTokens.bThick : AppTokens.bThin,
              ),
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
    final theme = Theme.of(context);
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
              color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : theme.dividerColor,
              ),
              borderRadius: BorderRadius.circular(AppTokens.r12),
            ),
            child: Text(
              size,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? theme.colorScheme.surface : theme.colorScheme.onSurface,
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
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(PhosphorIconsRegular.minus, size: 20),
          onPressed: quantity > 1
              ? () => onQuantityChanged(quantity - 1)
              : null,
          color: theme.colorScheme.onSurface,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.s16,
            vertical: AppTokens.s8,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(AppTokens.r12),
          ),
          child: Text(
            quantity.toString(),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: Icon(PhosphorIconsRegular.plus, size: 20),
          onPressed: () => onQuantityChanged(quantity + 1),
          color: theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}
"""

with open('lib/core/widgets/product_ui.dart', 'w') as f:
    f.write(replacement)
